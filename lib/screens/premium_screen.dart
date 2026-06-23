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
    _Feature(Icons.science_rounded, 'Deep Life DNA',
        'Full trait history, weekly DNA trends and rare place combos.'),
    _Feature(Icons.record_voice_over_rounded, 'Voice-style memories',
        'Diary lines delivered in your companion\'s own voice tone.'),
    _Feature(Icons.checkroom_rounded, 'Outfits & rooms',
        'Dress your companion and theme its home to match your places.'),
    _Feature(Icons.groups_rounded, 'Multiple companions',
        'Grow more than one - a commuter, a weekend wanderer, a traveller.'),
    _Feature(Icons.flight_takeoff_rounded, 'Travel evolutions',
        'Trips unlock special travel-only forms and memory packs.'),
    _Feature(Icons.photo_album_rounded, 'Monthly album export',
        'Turn your month of memories into a shareable keepsake.'),
    _Feature(Icons.family_restroom_rounded, 'Legacy & inheritance',
        'Pass a mature companion\'s traits and memories to the next.'),
  ];

  /// Concrete, side-by-side proof of value - shown before the feature list.
  static const _beforeAfter = [
    _BeforeAfter(
      icon: Icons.record_voice_over_rounded,
      title: 'Memories',
      free: '"The riverside was so still. I felt myself settle."',
      premium:
          '"The riverside was so still. I felt myself settle." (murmured, almost a sigh)',
    ),
    _BeforeAfter(
      icon: Icons.science_rounded,
      title: 'Life DNA',
      free: 'Today\'s top traits as simple chips.',
      premium:
          'Weekly trend lines, rare place combos, and how each week shifted the blend.',
    ),
    _BeforeAfter(
      icon: Icons.family_restroom_rounded,
      title: 'Companions',
      free: 'One companion, growing with you.',
      premium:
          'Multiple companions, plus legacy: a Luminary passes its traits to the next.',
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
                    Text('See the difference',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(color: Colors.white)),
                    const SizedBox(height: 12),
                    ..._beforeAfter.map(_beforeAfterCard),
                    const SizedBox(height: 20),
                    _comparison(context),
                    const SizedBox(height: 22),
                    Text('Everything in Premium',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(color: Colors.white)),
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
                            ? 'Demo unlock active - no real charge.'
                            : 'This is a preview. No real payment is taken.',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.white54),
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
          const Text('GeoFamiliar Premium',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Colors.white)),
          const Spacer(),
          if (isPremium) const PremiumBadge(label: 'Active'),
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
                colors: [AppColors.amber, AppColors.coral]),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                  color: AppColors.amber.withValues(alpha: 0.4),
                  blurRadius: 24,
                  offset: const Offset(0, 8)),
            ],
          ),
          child: const Icon(Icons.workspace_premium_rounded,
              color: Colors.white, size: 38),
        ),
        const SizedBox(height: 16),
        Text(
          isPremium ? 'You\'re Premium' : 'Grow deeper, remember more',
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 8),
        const Text(
          'Premium unlocks depth and expression - never a punishment for playing free.',
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
            child: _planColumn(
              'Free',
              AppColors.mint,
              const [
                'Hatch one companion',
                'Daily walks & memories',
                'Basic Life DNA',
                'Weekly evolution progress',
              ],
            ),
          ),
          Container(
              width: 1, height: 180, color: Colors.white.withValues(alpha: 0.12)),
          Expanded(
            child: _planColumn(
              'Premium',
              AppColors.amber,
              const [
                'Everything in Free',
                'Deep DNA & voice memories',
                'Outfits, rooms & albums',
                'Multiple companions & legacy',
              ],
            ),
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
          Text(title,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: accent)),
          const SizedBox(height: 10),
          ...items.map((t) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_rounded, size: 15, color: accent),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(t,
                          style: const TextStyle(
                              fontSize: 12.5,
                              height: 1.3,
                              color: Colors.white70)),
                    ),
                  ],
                ),
              )),
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
                Text(f.title,
                    style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
                const SizedBox(height: 2),
                Text(f.body,
                    style: const TextStyle(
                        fontSize: 12.5, height: 1.3, color: Colors.white60)),
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
        gradient: LinearGradient(colors: [
          AppColors.amber.withValues(alpha: 0.16),
          AppColors.coral.withValues(alpha: 0.12),
        ]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.amber.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Yen 680',
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: Colors.white)),
              SizedBox(width: 4),
              Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Text('/ month',
                    style: TextStyle(fontSize: 14, color: Colors.white70)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Monthly subscription. Seasonal packs and travel-memory packs available later as one-off add-ons.',
            style: TextStyle(fontSize: 12.5, height: 1.35, color: Colors.white60),
          ),
        ],
      ),
    );
  }

  Widget _ethicsNote() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.favorite_border_rounded,
            size: 16, color: AppColors.mint),
        const SizedBox(width: 8),
        const Expanded(
          child: Text(
            'Your companion will always be warm to you, paid or not. Premium adds room to express and remember - it never guilt-trips you into staying.',
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Premium demo turned off')),
          );
        },
        icon: const Icon(Icons.lock_open_rounded, color: Colors.white),
        label: const Text('Turn off Premium (demo)',
            style: TextStyle(color: Colors.white)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.white24, width: 1.5),
          minimumSize: const Size.fromHeight(52),
        ),
      );
    }
    return FilledButton.icon(
      onPressed: () {
        state.setPremium(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Premium unlocked (demo) - enjoy!')),
        );
      },
      icon: const Icon(Icons.workspace_premium_rounded),
      label: const Text('Unlock Premium (demo)'),
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
              Text(ba.title,
                  style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white)),
            ],
          ),
          const SizedBox(height: 12),
          _baRow('Free', ba.free, AppColors.mint, false),
          const SizedBox(height: 8),
          _baRow('Premium', ba.premium, AppColors.amber, true),
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
          child: Text(tag,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: color)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text,
              style: TextStyle(
                  fontSize: 12.5,
                  height: 1.35,
                  color: emphasised ? Colors.white : Colors.white60,
                  fontWeight: emphasised ? FontWeight.w600 : FontWeight.w400)),
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
