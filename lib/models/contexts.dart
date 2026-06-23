import 'package:flutter/material.dart';

import 'dna_trait.dart';

/// A place the user can move through. Each place type seeds the companion's
/// Life DNA with a small, curated blend of trait points.
enum PlaceType {
  station(
    label: '駅',
    icon: Icons.directions_transit_rounded,
    tagline: '人の流れ、出発の気配、朝の勢い。',
    dna: {DnaTrait.vitality: 2.0, DnaTrait.focus: 1.0},
  ),
  park(
    label: '公園',
    icon: Icons.park_rounded,
    tagline: 'ひらけた緑、深呼吸、やわらかな光。',
    dna: {DnaTrait.calm: 2.0, DnaTrait.warmth: 1.0},
  ),
  office(
    label: 'オフィス街',
    icon: Icons.business_rounded,
    tagline: 'ビルの輪郭、予定、頭が冴える場所。',
    dna: {DnaTrait.focus: 2.0, DnaTrait.vitality: 1.0},
  ),
  river(
    label: '川沿い',
    icon: Icons.water_rounded,
    tagline: '流れる水、遠くまで抜ける視界、静けさ。',
    dna: {DnaTrait.calm: 2.0, DnaTrait.wonder: 1.0},
  ),
  cafe(
    label: 'カフェ',
    icon: Icons.local_cafe_rounded,
    tagline: 'あたたかい飲み物、会話、ひと休み。',
    dna: {DnaTrait.warmth: 2.0, DnaTrait.calm: 1.0},
  ),
  residential(
    label: '住宅街',
    icon: Icons.home_rounded,
    tagline: '見慣れた道、帰る場所、安心感。',
    dna: {DnaTrait.warmth: 2.0, DnaTrait.focus: 1.0},
  ),
  shopping(
    label: '商店街',
    icon: Icons.storefront_rounded,
    tagline: '看板、発見、人のにぎわい。',
    dna: {DnaTrait.curiosity: 2.0, DnaTrait.vitality: 1.0},
  ),
  nightStore(
    label: '夜のコンビニ',
    icon: Icons.local_convenience_store_rounded,
    tagline: '夜の明かり、静かな棚、小さな不思議。',
    dna: {DnaTrait.wonder: 2.0, DnaTrait.curiosity: 1.0},
  ),
  travel(
    label: '旅先',
    icon: Icons.luggage_rounded,
    tagline: '知らない場所、見開く目、あとで話したい出来事。',
    dna: {DnaTrait.curiosity: 2.0, DnaTrait.wonder: 1.0},
  );

  const PlaceType({
    required this.label,
    required this.icon,
    required this.tagline,
    required this.dna,
  });

  final String label;
  final IconData icon;
  final String tagline;
  final Map<DnaTrait, double> dna;

  static PlaceType fromName(String name) => PlaceType.values.firstWhere(
    (p) => p.name == name,
    orElse: () => PlaceType.park,
  );
}

/// Time-of-day context. Acts as a gentle multiplier/booster on the place DNA.
enum TimeContext {
  morning(
    label: '朝',
    icon: Icons.wb_twilight_rounded,
    boost: {DnaTrait.vitality: 1.0},
  ),
  noon(
    label: '昼',
    icon: Icons.light_mode_rounded,
    boost: {DnaTrait.focus: 1.0},
  ),
  sunset(
    label: '夕方',
    icon: Icons.brightness_4_rounded,
    boost: {DnaTrait.warmth: 1.0},
  ),
  night(
    label: '夜',
    icon: Icons.dark_mode_rounded,
    boost: {DnaTrait.wonder: 1.0},
  ),
  rainyEvening(
    label: '雨の夕方',
    icon: Icons.umbrella_rounded,
    boost: {DnaTrait.calm: 1.0},
  );

  const TimeContext({
    required this.label,
    required this.icon,
    required this.boost,
  });

  final String label;
  final IconData icon;
  final Map<DnaTrait, double> boost;

  static TimeContext fromName(String name) => TimeContext.values.firstWhere(
    (t) => t.name == name,
    orElse: () => TimeContext.noon,
  );
}

/// Weather context. Adds a faint tint to the day's DNA.
enum WeatherContext {
  clear(
    label: '晴れ',
    icon: Icons.wb_sunny_rounded,
    boost: {DnaTrait.vitality: 0.5},
  ),
  rain(label: '雨', icon: Icons.water_drop_rounded, boost: {DnaTrait.calm: 0.5}),
  cloudy(label: 'くもり', icon: Icons.cloud_rounded, boost: {DnaTrait.focus: 0.5}),
  humid(
    label: '蒸し暑い',
    icon: Icons.blur_on_rounded,
    boost: {DnaTrait.warmth: 0.5},
  ),
  windy(
    label: '風が強い',
    icon: Icons.air_rounded,
    boost: {DnaTrait.curiosity: 0.5},
  );

  const WeatherContext({
    required this.label,
    required this.icon,
    required this.boost,
  });

  final String label;
  final IconData icon;
  final Map<DnaTrait, double> boost;

  static WeatherContext fromName(String name) => WeatherContext.values
      .firstWhere((w) => w.name == name, orElse: () => WeatherContext.clear);
}
