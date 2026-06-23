import 'package:flutter/material.dart';

/// The six core axes of a companion's Life DNA.
///
/// Every place, time-of-day and weather context the user moves through nudges
/// one or more of these axes. The blend of axes is what gives a companion its
/// personality, mood and eventual evolution - "this companion could only come
/// from my life".
enum DnaTrait {
  vitality(
    label: '活力',
    short: '活',
    blurb: '駅、通勤路、明るい朝から集まる勢い。',
    icon: Icons.bolt_rounded,
    color: Color(0xFFFF8A65), // coral
  ),
  calm(
    label: '静けさ',
    short: '静',
    blurb: '川沿い、公園、家の近くから集まる落ち着き。',
    icon: Icons.spa_rounded,
    color: Color(0xFF4DD0B1), // mint
  ),
  curiosity(
    label: '好奇心',
    short: '好',
    blurb: '商店街、知らない角、旅先から集まる発見。',
    icon: Icons.travel_explore_rounded,
    color: Color(0xFFFFC04D), // amber
  ),
  warmth(
    label: 'ぬくもり',
    short: '温',
    blurb: 'カフェ、住宅街、夕方の光から集まる安心。',
    icon: Icons.favorite_rounded,
    color: Color(0xFFFF6F91), // rose-coral
  ),
  focus(
    label: '集中',
    short: '集',
    blurb: 'オフィス街、駅、昼の用事から集まる冴え。',
    icon: Icons.center_focus_strong_rounded,
    color: Color(0xFF5C9DFF), // soft blue accent
  ),
  wonder(
    label: '不思議',
    short: '夢',
    blurb: '夕暮れ、夜の明かり、雨の窓から集まる余韻。',
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

  static DnaTrait fromName(String name) => DnaTrait.values.firstWhere(
    (t) => t.name == name,
    orElse: () => DnaTrait.calm,
  );
}
