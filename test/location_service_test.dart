import 'package:flutter_test/flutter_test.dart';
import 'package:geofamiliar/models/contexts.dart';
import 'package:geofamiliar/services/location_service.dart';

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
}
