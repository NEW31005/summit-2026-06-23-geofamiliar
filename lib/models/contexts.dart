import 'package:flutter/material.dart';

import 'dna_trait.dart';

/// A place the user can move through. Each place type seeds the companion's
/// Life DNA with a small, curated blend of trait points.
enum PlaceType {
  station(
    label: 'Station',
    icon: Icons.directions_transit_rounded,
    tagline: 'Crowd energy, departures, momentum.',
    dna: {DnaTrait.vitality: 2.0, DnaTrait.focus: 1.0},
  ),
  park(
    label: 'Park',
    icon: Icons.park_rounded,
    tagline: 'Open grass, slow breath, sunlight.',
    dna: {DnaTrait.calm: 2.0, DnaTrait.warmth: 1.0},
  ),
  office(
    label: 'Office district',
    icon: Icons.business_rounded,
    tagline: 'Glass towers, deadlines, sharp focus.',
    dna: {DnaTrait.focus: 2.0, DnaTrait.vitality: 1.0},
  ),
  river(
    label: 'Riverside',
    icon: Icons.water_rounded,
    tagline: 'Flowing water, long horizon, calm.',
    dna: {DnaTrait.calm: 2.0, DnaTrait.wonder: 1.0},
  ),
  cafe(
    label: 'Cafe',
    icon: Icons.local_cafe_rounded,
    tagline: 'Warm cups, soft chatter, a pause.',
    dna: {DnaTrait.warmth: 2.0, DnaTrait.calm: 1.0},
  ),
  residential(
    label: 'Home area',
    icon: Icons.home_rounded,
    tagline: 'Familiar streets, home, belonging.',
    dna: {DnaTrait.warmth: 2.0, DnaTrait.focus: 1.0},
  ),
  shopping(
    label: 'Shopping street',
    icon: Icons.storefront_rounded,
    tagline: 'Bright signs, new finds, buzz.',
    dna: {DnaTrait.curiosity: 2.0, DnaTrait.vitality: 1.0},
  ),
  nightStore(
    label: 'Night store',
    icon: Icons.local_convenience_store_rounded,
    tagline: 'Late lights, quiet aisles, small wonder.',
    dna: {DnaTrait.wonder: 2.0, DnaTrait.curiosity: 1.0},
  ),
  travel(
    label: 'Travel spot',
    icon: Icons.luggage_rounded,
    tagline: 'Somewhere new, wide eyes, a story.',
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
    label: 'Morning rush',
    icon: Icons.wb_twilight_rounded,
    boost: {DnaTrait.vitality: 1.0},
  ),
  noon(
    label: 'Midday',
    icon: Icons.light_mode_rounded,
    boost: {DnaTrait.focus: 1.0},
  ),
  sunset(
    label: 'Sunset',
    icon: Icons.brightness_4_rounded,
    boost: {DnaTrait.warmth: 1.0},
  ),
  night(
    label: 'Night',
    icon: Icons.dark_mode_rounded,
    boost: {DnaTrait.wonder: 1.0},
  ),
  rainyEvening(
    label: 'Rainy evening',
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
    label: 'Clear',
    icon: Icons.wb_sunny_rounded,
    boost: {DnaTrait.vitality: 0.5},
  ),
  rain(
    label: 'Rain',
    icon: Icons.water_drop_rounded,
    boost: {DnaTrait.calm: 0.5},
  ),
  cloudy(
    label: 'Cloudy',
    icon: Icons.cloud_rounded,
    boost: {DnaTrait.focus: 0.5},
  ),
  humid(
    label: 'Humid',
    icon: Icons.blur_on_rounded,
    boost: {DnaTrait.warmth: 0.5},
  ),
  windy(
    label: 'Windy',
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
