import 'package:flutter/material.dart';

import '../models/dna_trait.dart';
import '../theme/app_colors.dart';

/// A compact Life DNA chip: trait icon + label, tinted by the trait's colour.
/// Stable height so rows of chips never jump.
class DnaChip extends StatelessWidget {
  const DnaChip({
    super.key,
    required this.trait,
    this.value,
    this.dense = false,
  });

  final DnaTrait trait;
  final double? value;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: dense ? 30 : 34,
      padding: EdgeInsets.symmetric(horizontal: dense ? 10 : 12),
      decoration: BoxDecoration(
        color: trait.color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: trait.color.withValues(alpha: 0.30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(trait.icon, size: dense ? 14 : 16, color: _ink(trait.color)),
          const SizedBox(width: 6),
          Text(
            trait.label,
            style: TextStyle(
              fontSize: dense ? 12 : 13,
              fontWeight: FontWeight.w700,
              color: _ink(trait.color),
            ),
          ),
          if (value != null) ...[
            const SizedBox(width: 5),
            Text(
              value!.toStringAsFixed(0),
              style: TextStyle(
                fontSize: dense ? 11 : 12,
                fontWeight: FontWeight.w800,
                color: _ink(trait.color).withValues(alpha: 0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _ink(Color base) => Color.lerp(base, AppColors.ink, 0.45)!;
}

/// A labelled progress bar for a single trait. [fill] is 0..1.
class TraitBar extends StatelessWidget {
  const TraitBar({
    super.key,
    required this.trait,
    required this.fill,
    this.value,
  });

  final DnaTrait trait;
  final double fill;
  final double? value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Icon(trait.icon, size: 18, color: trait.color),
          ),
          SizedBox(
            width: 74,
            child: Text(
              trait.label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.inkSoft,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  Container(height: 10, color: AppColors.surfaceAlt),
                  AnimatedFractionallySizedBox(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutCubic,
                    widthFactor: fill.clamp(0.0, 1.0),
                    child: Container(
                      height: 10,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            trait.color.withValues(alpha: 0.7),
                            trait.color,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (value != null) ...[
            const SizedBox(width: 10),
            SizedBox(
              width: 26,
              child: Text(
                value!.toStringAsFixed(0),
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.inkMuted,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
