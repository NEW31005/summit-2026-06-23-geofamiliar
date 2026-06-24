import 'contexts.dart';
import 'place_context.dart';

enum MapSpotSource { mesh, confirmed }

class MapSpot {
  const MapSpot({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.place,
    required this.category,
    this.source = MapSpotSource.mesh,
    this.label,
    this.brandId,
  });

  final String id;
  final double latitude;
  final double longitude;
  final PlaceType place;
  final PlaceMeaningCategory category;
  final MapSpotSource source;
  final String? label;
  final String? brandId;

  bool get isConfirmed => source == MapSpotSource.confirmed;

  PlaceContext toPlaceContext() => PlaceContext.fromCategory(
    category,
    source: isConfirmed ? 'confirmed_spot' : 'mesh_spot',
  );
}
