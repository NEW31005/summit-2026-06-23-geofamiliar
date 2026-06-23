import 'package:flutter/material.dart';

import '../logic/evolution_engine.dart';
import '../models/evolution.dart';
import '../state/app_scope.dart';
import '../theme/app_colors.dart';
import '../widgets/section_header.dart';

/// Evolution screen: stage roadmap, weekly progress with a claimable evolution
/// card, a collection of past weekly cards, and an inheritance teaser.
class EvolutionScreen extends StatelessWidget {
  const EvolutionScreen({super.key, required this.onOpenPremium});

  final VoidCallback onOpenPremium;

  void _claim(BuildContext context) {
    final card = AppScope.read(context).claimWeeklyEvolution();
    if (card != null) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _EvolutionSheet(card: card),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final companion = state.companion;
    final cards = state.weeklyCards;
    final ready = companion.weekReady;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        Text('進化', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 4),
        const Text(
          '一週間のさんぽは、相棒がどう育ったかを残す進化カードになります。',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.inkMuted,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 18),

        _stageRoadmap(context, companion.stage),
        const SizedBox(height: 20),

        // Weekly progress / claim
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: ready
                  ? [
                      AppColors.amber.withValues(alpha: 0.18),
                      AppColors.coral.withValues(alpha: 0.12),
                    ]
                  : [AppColors.mint.withValues(alpha: 0.12), AppColors.surface],
            ),
            border: Border.all(
              color: ready ? AppColors.amber : AppColors.hairline,
              width: ready ? 1.6 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '${companion.week}週目',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  Text(
                    '${companion.walksThisWeek}/${EvolutionEngine.walksPerWeek}回',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.inkMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  children: [
                    Container(height: 12, color: AppColors.surfaceAlt),
                    AnimatedFractionallySizedBox(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutCubic,
                      widthFactor: companion.weeklyProgress == 0
                          ? 0.02
                          : companion.weeklyProgress,
                      child: Container(
                        height: 12,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.mint, AppColors.amber],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              if (ready)
                FilledButton.icon(
                  onPressed: () => _claim(context),
                  icon: const Icon(Icons.celebration_rounded),
                  label: const Text('今週の進化カードを受け取る'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.coralDeep,
                    foregroundColor: Colors.white,
                  ),
                )
              else
                Text(
                  'あと${state.walksRemaining}回さんぽを記録すると、今週の進化カードを受け取れます。',
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    color: AppColors.inkSoft,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 22),

        SectionHeader(
          eyebrow: 'コレクション',
          title: '進化カード',
          trailing: Text(
            '${cards.length}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.inkMuted,
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (cards.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.hairline),
            ),
            child: const Column(
              children: [
                Icon(Icons.style_rounded, size: 28, color: AppColors.inkMuted),
                SizedBox(height: 8),
                Text(
                  'まだ進化カードがありません',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.inkSoft,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '一週間分のさんぽを記録すると、最初のカードを受け取れます',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12.5, color: AppColors.inkMuted),
                ),
              ],
            ),
          )
        else
          for (final c in cards) ...[
            WeeklyCardView(card: c),
            const SizedBox(height: 12),
          ],
        const SizedBox(height: 12),

        _inheritanceTeaser(context),
      ],
    );
  }

  Widget _stageRoadmap(BuildContext context, EvolutionStage current) {
    final stages = EvolutionStage.values
        .where((s) => s != EvolutionStage.egg)
        .toList();
    return SizedBox(
      height: 84,
      child: Row(
        children: List.generate(stages.length, (i) {
          final s = stages[i];
          final reached = current.ring >= s.ring;
          final isCurrent = current == s;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: reached
                              ? AppColors.mintDeep
                              : AppColors.surfaceAlt,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isCurrent
                                ? AppColors.amber
                                : AppColors.hairline,
                            width: isCurrent ? 2.5 : 1,
                          ),
                        ),
                        child: Icon(
                          reached
                              ? Icons.eco_rounded
                              : Icons.lock_outline_rounded,
                          size: 18,
                          color: reached ? Colors.white : AppColors.inkMuted,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        s.label,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: isCurrent
                              ? FontWeight.w800
                              : FontWeight.w600,
                          color: isCurrent ? AppColors.ink : AppColors.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                if (i != stages.length - 1)
                  Container(
                    width: 14,
                    height: 2,
                    margin: const EdgeInsets.only(bottom: 24),
                    color: current.ring > s.ring
                        ? AppColors.mintDeep
                        : AppColors.hairline,
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _inheritanceTeaser(BuildContext context) {
    return GestureDetector(
      onTap: onOpenPremium,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(colors: AppColors.nightGradient),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.violet.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.family_restroom_rounded,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '継承',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '育ちきった相棒の性格と記憶を、次の相棒へ引き継げます。プレミアム機能です。',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white70),
          ],
        ),
      ),
    );
  }
}

/// A collectible weekly evolution card with a night-sky gradient.
class WeeklyCardView extends StatelessWidget {
  const WeeklyCardView({super.key, required this.card});

  final WeeklyCard card;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.nightGradient,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: card.topTrait.color.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${card.week}週目',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const Spacer(),
              if (card.evolved)
                const Row(
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      size: 14,
                      color: AppColors.amber,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '進化',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.amber,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: card.topTrait.color.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  card.topTrait.icon,
                  color: card.topTrait.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.headline,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      card.stage.label,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            card.summary,
            style: const TextStyle(
              fontSize: 13,
              height: 1.4,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _stat('${card.walks}', 'さんぽ'),
              const SizedBox(width: 18),
              _stat('${card.memories}', '記憶'),
              const SizedBox(width: 18),
              _stat(card.topTrait.label, '強いDNA'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.white54),
        ),
      ],
    );
  }
}

class _EvolutionSheet extends StatelessWidget {
  const _EvolutionSheet({required this.card});

  final WeeklyCard card;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.hairline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            card.evolved ? '相棒が進化しました' : '一週間がまとまりました',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          WeeklyCardView(card: card),
          const SizedBox(height: 8),
          if (!card.evolved)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'いつもの場所を記録していくと、次の段階に近づきます。',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.5, color: AppColors.inkMuted),
              ),
            ),
          const SizedBox(height: 10),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.mintDeep,
              foregroundColor: Colors.white,
            ),
            child: const Text('コレクションに追加'),
          ),
        ],
      ),
    );
  }
}
