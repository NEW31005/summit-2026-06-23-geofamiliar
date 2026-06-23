import '../models/contexts.dart';
import '../models/dna_trait.dart';
import '../models/life_dna.dart';
import '../models/walk.dart';
import 'dna_engine.dart';

/// A gentle, optional suggestion for rounding out a companion's Life DNA.
///
/// Suggestions are framed as "only if it is already on your way" - they never
/// push the user toward a specific distance, speed, time of day, or risky place.
class WalkSuggestion {
  const WalkSuggestion({
    required this.weakest,
    required this.place,
    required this.message,
  });

  final DnaTrait weakest;
  final PlaceType place;
  final String message;
}

/// Pure helpers that describe a walk's likely effect and suggest balance.
/// No Flutter, no I/O - unit testable.
class WalkAdvisor {
  const WalkAdvisor();

  /// The trait the companion currently has the least of.
  static DnaTrait weakestTrait(LifeDna dna) {
    DnaTrait weak = DnaTrait.values.first;
    for (final t in DnaTrait.values) {
      if (dna.of(t) < dna.of(weak)) weak = t;
    }
    return weak;
  }

  /// The place type that most strongly grows [trait].
  static PlaceType placeForTrait(DnaTrait trait) {
    PlaceType best = PlaceType.values.first;
    double bestScore = -1;
    for (final p in PlaceType.values) {
      final score = p.dna[trait] ?? 0;
      if (score > bestScore) {
        bestScore = score;
        best = p;
      }
    }
    return best;
  }

  /// A gentle, never-pushy suggestion to balance the companion's DNA.
  static WalkSuggestion gentleSuggestion(LifeDna dna) {
    final weak = weakestTrait(dna);
    final place = placeForTrait(weak);
    final message =
        '${weak.label}が少なめです。もし今日のついでに寄れそうなら、'
        '${place.label}を通ると相棒のバランスが少し整います。';
    return WalkSuggestion(weakest: weak, place: place, message: message);
  }

  /// A short forecast of how a planned walk will make the companion feel.
  /// Returns null for an empty route.
  static String? moodForecast(Walk walk) {
    if (walk.isEmpty) return null;
    final lead = walk.lead;
    final mood = DnaEngine.moodForTrait(lead);
    return 'このさんぽは「${lead.label}」寄りです。相棒は$mood気分になります。';
  }
}
