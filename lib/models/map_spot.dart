import 'contexts.dart';

class MapSpot {
  const MapSpot({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.place,
  });

  final String id;
  final double latitude;
  final double longitude;
  final PlaceType place;
}
