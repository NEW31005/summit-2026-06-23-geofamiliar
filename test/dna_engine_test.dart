import 'package:flutter_test/flutter_test.dart';
import 'package:geofamiliar/logic/dna_engine.dart';
import 'package:geofamiliar/models/contexts.dart';
import 'package:geofamiliar/models/dna_trait.dart';
import 'package:geofamiliar/models/life_dna.dart';

void main() {
  group('DnaEngine.contextDna', () {
    test('merges place, time and weather trait points', () {
      // Station: vitality 2, focus 1 | morning: vitality +1 | clear: vitality +0.5
      final dna = DnaEngine.contextDna(
        PlaceType.station,
        TimeContext.morning,
        WeatherContext.clear,
      );
      expect(dna[DnaTrait.vitality], closeTo(3.5, 1e-9));
      expect(dna[DnaTrait.focus], closeTo(1.0, 1e-9));
    });

    test('a riverside rainy evening leans calm', () {
      // River: calm 2, wonder 1 | rainy evening: calm +1 | rain: calm +0.5
      final dna = DnaEngine.contextLifeDna(
        PlaceType.river,
        TimeContext.rainyEvening,
        WeatherContext.rain,
      );
      expect(dna.dominant, DnaTrait.calm);
      expect(dna.of(DnaTrait.calm), closeTo(3.5, 1e-9));
    });
  });

  group('Personality', () {
    test('dominant trait drives the form name', () {
      final calm = LifeDna.from({DnaTrait.calm: 5, DnaTrait.warmth: 2});
      expect(DnaEngine.formName(calm.dominant), 'Driftling');

      final vital = LifeDna.from({DnaTrait.vitality: 6, DnaTrait.focus: 2});
      expect(DnaEngine.formName(vital.dominant), 'Sparkling');
    });

    test('personality uses dominant then secondary, never equal', () {
      final dna = LifeDna.from({
        DnaTrait.curiosity: 5,
        DnaTrait.wonder: 3,
        DnaTrait.calm: 1,
      });
      final p = DnaEngine.personality(dna);
      expect(p.dominant, DnaTrait.curiosity);
      expect(p.secondary, DnaTrait.wonder);
      expect(p.dominant == p.secondary, isFalse);
      expect(p.title, isNotEmpty);
      expect(p.description, isNotEmpty);
    });
  });

  group('LifeDna math', () {
    test('combine adds totals immutably', () {
      final a = LifeDna.from({DnaTrait.calm: 2});
      final b = LifeDna.from({DnaTrait.calm: 3, DnaTrait.focus: 1});
      final c = a.combine(b);
      expect(c.of(DnaTrait.calm), 5);
      expect(c.of(DnaTrait.focus), 1);
      // original untouched
      expect(a.of(DnaTrait.calm), 2);
    });

    test('balance is higher for an even spread than a one-note blend', () {
      final even = LifeDna.from({for (final t in DnaTrait.values) t: 2.0});
      final oneNote = LifeDna.from({DnaTrait.calm: 10});
      expect(even.balance, greaterThan(oneNote.balance));
      expect(even.balance, closeTo(1.0, 1e-6));
      expect(oneNote.balance, closeTo(0.0, 1e-6));
    });

    test('empty DNA reports zero shares without dividing by zero', () {
      final empty = LifeDna.empty();
      expect(empty.sum, 0);
      expect(empty.share(DnaTrait.calm), 0);
      expect(empty.relative(DnaTrait.calm), 0);
    });

    test('round-trips through JSON', () {
      final dna = LifeDna.from({DnaTrait.warmth: 4, DnaTrait.focus: 1.5});
      final restored = LifeDna.fromJson(dna.toJson());
      expect(restored.of(DnaTrait.warmth), 4);
      expect(restored.of(DnaTrait.focus), 1.5);
    });
  });
}
