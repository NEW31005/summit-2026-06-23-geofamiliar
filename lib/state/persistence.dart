import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/companion.dart';
import '../models/evolution.dart';
import '../models/life_dna.dart';
import '../models/map_familiar.dart';
import '../models/memory_card.dart';

/// A snapshot of everything we persist locally. Kept deliberately small and
/// JSON-friendly so it round-trips cleanly through shared_preferences.
class GameSnapshot {
  GameSnapshot({
    required this.companion,
    required this.memories,
    required this.weeklyCards,
    required this.weekDna,
    required this.familiars,
    required this.memoriesThisWeek,
    required this.isPremium,
    required this.premiumTeaserSeen,
  });

  final Companion companion;
  final List<MemoryCard> memories;
  final List<WeeklyCard> weeklyCards;
  final LifeDna weekDna;
  final List<MapFamiliar> familiars;
  final int memoriesThisWeek;
  final bool isPremium;
  final bool premiumTeaserSeen;

  Map<String, dynamic> toJson() => {
    'companion': companion.toJson(),
    'memories': memories.map((m) => m.toJson()).toList(),
    'weeklyCards': weeklyCards.map((c) => c.toJson()).toList(),
    'weekDna': weekDna.toJson(),
    'familiars': familiars.map((f) => f.toJson()).toList(),
    'memoriesThisWeek': memoriesThisWeek,
    'isPremium': isPremium,
    'premiumTeaserSeen': premiumTeaserSeen,
  };

  factory GameSnapshot.fromJson(Map<String, dynamic> json) => GameSnapshot(
    companion: Companion.fromJson(json['companion'] as Map<String, dynamic>),
    memories: (json['memories'] as List)
        .map((m) => MemoryCard.fromJson(m as Map<String, dynamic>))
        .toList(),
    weeklyCards: (json['weeklyCards'] as List)
        .map((c) => WeeklyCard.fromJson(c as Map<String, dynamic>))
        .toList(),
    weekDna: LifeDna.fromJson(json['weekDna'] as Map<String, dynamic>),
    familiars: ((json['familiars'] as List?) ?? const [])
        .map((f) => MapFamiliar.fromJson(f as Map<String, dynamic>))
        .toList(),
    memoriesThisWeek: json['memoriesThisWeek'] as int? ?? 0,
    isPremium: json['isPremium'] as bool? ?? false,
    premiumTeaserSeen: json['premiumTeaserSeen'] as bool? ?? false,
  );
}

/// Thin wrapper over shared_preferences. All persistence failures are swallowed
/// gracefully - the app must still run if storage is unavailable.
class Persistence {
  Persistence._();

  static const _key = 'geofamiliar.save.v2.ja';

  static Future<void> save(GameSnapshot snapshot) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, jsonEncode(snapshot.toJson()));
    } catch (_) {
      // Non-fatal: continue in-memory only.
    }
  }

  static Future<GameSnapshot?> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null || raw.isEmpty) return null;
      return GameSnapshot.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  static Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (_) {
      // ignore
    }
  }
}
