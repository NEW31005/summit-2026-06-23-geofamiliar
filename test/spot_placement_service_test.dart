import 'package:flutter_test/flutter_test.dart';
import 'package:geofamiliar/models/contexts.dart';
import 'package:geofamiliar/models/map_spot.dart';
import 'package:geofamiliar/models/place_context.dart';
import 'package:geofamiliar/services/spot_grid_service.dart';
import 'package:geofamiliar/services/spot_placement_service.dart';
import 'package:latlong2/latlong.dart';

void main() {
  group('SpotPlacementService', () {
    test('mixes confirmed places into the mesh around Tokyo Station', () {
      final spots = SpotPlacementService.generateAround(
        SpotGridService.defaultCenter,
      );
      final confirmed = spots.where((spot) => spot.isConfirmed).toList();

      expect(confirmed, isNotEmpty);
      expect(
        confirmed.map((spot) => spot.category),
        containsAll([
          PlaceMeaningCategory.station,
          PlaceMeaningCategory.park,
          PlaceMeaningCategory.waterside,
        ]),
      );
      expect(
        confirmed.map((spot) => spot.place),
        containsAll([PlaceType.station, PlaceType.park, PlaceType.river]),
      );
    });

    test('confirmed station wins entry detection over nearby mesh spots', () {
      final spots = SpotPlacementService.generateAround(
        SpotGridService.defaultCenter,
      );
      final entered = SpotGridService.enteredSpot(
        SpotGridService.defaultCenter,
        spots,
        <String>{},
      );

      expect(entered, isNotNull);
      expect(entered!.id, 'confirmed:tokyo-station');
      expect(entered.category, PlaceMeaningCategory.station);
      expect(entered.place, PlaceType.station);
    });

    test('brandId can be attached without changing capture semantics', () {
      const sponsored = MapSpot(
        id: 'confirmed:sample-brand-spot',
        latitude: 35.0,
        longitude: 139.0,
        place: PlaceType.nightStore,
        category: PlaceMeaningCategory.convenience,
        source: MapSpotSource.confirmed,
        brandId: 'sample-brand',
      );

      expect(sponsored.isConfirmed, isTrue);
      expect(sponsored.brandId, 'sample-brand');
      expect(sponsored.toPlaceContext().place, PlaceType.nightStore);
      expect(
        sponsored.toPlaceContext().category,
        PlaceMeaningCategory.convenience,
      );
    });

    test('falls back to pure mesh away from the confirmed catalog', () {
      final spots = SpotPlacementService.generateAround(
        const LatLng(34.6937, 135.5023),
      );

      expect(spots.length, 25);
      expect(spots.any((spot) => spot.isConfirmed), isFalse);
    });
  });
}
