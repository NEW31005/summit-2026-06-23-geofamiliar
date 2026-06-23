import 'package:flutter/material.dart';

import '../models/companion.dart';
import '../theme/app_colors.dart';
import 'companion_avatar.dart';

/// The companion hero panel - avatar on a soft gradient with name, form, mood
/// and stage. Fixed height for a stable home layout.
class CompanionPanel extends StatelessWidget {
  const CompanionPanel({
    super.key,
    required this.companion,
    this.premium = false,
  });

  final Companion companion;
  final bool premium;

  @override
  Widget build(BuildContext context) {
    final personality = companion.personality;
    final primary = personality.dominant.color;
    final secondary = personality.secondary.color;

    return Container(
      height: 268,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primary.withValues(alpha: 0.16),
            secondary.withValues(alpha: 0.12),
            AppColors.surface,
          ],
        ),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Stack(
        children: [
          // Stage chip
          Positioned(
            top: 14,
            left: 16,
            child: _pill(
              icon: Icons.eco_rounded,
              text: companion.stage.label,
              color: AppColors.mintDeep,
            ),
          ),
          // Mood chip
          Positioned(
            top: 14,
            right: 16,
            child: _pill(
              icon: Icons.mood_rounded,
              text: companion.moodLabel,
              color: AppColors.coralDeep,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                CompanionAvatar(
                  primary: personality.dominant,
                  secondary: personality.secondary,
                  mood: companion.moodLabel,
                  stageRing: companion.stage.ring,
                  seed: companion.visualSeed,
                  sparkle: premium,
                  size: 150,
                ),
                const SizedBox(height: 6),
                Text(
                  companion.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 2),
                Text(
                  '${companion.formName} - ${personality.title}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.inkMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color.lerp(color, AppColors.ink, 0.35),
            ),
          ),
        ],
      ),
    );
  }
}
