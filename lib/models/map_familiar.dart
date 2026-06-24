import 'contexts.dart';

class MapFamiliar {
  const MapFamiliar({
    required this.id,
    required this.spotId,
    required this.latitude,
    required this.longitude,
    required this.place,
    required this.acquiredAt,
    required this.visualSeed,
  });

  final String id;
  final String spotId;
  final double latitude;
  final double longitude;
  final PlaceType place;
  final DateTime acquiredAt;
  final int visualSeed;

  Map<String, dynamic> toJson() => {
    'id': id,
    'spotId': spotId,
    'latitude': latitude,
    'longitude': longitude,
    'place': place.name,
    'acquiredAt': acquiredAt.toIso8601String(),
    'visualSeed': visualSeed,
  };

  factory MapFamiliar.fromJson(Map<String, dynamic> json) => MapFamiliar(
    id: json['id'] as String,
    spotId: json['spotId'] as String,
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    place: PlaceType.fromName(json['place'] as String),
    acquiredAt:
        DateTime.tryParse(json['acquiredAt'] as String? ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0),
    visualSeed: json['visualSeed'] as int? ?? 1,
  );
}
