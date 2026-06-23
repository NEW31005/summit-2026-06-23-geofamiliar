import 'package:flutter_test/flutter_test.dart';
import 'package:geofamiliar/logic/evolution_engine.dart';
import 'package:geofamiliar/models/dna_trait.dart';
import 'package:geofamiliar/models/evolution.dart';
import 'package:geofamiliar/models/life_dna.dart';

void main() {
  group('EvolutionEngine.stageFor', () {
    test('maps total walks to the right stage', () {
      expect(EvolutionEngine.stageFor(0), EvolutionStage.hatchling);
      expect(EvolutionEngine.stageFor(4), EvolutionStage.hatchling);
      expect(EvolutionEngine.stageFor(5), EvolutionStage.wanderer);
      expect(EvolutionEngine.stageFor(12), EvolutionStage.kindred);
      expect(EvolutionEngine.stageFor(22), EvolutionStage.luminary);
      expect(EvolutionEngine.stageFor(99), EvolutionStage.luminary);
    });
  });

  group('weekly progress', () {
    test('progress clamps between 0 and 1', () {
      expect(EvolutionEngine.weeklyProgress(0), 0);
      expect(EvolutionEngine.weeklyProgress(5), 1);
      expect(EvolutionEngine.weeklyProgress(8), 1);
    });

    test('week is ready only at or beyond the target', () {
      expect(EvolutionEngine.weekReady(4), isFalse);
      expect(EvolutionEngine.weekReady(5), isTrue);
    });

    test('remaining walks count down to zero, never negative', () {
      expect(EvolutionEngine.walksRemaining(0), EvolutionEngine.walksPerWeek);
      expect(EvolutionEngine.walksRemaining(3), 2);
      expect(EvolutionEngine.walksRemaining(7), 0);
    });
  });

  group('buildWeeklyCard', () {
    test('flags evolution when a stage boundary is crossed', () {
      // Before: 4 walks (hatchling). After +1 = 5 walks (wanderer).
      final card = EvolutionEngine.buildWeeklyCard(
        week: 1,
        totalWalksBefore: 4,
        walksThisWeek: 1,
        memoriesThisWeek: 1,
        weekDna: LifeDna.from({DnaTrait.curiosity: 4}),
      );
      expect(card.evolved, isTrue);
      expect(card.stage, EvolutionStage.wanderer);
      expect(card.topTrait, DnaTrait.curiosity);
      expect(card.headline.toLowerCase(), contains('wanderer'));
    });

    test('no evolution flag when staying within a stage', () {
      final card = EvolutionEngine.buildWeeklyCard(
        week: 2,
        totalWalksBefore: 6,
        walksThisWeek: 3,
        memoriesThisWeek: 3,
        weekDna: LifeDna.from({DnaTrait.warmth: 6}),
      );
      expect(card.evolved, isFalse);
      expect(card.stage, EvolutionStage.wanderer);
      expect(card.topTrait, DnaTrait.warmth);
      expect(card.walks, 3);
      expect(card.memories, 3);
    });

    test('falls back to calm top trait when the week has no DNA', () {
      final card = EvolutionEngine.buildWeeklyCard(
        week: 1,
        totalWalksBefore: 0,
        walksThisWeek: 0,
        memoriesThisWeek: 0,
        weekDna: LifeDna.empty(),
      );
      expect(card.topTrait, DnaTrait.calm);
    });

    test('round-trips through JSON', () {
      final card = EvolutionEngine.buildWeeklyCard(
        week: 3,
        totalWalksBefore: 11,
        walksThisWeek: 1,
        memoriesThisWeek: 1,
        weekDna: LifeDna.from({DnaTrait.focus: 3}),
      );
      final restored = WeeklyCard.fromJson(card.toJson());
      expect(restored.week, card.week);
      expect(restored.stage, card.stage);
      expect(restored.evolved, card.evolved);
      expect(restored.topTrait, card.topTrait);
    });
  });
}
