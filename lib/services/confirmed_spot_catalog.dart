import 'package:latlong2/latlong.dart';

import '../models/contexts.dart';
import '../models/map_spot.dart';
import '../models/place_context.dart';
import 'spot_grid_service.dart';

class ConfirmedSpotCatalog {
  const ConfirmedSpotCatalog._();

  static const activationRadiusMeters = 2400.0;

  static const _tokyoStationArea = [
    MapSpot(
      id: 'confirmed:tokyo-station',
      latitude: 35.681236,
      longitude: 139.767125,
      place: PlaceType.station,
      category: PlaceMeaningCategory.station,
      source: MapSpotSource.confirmed,
      label: 'Tokyo Station',
    ),
    MapSpot(
      id: 'confirmed:wadakura-fountain-park',
      latitude: 35.684949,
      longitude: 139.761962,
      place: PlaceType.park,
      category: PlaceMeaningCategory.park,
      source: MapSpotSource.confirmed,
      label: 'Wadakura Fountain Park',
    ),
    MapSpot(
      id: 'confirmed:imperial-moat',
      latitude: 35.68564,
      longitude: 139.760371,
      place: PlaceType.river,
      category: PlaceMeaningCategory.waterside,
      source: MapSpotSource.confirmed,
      label: 'Imperial Palace Moat',
    ),
    MapSpot(
      id: 'confirmed:marunouchi-office',
      latitude: 35.680521,
      longitude: 139.764731,
      place: PlaceType.office,
      category: PlaceMeaningCategory.office,
      source: MapSpotSource.confirmed,
      label: 'Marunouchi Office District',
    ),
    MapSpot(
      id: 'confirmed:yaesu-convenience',
      latitude: 35.680065,
      longitude: 139.769646,
      place: PlaceType.nightStore,
      category: PlaceMeaningCategory.convenience,
      source: MapSpotSource.confirmed,
      label: 'Yaesu Convenience Cluster',
    ),
  ];

  static List<MapSpot> around(LatLng center) {
    return _tokyoStationArea
        .where(
          (spot) =>
              SpotGridService.distanceMeters(
                center,
                LatLng(spot.latitude, spot.longitude),
              ) <=
              activationRadiusMeters,
        )
        .toList(growable: false);
  }
}
