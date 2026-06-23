import 'package:flutter/material.dart';

import '../models/contexts.dart';
import '../models/dna_trait.dart';
import '../state/app_scope.dart';
import '../theme/app_colors.dart';
import '../widgets/app_background.dart';
import '../widgets/dna_radar.dart';
import '../widgets/dna_widgets.dart';
import '../widgets/section_header.dart';

/// Life DNA screen: a trait wheel, full trait breakdown, this week's mix, and a
/// guide to which places feed which traits.
class DnaScreen extends StatelessWidget {
  const DnaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final dna = state.companion.dna;
    final weekDna = state.weekDna;
    final personality = state.companion.personality;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        Text('Life DNA', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 4),
        const Text(
          'The blend of places, times and weather your companion is made from.',
          style: TextStyle(fontSize: 13, color: AppColors.inkMuted, height: 1.35),
        ),
        const SizedBox(height: 16),

        // Trait wheel
        SoftCard(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          child: Column(
            children: [
              Center(child: DnaRadar(dna: dna, size: 240)),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: personality.dominant.color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(personality.dominant.icon,
                        size: 20, color: personality.dominant.color),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(personality.title,
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 2),
                          Text(personality.description,
                              style: const TextStyle(
                                  fontSize: 12.5,
                                  height: 1.3,
                                  color: AppColors.inkSoft)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Full breakdown
        const SectionHeader(eyebrow: 'Breakdown', title: 'Trait totals'),
        const SizedBox(height: 8),
        SoftCard(
          child: Column(
            children: DnaTrait.values
                .map((t) => TraitBar(
                      trait: t,
                      fill: dna.relative(t),
                      value: dna.of(t),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 20),

        // Weekly mix
        const SectionHeader(eyebrow: 'This week', title: 'Weekly DNA mix'),
        const SizedBox(height: 8),
        if (weekDna.sum > 0)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: weekDna.ranked
                .where((t) => weekDna.of(t) > 0)
                .map((t) => DnaChip(trait: t, value: weekDna.of(t)))
                .toList(),
          )
        else
          const Text('Take a walk to start this week\'s mix.',
              style: TextStyle(fontSize: 13, color: AppColors.inkMuted)),
        const SizedBox(height: 22),

        // Place contribution guide
        const SectionHeader(eyebrow: 'Guide', title: 'Where traits come from'),
        const SizedBox(height: 8),
        SoftCard(
          child: Column(
            children: [
              for (int i = 0; i < PlaceType.values.length; i++) ...[
                _placeRow(PlaceType.values[i]),
                if (i != PlaceType.values.length - 1)
                  const Divider(height: 16, color: AppColors.hairline),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _placeRow(PlaceType place) {
    return Row(
      children: [
        Icon(place.icon, size: 20, color: AppColors.inkSoft),
        const SizedBox(width: 10),
        SizedBox(
          width: 96,
          child: Text(place.label,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink)),
        ),
        Expanded(
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            alignment: WrapAlignment.end,
            children: place.dna.keys
                .map((t) => DnaChip(trait: t, dense: true))
                .toList(),
          ),
        ),
      ],
    );
  }
}
