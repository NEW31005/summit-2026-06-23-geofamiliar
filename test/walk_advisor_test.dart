import 'package:flutter_test/flutter_test.dart';
import 'package:geofamiliar/logic/walk_advisor.dart';
import 'package:geofamiliar/models/contexts.dart';
import 'package:geofamiliar/models/dna_trait.dart';
import 'package:geofamiliar/models/life_dna.dart';
import 'package:geofamiliar/models/walk.dart';

void main() {
  group('WalkAdvisor.weakestTrait', () {
    test('finds the lowest trait', () {
      final dna = LifeDna.from({
        DnaTrait.vitality: 5,
        DnaTrait.calm: 4,
        DnaTrait.curiosity: 1, // lowest
        DnaTrait.warmth: 3,
        DnaTrait.focus: 2,
        DnaTrait.wonder: 6,
      });
      expect(WalkAdvisor.weakestTrait(dna), DnaTrait.curiosity);
    });

    test('an empty profile is allowed (all zero) and returns a valid trait', () {
      final weak = WalkAdvisor.weakestTrait(LifeDna.empty());
      expect(DnaTrait.values.contains(weak), isTrue);
    });
  });

  group('WalkAdvisor.placeForTrait', () {
    test('returns a place that actually grows the trait', () {
      for (final trait in DnaTrait.values) {
        final place = WalkAdvisor.placeForTrait(trait);
        expect(place.dna[trait], isNotNull,
            reason: '${place.name} should contribute to ${trait.name}');
        expect(place.dna[trait]! > 0, isTrue);
      }
    });

    test('vitality maps to the station', () {
      expect(WalkAdvisor.placeForTrait(DnaTrait.vitality), PlaceType.station);
    });
  });

  group('WalkAdvisor.gentleSuggestion', () {
    test('suggests the weakest trait and a matching place, safely worded', () {
      final dna = LifeDna.from({
        DnaTrait.vitality: 5,
        DnaTrait.calm: 4,
        DnaTrait.curiosity: 3,
        DnaTrait.warmth: 8,
        DnaTrait.focus: 1, // uniquely lowest
        DnaTrait.wonder: 6,
      });
      final s = WalkAdvisor.gentleSuggestion(dna);
      expect(s.weakest, DnaTrait.focus);
      expect(s.place.dna[DnaTrait.focus]! > 0, isTrue);
      // Never pushy: framed as optional / on-your-way, no speed/distance prompts.
      expect(s.message.toLowerCase(), contains('on your way'));
      expect(s.message.toLowerCase(), isNot(contains('faster')));
      expect(s.message.toLowerCase(), isNot(contains('hurry')));
    });
  });

  group('WalkAdvisor.moodForecast', () {
    test('describes the dominant trait of a planned route', () {
      final walk = Walk(
        stops: const [RouteStop(PlaceType.river), RouteStop(PlaceType.park)],
        time: TimeContext.rainyEvening,
        weather: WeatherContext.rain,
      );
      final forecast = WalkAdvisor.moodForecast(walk)!;
      expect(forecast.toLowerCase(), contains('calm'));
      expect(forecast.toLowerCase(), contains('settled'));
    });

    test('returns null for an empty route', () {
      final walk = Walk(stops: const [], time: TimeContext.noon, weather: WeatherContext.clear);
      expect(WalkAdvisor.moodForecast(walk), isNull);
    });
  });
}
