import 'contexts.dart';
import 'dna_trait.dart';
import 'life_dna.dart';
import '../logic/dna_engine.dart';

/// One stop on a walk - a single place visited under the day's time/weather.
class RouteStop {
  const RouteStop(this.place);

  final PlaceType place;

  Map<String, dynamic> toJson() => {'place': place.name};

  factory RouteStop.fromJson(Map<String, dynamic> json) =>
      RouteStop(PlaceType.fromName(json['place'] as String));
}

/// A simulated walk: an ordered route of stops under a shared time + weather.
///
/// The walk's Life DNA is the sum of every stop's context DNA. Walking is the
/// game's only input - this is where movement becomes growth.
class Walk {
  Walk({
    required this.stops,
    required this.time,
    required this.weather,
  });

  final List<RouteStop> stops;
  final TimeContext time;
  final WeatherContext weather;

  bool get isEmpty => stops.isEmpty;
  int get length => stops.length;

  /// Aggregate Life DNA contributed by the whole walk.
  LifeDna get dna {
    var dna = LifeDna.empty();
    for (final stop in stops) {
      dna = dna.add(DnaEngine.contextDna(stop.place, time, weather));
    }
    return dna;
  }

  /// The trait this walk pushed hardest - drives the memory it creates.
  DnaTrait get lead => dna.dominant;

  /// A short distance-style label. We never reward speed or risky distance, so
  /// this is a gentle, flavour-only figure derived from the number of stops.
  String get strollLabel {
    final approxMinutes = stops.length * 8;
    return '$approxMinutes min stroll';
  }
}
