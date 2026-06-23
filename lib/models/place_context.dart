import 'contexts.dart';

/// Coarse place meaning inferred from a location lookup.
///
/// This intentionally stores a category and a broad display hint, not an exact
/// address or precise coordinates. Exact coordinates only live during the
/// current read inside LocationRead.
enum PlaceMeaningCategory {
  residential('住宅街周辺', PlaceType.residential),
  commercial('商業地の近く', PlaceType.shopping),
  park('公園の近く', PlaceType.park),
  station('駅周辺', PlaceType.station),
  waterside('水辺の近く', PlaceType.river),
  greenery('緑地の近く', PlaceType.park),
  school('学校の近く', PlaceType.residential),
  medical('医療施設の近く', PlaceType.office),
  shrineTemple('神社・お寺の近く', PlaceType.travel),
  office('オフィス街周辺', PlaceType.office),
  cafe('カフェ周辺', PlaceType.cafe),
  convenience('夜のコンビニ周辺', PlaceType.nightStore),
  travel('旅先の近く', PlaceType.travel),
  other('いつもの場所', PlaceType.residential);

  const PlaceMeaningCategory(this.displayHint, this.place);

  final String displayHint;
  final PlaceType place;

  static PlaceMeaningCategory fromName(String? name) {
    return PlaceMeaningCategory.values.firstWhere(
      (category) => category.name == name,
      orElse: () => PlaceMeaningCategory.other,
    );
  }
}

class PlaceContext {
  const PlaceContext({
    required this.place,
    required this.category,
    required this.displayHint,
    required this.source,
    this.coarseLatitude,
    this.coarseLongitude,
  });

  final PlaceType place;
  final PlaceMeaningCategory category;
  final String displayHint;
  final String source;

  /// Rounded coordinates are transient evidence for the current read. They are
  /// deliberately omitted from persistence by [toJson].
  final double? coarseLatitude;
  final double? coarseLongitude;

  factory PlaceContext.manual(PlaceType place) {
    return PlaceContext(
      place: place,
      category: PlaceMeaningCategory.other,
      displayHint: place.label,
      source: 'manual',
    );
  }

  factory PlaceContext.fromCategory(
    PlaceMeaningCategory category, {
    String source = 'resolver',
    double? coarseLatitude,
    double? coarseLongitude,
  }) {
    return PlaceContext(
      place: category.place,
      category: category,
      displayHint: category.displayHint,
      source: source,
      coarseLatitude: coarseLatitude,
      coarseLongitude: coarseLongitude,
    );
  }

  Map<String, dynamic> toJson() => {
    'place': place.name,
    'category': category.name,
    'displayHint': displayHint,
    'source': source,
  };

  factory PlaceContext.fromJson(Map<String, dynamic> json) {
    final category = PlaceMeaningCategory.fromName(json['category'] as String?);
    final place = PlaceType.fromName(
      json['place'] as String? ?? category.place.name,
    );
    return PlaceContext(
      place: place,
      category: category,
      displayHint: json['displayHint'] as String? ?? category.displayHint,
      source: json['source'] as String? ?? 'saved',
    );
  }
}
