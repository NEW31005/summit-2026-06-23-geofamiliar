import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:geofamiliar/models/contexts.dart';
import 'package:geofamiliar/models/place_context.dart';
import 'package:geofamiliar/services/location_service.dart';
import 'package:geofamiliar/services/place_resolver.dart';

void main() {
  group('LocationHeuristics', () {
    test('maps hours to Japanese time contexts', () {
      expect(LocationHeuristics.timeFromHour(6), TimeContext.morning);
      expect(LocationHeuristics.timeFromHour(12), TimeContext.noon);
      expect(LocationHeuristics.timeFromHour(17), TimeContext.sunset);
      expect(LocationHeuristics.timeFromHour(23), TimeContext.night);
    });

    test('maps coordinates to a stable place category', () {
      final a = LocationHeuristics.placeFromCoordinates(35.6812, 139.7671);
      final b = LocationHeuristics.placeFromCoordinates(35.6812, 139.7671);

      expect(a, b);
      expect(PlaceType.values, contains(a));
    });
  });

  group('PlaceResolver', () {
    test(
      'maps reverse geocode station evidence to a broad place context',
      () async {
        final resolver = PlaceResolver(
          client: MockClient((request) async {
            return http.Response.bytes(
              utf8.encode(
                jsonEncode({
                  'category': 'railway',
                  'type': 'station',
                  'address': {'railway': 'Tokyo Station'},
                }),
              ),
              200,
            );
          }),
        );

        final context = await resolver.resolve(35.6812, 139.7671);

        expect(context.category, PlaceMeaningCategory.station);
        expect(context.place, PlaceType.station);
        expect(context.displayHint, '駅周辺');
        expect(context.toJson().containsKey('coarseLatitude'), isFalse);
      },
    );

    test('falls back to a stable offline category when lookup fails', () async {
      final resolver = PlaceResolver(
        client: MockClient((request) async => http.Response('nope', 503)),
      );

      final context = await resolver.resolve(35.1234, 139.9876);

      expect(context.source, 'offline');
      expect(PlaceType.values, contains(context.place));
      expect(context.displayHint, isNotEmpty);
    });
  });
}
