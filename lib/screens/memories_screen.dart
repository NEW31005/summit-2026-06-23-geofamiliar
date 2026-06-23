import 'package:flutter/material.dart';

import '../models/contexts.dart';
import '../models/memory_card.dart';
import '../state/app_scope.dart';
import '../theme/app_colors.dart';
import '../widgets/dna_widgets.dart';
import '../widgets/misc_widgets.dart';

/// Memories diary - a timeline of the companion's lines, newest first.
class MemoriesScreen extends StatelessWidget {
  const MemoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final memories = state.memories;

    if (memories.isEmpty) {
      return EmptyState(
        icon: Icons.auto_stories_rounded,
        title: 'No memories yet',
        message:
            'Finish a walk and your companion will write its first diary line here.',
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Memories',
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 4),
                  Text(
                    '${memories.length} diary line${memories.length == 1 ? '' : 's'} from your places',
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.inkMuted),
                  ),
                ],
              ),
            ),
            if (state.isPremium) const PremiumBadge(label: 'Album'),
          ],
        ),
        const SizedBox(height: 18),
        for (final m in memories) ...[
          _MemoryTile(memory: m),
          const SizedBox(height: 12),
        ],
        if (!state.isPremium) ...[
          const SizedBox(height: 4),
          _albumTeaser(context),
        ],
      ],
    );
  }

  Widget _albumTeaser(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.amber.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.amber.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.photo_album_rounded,
              size: 20, color: AppColors.coralDeep),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Premium turns these into an exportable monthly album with voice-style lines.',
              style: TextStyle(fontSize: 12.5, height: 1.3, color: AppColors.inkSoft),
            ),
          ),
        ],
      ),
    );
  }
}

class _MemoryTile extends StatelessWidget {
  const _MemoryTile({required this.memory});

  final MemoryCard memory;

  @override
  Widget build(BuildContext context) {
    final lead = memory.lead;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header strip tinted by lead trait
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: lead.color.withValues(alpha: 0.12),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: lead.color.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(memory.icon, size: 19, color: lead.color),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(memory.title,
                          style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink)),
                      Text(
                        '${memory.dayLabel}  -  ${memory.time.label}  -  ${memory.weather.label}',
                        style: const TextStyle(
                            fontSize: 11.5, color: AppColors.inkMuted),
                      ),
                    ],
                  ),
                ),
                if (memory.premium) const PremiumBadge(label: 'Voice'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('"${memory.diary}"',
                    style: const TextStyle(
                        fontSize: 14,
                        height: 1.45,
                        fontStyle: FontStyle.italic,
                        color: AppColors.ink)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    DnaChip(trait: lead, dense: true),
                    ..._uniquePlaces(memory).map((p) => Container(
                          height: 30,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceAlt,
                            borderRadius: BorderRadius.circular(13),
                            border: Border.all(color: AppColors.hairline),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(p.icon, size: 13, color: AppColors.inkMuted),
                              const SizedBox(width: 5),
                              Text(p.label,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.inkSoft)),
                            ],
                          ),
                        )),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<PlaceType> _uniquePlaces(MemoryCard m) {
    final seen = <String>{};
    return m.places.where((p) => seen.add(p.name)).toList();
  }
}
