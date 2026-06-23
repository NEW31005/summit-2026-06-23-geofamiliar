import '../logic/dna_engine.dart';
import '../logic/evolution_engine.dart';
import 'contexts.dart';
import 'evolution.dart';
import 'life_dna.dart';

/// The companion itself - the single creature the user grows. A plain data
/// holder; all derived qualities (stage, personality, form) come from the pure
/// engines so they stay consistent and testable.
class Companion {
  Companion({
    required this.id,
    required this.name,
    required this.generation,
    required this.visualSeed,
    required this.dna,
    required this.totalWalks,
    required this.walksThisWeek,
    required this.week,
    required this.hatched,
    this.lastPlace,
    this.lastTime,
    this.lastWeather,
    this.inheritedFrom,
  });

  String id;
  String name;
  int generation;
  int visualSeed;
  LifeDna dna;
  int totalWalks;
  int walksThisWeek;
  int week;
  bool hatched;
  PlaceType? lastPlace;
  TimeContext? lastTime;
  WeatherContext? lastWeather;

  /// Name of the companion this one inherited from (inheritance teaser).
  String? inheritedFrom;

  /// A brand-new, pre-hatch egg.
  factory Companion.egg() => Companion(
    id: 'companion-1',
    name: 'たまご',
    generation: 1,
    visualSeed: 1,
    dna: LifeDna.empty(),
    totalWalks: 0,
    walksThisWeek: 0,
    week: 1,
    hatched: false,
  );

  EvolutionStage get stage =>
      hatched ? EvolutionEngine.stageFor(totalWalks) : EvolutionStage.egg;

  Personality get personality => DnaEngine.personality(dna);

  String get formName => DnaEngine.formName(dna.dominant);

  String get moodLabel {
    if (!hatched) return '待っている';
    if (lastPlace != null && lastTime != null && lastWeather != null) {
      return DnaEngine.moodFor(lastPlace!, lastTime!, lastWeather!);
    }
    return 'ごきげん';
  }

  double get weeklyProgress => EvolutionEngine.weeklyProgress(walksThisWeek);

  bool get weekReady => EvolutionEngine.weekReady(walksThisWeek);

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'generation': generation,
    'visualSeed': visualSeed,
    'dna': dna.toJson(),
    'totalWalks': totalWalks,
    'walksThisWeek': walksThisWeek,
    'week': week,
    'hatched': hatched,
    'lastPlace': lastPlace?.name,
    'lastTime': lastTime?.name,
    'lastWeather': lastWeather?.name,
    'inheritedFrom': inheritedFrom,
  };

  factory Companion.fromJson(Map<String, dynamic> json) => Companion(
    id: json['id'] as String,
    name: json['name'] as String,
    generation: json['generation'] as int,
    visualSeed: json['visualSeed'] as int,
    dna: LifeDna.fromJson(json['dna'] as Map<String, dynamic>),
    totalWalks: json['totalWalks'] as int,
    walksThisWeek: json['walksThisWeek'] as int,
    week: json['week'] as int,
    hatched: json['hatched'] as bool,
    lastPlace: json['lastPlace'] == null
        ? null
        : PlaceType.fromName(json['lastPlace'] as String),
    lastTime: json['lastTime'] == null
        ? null
        : TimeContext.fromName(json['lastTime'] as String),
    lastWeather: json['lastWeather'] == null
        ? null
        : WeatherContext.fromName(json['lastWeather'] as String),
    inheritedFrom: json['inheritedFrom'] as String?,
  );
}
