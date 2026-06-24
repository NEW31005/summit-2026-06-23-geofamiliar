import 'package:flutter_test/flutter_test.dart';
import 'package:geofamiliar/models/contexts.dart';
import 'package:geofamiliar/models/place_context.dart';
import 'package:geofamiliar/services/demo_walk_route.dart';
import 'package:geofamiliar/services/spot_grid_service.dart';
import 'package:geofamiliar/services/spot_placement_service.dart';

void main() {
  group('DemoWalkRoute', () {
    test('walks through visible confirmed place types without tapping', () {
      final route = DemoWalkRoute.tokyoStationLoop();
      final spots = SpotPlacementService.generateAround(
        SpotGridService.defaultCenter,
      );
      final entered = <PlaceMeaningCategory>{};

      for (final point in route) {
        final spot = SpotGridService.enteredSpot(point, spots, <String>{});
        if (spot != null) entered.add(spot.category);
      }

      expect(route.length, greaterThanOrEqualTo(20));
      expect(
        entered,
        containsAll([
          PlaceMeaningCategory.station,
          PlaceMeaningCategory.park,
          PlaceMeaningCategory.waterside,
        ]),
      );
      expect(
        entered.map((category) => category.place),
        containsAll([PlaceType.station, PlaceType.park, PlaceType.river]),
      );
    });
  });
}
