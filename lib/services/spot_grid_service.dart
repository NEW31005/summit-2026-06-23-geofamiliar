import 'dart:math' as math;

import 'package:latlong2/latlong.dart';

import '../models/contexts.dart';
import '../models/map_spot.dart';

class SpotGridService {
  const SpotGridService._();

  static const defaultCenter = LatLng(35.681236, 139.767125);
  static const cellSizeDegrees = 0.0011;
  static const captureRadiusMeters = 85.0;

  static List<MapSpot> generateAround(LatLng center, {int radiusCells = 2}) {
    final baseLatCell = _cellIndex(center.latitude);
    final baseLonCell = _cellIndex(center.longitude);
    final spots = <MapSpot>[];

    for (var latOffset = -radiusCells; latOffset <= radiusCells; latOffset++) {
      for (
        var lonOffset = -radiusCells;
        lonOffset <= radiusCells;
        lonOffset++
      ) {
        final latCell = baseLatCell + latOffset;
        final lonCell = baseLonCell + lonOffset;
        spots.add(
          MapSpot(
            id: '$latCell:$lonCell',
            latitude: _cellCenter(latCell),
            longitude: _cellCenter(lonCell),
            place: _placeForCell(latCell, lonCell),
          ),
        );
      }
    }

    return spots;
  }

  static MapSpot? enteredSpot(
    LatLng current,
    Iterable<MapSpot> spots,
    Set<String> capturedSpotIds, {
    double radiusMeters = captureRadiusMeters,
  }) {
    MapSpot? nearest;
    var nearestMeters = double.infinity;
    const distance = Distance();

    for (final spot in spots) {
      if (capturedSpotIds.contains(spot.id)) continue;
      final meters = distance.as(
        LengthUnit.Meter,
        current,
        LatLng(spot.latitude, spot.longitude),
      );
      if (meters < nearestMeters) {
        nearestMeters = meters;
        nearest = spot;
      }
    }

    if (nearest != null && nearestMeters <= radiusMeters) return nearest;
    return null;
  }

  static int _cellIndex(double value) => (value / cellSizeDegrees).floor();

  static double _cellCenter(int index) => (index + 0.5) * cellSizeDegrees;

  static PlaceType _placeForCell(int latCell, int lonCell) {
    final hash = (latCell * 73856093) ^ (lonCell * 19349663);
    final places = const [
      PlaceType.station,
      PlaceType.park,
      PlaceType.river,
      PlaceType.cafe,
      PlaceType.shopping,
      PlaceType.residential,
      PlaceType.office,
      PlaceType.nightStore,
      PlaceType.travel,
    ];
    return places[hash.abs() % places.length];
  }

  static double distanceMeters(LatLng a, LatLng b) {
    return const Distance().as(LengthUnit.Meter, a, b);
  }

  static LatLng nudge(LatLng point, double metersNorth, double metersEast) {
    final latMeters = metersNorth / 111320.0;
    final lonMeters =
        metersEast /
        (111320.0 * math.cos(point.latitude * math.pi / 180).abs());
    return LatLng(point.latitude + latMeters, point.longitude + lonMeters);
  }
}
