import 'package:flutter/material.dart';

/// The six core axes of a companion's Life DNA.
///
/// Every place, time-of-day and weather context the user moves through nudges
/// one or more of these axes. The blend of axes is what gives a companion its
/// personality, mood and eventual evolution - "this companion could only come
/// from my life".
enum DnaTrait {
  vitality(
    label: 'Vitality',
    short: 'VIT',
    blurb: 'Energy from busy streets, commutes and bright mornings.',
    icon: Icons.bolt_rounded,
    color: Color(0xFFFF8A65), // coral
  ),
  calm(
    label: 'Calm',
    short: 'CAL',
    blurb: 'Stillness gathered by rivers, parks and quiet homes.',
    icon: Icons.spa_rounded,
    color: Color(0xFF4DD0B1), // mint
  ),
  curiosity(
    label: 'Curiosity',
    short: 'CUR',
    blurb: 'Wonder picked up in shops, new corners and travel.',
    icon: Icons.travel_explore_rounded,
    color: Color(0xFFFFC04D), // amber
  ),
  warmth(
    label: 'Warmth',
    short: 'WRM',
    blurb: 'Comfort from cafes, neighbourhoods and golden light.',
    icon: Icons.favorite_rounded,
    color: Color(0xFFFF6F91), // rose-coral
  ),
  focus(
    label: 'Focus',
    short: 'FOC',
    blurb: 'Clarity built in offices, stations and midday routines.',
    icon: Icons.center_focus_strong_rounded,
    color: Color(0xFF5C9DFF), // soft blue accent
  ),
  wonder(
    label: 'Wonder',
    short: 'WND',
    blurb: 'Quiet magic from dusk, night lights and rainy glass.',
    icon: Icons.auto_awesome_rounded,
    color: Color(0xFFB388FF), // gentle violet accent
  );

  const DnaTrait({
    required this.label,
    required this.short,
    required this.blurb,
    required this.icon,
    required this.color,
  });

  final String label;
  final String short;
  final String blurb;
  final IconData icon;
  final Color color;

  static DnaTrait fromName(String name) =>
      DnaTrait.values.firstWhere((t) => t.name == name, orElse: () => DnaTrait.calm);
}
