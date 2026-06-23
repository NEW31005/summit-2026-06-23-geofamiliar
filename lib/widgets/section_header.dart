import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A consistent section heading: an eyebrow label, a title, and optional action.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.eyebrow,
    this.trailing,
  });

  final String title;
  final String? eyebrow;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (eyebrow case final String eb) ...[
                Text(
                  eb.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.mintDeep,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
              ],
              Text(title, style: theme.textTheme.titleLarge),
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}
