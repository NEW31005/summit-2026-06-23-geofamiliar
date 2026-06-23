import 'package:flutter/material.dart';

import '../state/app_scope.dart';
import '../theme/app_colors.dart';
import '../widgets/app_background.dart';
import '../widgets/misc_widgets.dart';

/// Premium preview - explains the recurring value, free vs premium scope, and
/// offers a mock unlock. No real payment in the first build.
class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  static const _features = [
    _Feature(
      Icons.science_rounded,
      '深い生活圏DNA',
      '性格の履歴、週ごとの変化、珍しい場所の組み合わせを見られます。',
    ),
    _Feature(
      Icons.record_voice_over_rounded,
      '声色つき記憶',
      '相棒ごとの話し方に寄せた、少し濃い日記になります。',
    ),
    _Feature(Icons.checkroom_rounded, '衣装と部屋', '通った場所に合わせて、相棒の服や部屋を飾れます。'),
    _Feature(Icons.groups_rounded, '複数の相棒', '通勤用、週末用、旅先用など、複数の相棒を育てられます。'),
    _Feature(Icons.flight_takeoff_rounded, '旅先進化', '旅行中だけの姿や、旅の記憶パックを受け取れます。'),
    _Feature(
      Icons.photo_album_rounded,
      '月間アルバム',
      '一か月分の記憶を、見返せるアルバムとして保存できます。',
    ),
    _Feature(
      Icons.family_restroom_rounded,
      '継承',
      '育ちきった相棒の性格と記憶を、次の相棒へ受け渡せます。',
    ),
  ];

  /// Concrete, side-by-side proof of value - shown before the feature list.
  static const _beforeAfter = [
    _BeforeAfter(
      icon: Icons.record_voice_over_rounded,
      title: '記憶',
      free: '「川沿いはとても静かで、心が落ち着きました。」',
      premium: '「川沿いはとても静かで、心が落ち着きました。」（ため息みたいに、そっと）',
    ),
    _BeforeAfter(
      icon: Icons.science_rounded,
      title: '生活圏DNA',
      free: '今日増えた性格がチップで見えます。',
      premium: '週ごとの推移、珍しい場所の組み合わせ、性格がどう変わったかまで見えます。',
    ),
    _BeforeAfter(
      icon: Icons.family_restroom_rounded,
      title: '相棒',
      free: '1体の相棒を育てられます。',
      premium: '複数の相棒と、育ちきった相棒から次へ受け渡す継承が使えます。',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final isPremium = state.isPremium;

    return Scaffold(
      body: AppBackground(
        night: true,
        child: SafeArea(
          child: Column(
            children: [
              _appBar(context, isPremium),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                  children: [
                    _hero(context, isPremium),
                    const SizedBox(height: 22),
                    Text(
                      '無料とプレミアムの違い',
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    ..._beforeAfter.map(_beforeAfterCard),
                    const SizedBox(height: 20),
                    _comparison(context),
                    const SizedBox(height: 22),
                    Text(
                      'プレミアムに含まれるもの',
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    ..._features.map((f) => _featureCard(f)),
                    const SizedBox(height: 18),
                    _pricing(context),
                    const SizedBox(height: 16),
                    _ethicsNote(),
                    const SizedBox(height: 20),
                    _ctaButton(context, state, isPremium),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        isPremium
                            ? 'デモ解除中です。実際の請求はありません。'
                            : 'これはプレビューです。実際の決済は発生しません。',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white54,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _appBar(BuildContext context, bool isPremium) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          ),
          const Text(
            'GeoFamiliar プレミアム',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          if (isPremium) const PremiumBadge(label: '有効'),
        ],
      ),
    );
  }

  Widget _hero(BuildContext context, bool isPremium) {
    return Column(
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.amber, AppColors.coral],
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: AppColors.amber.withValues(alpha: 0.4),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.workspace_premium_rounded,
            color: Colors.white,
            size: 38,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          isPremium ? 'プレミアム有効中' : 'もっと深く育てて、もっと残す',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 8),
        const Text(
          'プレミアムは相棒の表現と記憶を深くします。無料で遊ぶことへの罰にはしません。',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13.5, height: 1.4, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _comparison(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _planColumn('無料', AppColors.mint, const [
              '相棒1体',
              'さんぽ記録と記憶',
              '基本の生活圏DNA',
              '今週の進化進捗',
            ]),
          ),
          Container(
            width: 1,
            height: 180,
            color: Colors.white.withValues(alpha: 0.12),
          ),
          Expanded(
            child: _planColumn('プレミアム', AppColors.amber, const [
              '無料の全機能',
              '深いDNA分析と声色つき記憶',
              '衣装、部屋、アルバム',
              '複数相棒と継承',
            ]),
          ),
        ],
      ),
    );
  }

  Widget _planColumn(String title, Color accent, List<String> items) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: accent,
            ),
          ),
          const SizedBox(height: 10),
          ...items.map(
            (t) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_rounded, size: 15, color: accent),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      t,
                      style: const TextStyle(
                        fontSize: 12.5,
                        height: 1.3,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _featureCard(_Feature f) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.amber.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(f.icon, color: AppColors.amber, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  f.title,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  f.body,
                  style: const TextStyle(
                    fontSize: 12.5,
                    height: 1.3,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pricing(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.amber.withValues(alpha: 0.16),
            AppColors.coral.withValues(alpha: 0.12),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.amber.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '680円',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 4),
              Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Text(
                  '/ 月',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            '月額サブスクリプション想定です。季節パックや旅の記憶パックは、あとで買い切り追加にできます。',
            style: TextStyle(
              fontSize: 12.5,
              height: 1.35,
              color: Colors.white60,
            ),
          ),
        ],
      ),
    );
  }

  Widget _ethicsNote() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.favorite_border_rounded,
          size: 16,
          color: AppColors.mint,
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Text(
            '無料でも相棒は変わらずそばにいます。プレミアムは表現と保存を増やすもので、罪悪感で引き留める設計にはしません。',
            style: TextStyle(fontSize: 12, height: 1.4, color: Colors.white54),
          ),
        ),
      ],
    );
  }

  Widget _ctaButton(BuildContext context, state, bool isPremium) {
    if (isPremium) {
      return OutlinedButton.icon(
        onPressed: () {
          state.setPremium(false);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('プレミアムデモをオフにしました')));
        },
        icon: const Icon(Icons.lock_open_rounded, color: Colors.white),
        label: const Text('プレミアムデモをオフ', style: TextStyle(color: Colors.white)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.white24, width: 1.5),
          minimumSize: const Size.fromHeight(52),
        ),
      );
    }
    return FilledButton.icon(
      onPressed: () {
        state.setPremium(true);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('プレミアムデモをオンにしました')));
      },
      icon: const Icon(Icons.workspace_premium_rounded),
      label: const Text('プレミアムデモをオン'),
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.amber,
        foregroundColor: AppColors.ink,
      ),
    );
  }

  Widget _beforeAfterCard(_BeforeAfter ba) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(ba.icon, size: 18, color: AppColors.amber),
              const SizedBox(width: 8),
              Text(
                ba.title,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _baRow('無料', ba.free, AppColors.mint, false),
          const SizedBox(height: 8),
          _baRow('プレミアム', ba.premium, AppColors.amber, true),
        ],
      ),
    );
  }

  Widget _baRow(String tag, String text, Color color, bool emphasised) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 64,
          padding: const EdgeInsets.symmetric(vertical: 3),
          margin: const EdgeInsets.only(top: 1),
          decoration: BoxDecoration(
            color: color.withValues(alpha: emphasised ? 0.22 : 0.0),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.5)),
          ),
          child: Text(
            tag,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.35,
              color: emphasised ? Colors.white : Colors.white60,
              fontWeight: emphasised ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}

class _Feature {
  const _Feature(this.icon, this.title, this.body);
  final IconData icon;
  final String title;
  final String body;
}

class _BeforeAfter {
  const _BeforeAfter({
    required this.icon,
    required this.title,
    required this.free,
    required this.premium,
  });
  final IconData icon;
  final String title;
  final String free;
  final String premium;
}
