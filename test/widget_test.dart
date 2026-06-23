import 'package:flutter_test/flutter_test.dart';
import 'package:geofamiliar/app.dart';
import 'package:geofamiliar/models/contexts.dart';
import 'package:geofamiliar/models/walk.dart';
import 'package:geofamiliar/state/app_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    // Start each test from clean local storage.
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('fresh launch shows the hatch onboarding flow', (tester) async {
    final state = AppState();
    await state.init();
    await tester.pumpWidget(GeoFamiliarApp(state: state));
    // The companion avatar animates forever, so advance time manually rather
    // than pumpAndSettle (which would never converge).
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('GeoFamiliar'), findsOneWidget);
    expect(find.text('今日の場所から生まれさせる'), findsOneWidget);
    expect(state.hasHatched, isFalse);
  });

  group('AppState game loop', () {
    test('hatch seeds DNA and writes a first memory', () async {
      final state = AppState();
      await state.init();

      state.hatch(PlaceType.river, TimeContext.sunset, WeatherContext.clear);

      expect(state.hasHatched, isTrue);
      expect(state.companion.dna.sum, greaterThan(0));
      expect(state.memories.length, 1);
      expect(state.companion.name, isNotEmpty);
    });

    test('completing walks grows the companion and adds memories', () async {
      final state = AppState();
      await state.init();
      state.hatch(PlaceType.station, TimeContext.morning, WeatherContext.clear);

      final beforeDna = state.companion.dna.sum;
      for (var i = 0; i < 5; i++) {
        state.completeWalk(
          Walk(
            stops: const [RouteStop(PlaceType.park), RouteStop(PlaceType.cafe)],
            time: TimeContext.noon,
            weather: WeatherContext.clear,
          ),
        );
      }

      expect(state.companion.totalWalks, 5);
      expect(state.companion.walksThisWeek, 5);
      expect(state.companion.dna.sum, greaterThan(beforeDna));
      expect(state.memories.length, 6); // hatch + 5 walks
      expect(state.companion.weekReady, isTrue);
    });

    test(
      'claiming weekly evolution produces a card and resets the week',
      () async {
        final state = AppState();
        await state.init();
        state.hatch(
          PlaceType.station,
          TimeContext.morning,
          WeatherContext.clear,
        );
        for (var i = 0; i < 5; i++) {
          state.completeWalk(
            Walk(
              stops: const [RouteStop(PlaceType.river)],
              time: TimeContext.night,
              weather: WeatherContext.rain,
            ),
          );
        }

        final card = state.claimWeeklyEvolution();

        expect(card, isNotNull);
        expect(state.weeklyCards.length, 1);
        expect(state.companion.week, 2);
        expect(state.companion.walksThisWeek, 0);
        expect(state.weekDna.sum, 0);
      },
    );

    test('weekly evolution cannot be claimed early', () async {
      final state = AppState();
      await state.init();
      state.hatch(PlaceType.cafe, TimeContext.noon, WeatherContext.cloudy);
      state.completeWalk(
        Walk(
          stops: const [RouteStop(PlaceType.park)],
          time: TimeContext.noon,
          weather: WeatherContext.clear,
        ),
      );

      expect(state.claimWeeklyEvolution(), isNull);
      expect(state.weeklyCards, isEmpty);
    });

    test('premium toggle and reset behave', () async {
      final state = AppState();
      await state.init();
      state.hatch(PlaceType.park, TimeContext.noon, WeatherContext.clear);

      state.setPremium(true);
      expect(state.isPremium, isTrue);

      await state.resetGame();
      expect(state.hasHatched, isFalse);
      expect(state.memories, isEmpty);
      expect(state.isPremium, isFalse);
    });
  });
}
