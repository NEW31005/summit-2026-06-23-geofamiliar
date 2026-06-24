import 'package:latlong2/latlong.dart';

import '../models/map_spot.dart';
import 'confirmed_spot_catalog.dart';
import 'spot_grid_service.dart';

class SpotPlacementService {
  const SpotPlacementService._();

  static const confirmedSpotClearanceMeters = 120.0;

  static List<MapSpot> generateAround(LatLng center, {int radiusCells = 2}) {
    final confirmed = ConfirmedSpotCatalog.around(center);
    final mesh = SpotGridService.generateAround(
      center,
      radiusCells: radiusCells,
    );
    if (confirmed.isEmpty) return mesh;

    final filteredMesh = mesh
        .where(
          (meshSpot) => confirmed.every(
            (fixedSpot) =>
                SpotGridService.distanceMeters(
                  LatLng(meshSpot.latitude, meshSpot.longitude),
                  LatLng(fixedSpot.latitude, fixedSpot.longitude),
                ) >
                confirmedSpotClearanceMeters,
          ),
        )
        .toList(growable: false);

    return [...confirmed, ...filteredMesh];
  }
}
