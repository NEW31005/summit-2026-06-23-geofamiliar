import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A selectable place option used in hatch + walk. Stable dimensions so the
/// grid never reflows when selection changes.
class PlaceTile extends StatelessWidget {
  const PlaceTile({
    super.key,
    required this.icon,
    required this.label,
    required this.tagline,
    required this.selected,
    required this.onTap,
    this.accent = AppColors.mintDeep,
  });

  final IconData icon;
  final String label;
  final String tagline;
  final bool selected;
  final VoidCallback onTap;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected ? accent.withValues(alpha: 0.12) : AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? accent : AppColors.hairline,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: selected ? 0.18 : 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 22, color: accent),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tagline,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        height: 1.25,
                        color: AppColors.inkMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                Icon(Icons.check_circle_rounded, size: 20, color: accent),
            ],
          ),
        ),
      ),
    );
  }
}

/// A horizontal wrap of choice pills for time / weather context.
class ChoicePills<T> extends StatelessWidget {
  const ChoicePills({
    super.key,
    required this.items,
    required this.selected,
    required this.labelOf,
    required this.iconOf,
    required this.onSelect,
    this.accent = AppColors.coralDeep,
  });

  final List<T> items;
  final T selected;
  final String Function(T) labelOf;
  final IconData Function(T) iconOf;
  final ValueChanged<T> onSelect;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        final isSel = item == selected;
        return GestureDetector(
          onTap: () => onSelect(item),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isSel ? accent.withValues(alpha: 0.14) : AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: isSel ? accent : AppColors.hairline,
                width: isSel ? 1.6 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(iconOf(item),
                    size: 16,
                    color: isSel ? accent : AppColors.inkMuted),
                const SizedBox(width: 6),
                Text(
                  labelOf(item),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isSel ? Color.lerp(accent, AppColors.ink, 0.4) : AppColors.inkSoft,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
