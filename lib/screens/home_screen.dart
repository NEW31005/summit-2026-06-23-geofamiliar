import 'package:flutter/material.dart';

import '../state/app_scope.dart';
import '../theme/app_colors.dart';
import '../widgets/companion_panel.dart';
import '../widgets/dna_widgets.dart';
import '../widgets/misc_widgets.dart';
import '../widgets/section_header.dart';

/// The companion home: hero panel, today's Life DNA, weekly progress, and the
/// single most-important action - start today's walk.
class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.onNavigate,
    required this.onOpenPremium,
  });

  /// Switch the bottom-nav tab (0 Home, 1 Walk, 2 DNA, 3 Memories, 4 Evolve).
  final ValueChanged<int> onNavigate;
  final VoidCallback onOpenPremium;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final companion = state.companion;
    final dna = companion.dna;
    final topTraits = dna.ranked.where((t) => dna.of(t) > 0).take(4).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      children: [
        _topBar(context, state),
        const SizedBox(height: 12),
        CompanionPanel(companion: companion, premium: state.isPremium),
        const SizedBox(height: 16),

        // Primary action - the most prominent element on the screen.
        FilledButton.icon(
          onPressed: () => onNavigate(1),
          icon: const Icon(Icons.directions_walk_rounded),
          label: const Text('今日のさんぽを記録'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.coralDeep,
            foregroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => onNavigate(2),
                icon: const Icon(Icons.science_rounded, size: 18),
                label: const Text('生活圏DNA'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => onNavigate(3),
                icon: const Icon(Icons.auto_stories_rounded, size: 18),
                label: const Text('記憶'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),

        // Today's Life DNA
        const SectionHeader(eyebrow: '今日', title: '今までの生活圏DNA'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: topTraits
              .map((t) => DnaChip(trait: t, value: dna.of(t)))
              .toList(),
        ),
        const SizedBox(height: 20),

        _weeklyProgress(context, state),
        const SizedBox(height: 20),

        // Stat row
        Row(
          children: [
            Expanded(
              child: StatPill(
                value: '${companion.totalWalks}',
                label: 'さんぽ',
                icon: Icons.directions_walk_rounded,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatPill(
                value: '${state.memories.length}',
                label: '記憶',
                icon: Icons.auto_stories_rounded,
                color: AppColors.coralDeep,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatPill(
                value: '週${companion.week}',
                label: '今週',
                icon: Icons.calendar_today_rounded,
                color: AppColors.amber,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        if (!state.isPremium) _premiumBanner(context),
      ],
    );
  }

  Widget _topBar(BuildContext context, state) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'GeoFamiliar',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Text(
                '生活圏から生まれる相棒',
                style: TextStyle(fontSize: 12.5, color: AppColors.inkMuted),
              ),
            ],
          ),
        ),
        if (state.isPremium)
          const PremiumBadge()
        else
          IconButton(
            onPressed: onOpenPremium,
            tooltip: 'プレミアム',
            icon: const Icon(
              Icons.workspace_premium_rounded,
              color: AppColors.amber,
            ),
          ),
        _menu(context, state),
      ],
    );
  }

  Widget _menu(BuildContext context, state) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_rounded, color: AppColors.inkMuted),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      onSelected: (value) {
        if (value == 'rename') {
          _renameDialog(context, state);
        } else if (value == 'reset') {
          _resetDialog(context, state);
        }
      },
      itemBuilder: (_) => const [
        PopupMenuItem(
          value: 'rename',
          child: Row(
            children: [
              Icon(Icons.edit_rounded, size: 18, color: AppColors.inkSoft),
              SizedBox(width: 10),
              Text('相棒の名前を変える'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'reset',
          child: Row(
            children: [
              Icon(
                Icons.restart_alt_rounded,
                size: 18,
                color: AppColors.coralDeep,
              ),
              SizedBox(width: 10),
              Text('最初からやり直す'),
            ],
          ),
        ),
      ],
    );
  }

  void _renameDialog(BuildContext context, state) {
    final controller = TextEditingController(text: state.companion.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('相棒の名前を変える'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 16,
          decoration: const InputDecoration(hintText: '名前'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () {
              state.renameCompanion(controller.text);
              Navigator.of(ctx).pop();
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.mintDeep,
              foregroundColor: Colors.white,
            ),
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _resetDialog(BuildContext context, state) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('最初からやり直しますか？'),
        content: const Text('今の相棒と記憶カードを消して、新しいたまごから始めます。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('今の相棒を残す'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              state.resetGame();
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.coralDeep,
              foregroundColor: Colors.white,
            ),
            child: const Text('やり直す'),
          ),
        ],
      ),
    );
  }

  Widget _weeklyProgress(BuildContext context, state) {
    final companion = state.companion;
    final progress = companion.weeklyProgress;
    final ready = companion.weekReady;
    final remaining = state.walksRemaining;

    return GestureDetector(
      onTap: () => onNavigate(4),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
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
                Icon(
                  ready ? Icons.celebration_rounded : Icons.eco_rounded,
                  size: 18,
                  color: ready ? AppColors.amber : AppColors.mintDeep,
                ),
                const SizedBox(width: 8),
                Text('今週の進化', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                Text(
                  ready ? '受け取れます' : 'あと$remaining回',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: ready ? AppColors.amber : AppColors.inkMuted,
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
                    widthFactor: progress == 0 ? 0.02 : progress,
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
            const SizedBox(height: 8),
            Text(
              ready ? 'タップすると今週の進化カードを開きます。' : 'いつもの場所を記録すると、次の進化に近づきます。',
              style: const TextStyle(fontSize: 12.5, color: AppColors.inkMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _premiumBanner(BuildContext context) {
    return GestureDetector(
      onTap: onOpenPremium,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [AppColors.ink, AppColors.inkSoft],
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.amber, AppColors.coral],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.workspace_premium_rounded,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'GeoFamiliar プレミアム',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '深いDNA分析、声色つき記憶、継承など',
                    style: TextStyle(fontSize: 12, color: Colors.white70),
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
