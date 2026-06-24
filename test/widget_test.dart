import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geofamiliar/app.dart';
import 'package:geofamiliar/models/contexts.dart';
import 'package:geofamiliar/models/map_spot.dart';
import 'package:geofamiliar/models/place_context.dart';
import 'package:geofamiliar/models/walk.dart';
import 'package:geofamiliar/state/app_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('fresh launch opens directly on the map loop', (tester) async {
    final state = AppState();
    await state.init();
    await tester.pumpWidget(GeoFamiliarApp(state: state, showMapTiles: false));
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.byKey(const ValueKey('geo-map-screen')), findsOneWidget);
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

    test('collecting a map spot hatches and records a familiar', () async {
      final state = AppState();
      await state.init();

      final familiar = state.collectSpot(
        const MapSpot(
          id: 'test:station',
          latitude: 35.681236,
          longitude: 139.767125,
          place: PlaceType.station,
          category: PlaceMeaningCategory.station,
        ),
        time: TimeContext.morning,
      );

      expect(familiar, isNotNull);
      expect(state.hasHatched, isTrue);
      expect(state.familiars.length, 1);
      expect(state.capturedSpotIds, contains('test:station'));
      expect(state.memories.length, 1);
    });

    test('collecting the same map spot twice does not duplicate', () async {
      final state = AppState();
      await state.init();
      const spot = MapSpot(
        id: 'test:park',
        latitude: 35.681236,
        longitude: 139.767125,
        place: PlaceType.park,
        category: PlaceMeaningCategory.park,
      );

      expect(state.collectSpot(spot), isNotNull);
      expect(state.collectSpot(spot), isNull);

      expect(state.familiars.length, 1);
      expect(state.memories.length, 1);
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
      expect(state.memories.length, 6);
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
      expect(state.familiars, isEmpty);
      expect(state.memories, isEmpty);
      expect(state.isPremium, isFalse);
    });

    test('premium demo entitlement flow purchase restore and cancel', () async {
      final state = AppState();
      await state.init();

      final purchase = await state.purchasePremiumDemo();
      expect(purchase.isActive, isTrue);
      expect(state.isPremium, isTrue);

      final cancel = await state.cancelPremiumDemo();
      expect(cancel.isActive, isFalse);
      expect(state.isPremium, isFalse);

      final restore = await state.restorePremiumDemo();
      expect(restore.isActive, isTrue);
      expect(state.isPremium, isTrue);
    });
  });
}
