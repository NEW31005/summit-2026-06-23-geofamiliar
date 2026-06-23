import 'package:flutter_test/flutter_test.dart';
import 'package:geofamiliar/logic/memory_generator.dart';
import 'package:geofamiliar/models/contexts.dart';
import 'package:geofamiliar/models/dna_trait.dart';
import 'package:geofamiliar/models/memory_card.dart';
import 'package:geofamiliar/models/walk.dart';

Walk _walk(List<PlaceType> places, TimeContext time, WeatherContext weather) =>
    Walk(stops: places.map(RouteStop.new).toList(), time: time, weather: weather);

void main() {
  group('MemoryGenerator', () {
    test('generation is deterministic for the same walk + seed', () {
      final walk = _walk(
        [PlaceType.river, PlaceType.park],
        TimeContext.sunset,
        WeatherContext.clear,
      );
      final a = MemoryGenerator.generate(walk, seed: 4, dayIndex: 2);
      final b = MemoryGenerator.generate(walk, seed: 4, dayIndex: 2);
      expect(a.diary, b.diary);
      expect(a.title, b.title);
      expect(a.id, b.id);
    });

    test('lead trait matches the walk\'s dominant DNA', () {
      final walk = _walk(
        [PlaceType.river, PlaceType.river],
        TimeContext.rainyEvening,
        WeatherContext.rain,
      );
      final memory = MemoryGenerator.generate(walk, seed: 1, dayIndex: 1);
      expect(memory.lead, DnaTrait.calm);
      expect(walk.lead, DnaTrait.calm);
    });

    test('diary fills template tokens (no raw {first}/{last} left)', () {
      final walk = _walk(
        [PlaceType.shopping, PlaceType.station],
        TimeContext.noon,
        WeatherContext.windy,
      );
      final memory = MemoryGenerator.generate(walk, seed: 2, dayIndex: 3);
      expect(memory.diary.contains('{'), isFalse);
      expect(memory.diary, isNotEmpty);
      expect(memory.dayLabel, 'Day 3');
      expect(memory.places.length, 2);
    });

    test('premium memories add a voice-style flourish', () {
      final walk = _walk([PlaceType.cafe], TimeContext.sunset, WeatherContext.humid);
      final free = MemoryGenerator.generate(walk, seed: 0, dayIndex: 1);
      final premium =
          MemoryGenerator.generate(walk, seed: 0, dayIndex: 1, premium: true);
      expect(premium.premium, isTrue);
      expect(premium.diary.length, greaterThan(free.diary.length));
    });

    test('round-trips through JSON', () {
      final walk =
          _walk([PlaceType.nightStore], TimeContext.night, WeatherContext.cloudy);
      final memory = MemoryGenerator.generate(walk, seed: 5, dayIndex: 7);
      final restored = MemoryCard.fromJson(memory.toJson());
      expect(restored.diary, memory.diary);
      expect(restored.lead, memory.lead);
      expect(restored.time, memory.time);
      expect(restored.weather, memory.weather);
      expect(restored.places, memory.places);
    });
  });
}
