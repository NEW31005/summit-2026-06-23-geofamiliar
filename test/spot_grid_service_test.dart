import 'package:flutter_test/flutter_test.dart';
import 'package:geofamiliar/services/spot_grid_service.dart';
import 'package:latlong2/latlong.dart';

void main() {
  group('SpotGridService', () {
    test('generates stable spots around the current cell', () {
      final spots = SpotGridService.generateAround(
        SpotGridService.defaultCenter,
      );
      final again = SpotGridService.generateAround(
        SpotGridService.defaultCenter,
      );

      expect(spots.length, 25);
      expect(spots.map((spot) => spot.id), again.map((spot) => spot.id));
    });

    test('detects entry without requiring a tap on the spot', () {
      final spots = SpotGridService.generateAround(
        SpotGridService.defaultCenter,
      );
      final entered = SpotGridService.enteredSpot(
        SpotGridService.defaultCenter,
        spots,
        <String>{},
      );

      expect(entered, isNotNull);
    });

    test('ignores already captured spots', () {
      final spots = SpotGridService.generateAround(
        SpotGridService.defaultCenter,
      );
      final entered = SpotGridService.enteredSpot(
        SpotGridService.defaultCenter,
        spots,
        <String>{},
      );
      final second = SpotGridService.enteredSpot(
        LatLng(entered!.latitude, entered.longitude),
        spots,
        {entered.id},
      );

      expect(second?.id, isNot(entered.id));
    });
  });
}
