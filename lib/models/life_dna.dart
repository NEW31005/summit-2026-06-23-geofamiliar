import 'dart:math' as math;

import 'dna_trait.dart';

/// An accumulated blend of Life DNA trait points.
///
/// This is an immutable value object: combining DNA returns a new [LifeDna].
/// It is the heart of GeoFamiliar - the running total of every place, time and
/// weather context the companion has lived through.
class LifeDna {
  const LifeDna(this.totals);

  final Map<DnaTrait, double> totals;

  factory LifeDna.empty() =>
      LifeDna({for (final t in DnaTrait.values) t: 0.0});

  /// Build from a single context blend (place + time + weather already merged).
  factory LifeDna.from(Map<DnaTrait, double> points) {
    final map = {for (final t in DnaTrait.values) t: 0.0};
    points.forEach((trait, value) => map[trait] = (map[trait] ?? 0) + value);
    return LifeDna(map);
  }

  double of(DnaTrait trait) => totals[trait] ?? 0.0;

  double get sum => totals.values.fold(0.0, (a, b) => a + b);

  /// Returns a copy with [other]'s points added on top.
  LifeDna combine(LifeDna other) {
    final map = {for (final t in DnaTrait.values) t: of(t) + other.of(t)};
    return LifeDna(map);
  }

  /// Returns a copy with a raw point map added on top.
  LifeDna add(Map<DnaTrait, double> points) => combine(LifeDna.from(points));

  /// The strongest trait. Ties resolve by enum order for determinism.
  DnaTrait get dominant {
    DnaTrait best = DnaTrait.values.first;
    for (final t in DnaTrait.values) {
      if (of(t) > of(best)) best = t;
    }
    return best;
  }

  /// The second-strongest trait, never equal to [dominant].
  DnaTrait get secondary {
    final dom = dominant;
    DnaTrait? best;
    for (final t in DnaTrait.values) {
      if (t == dom) continue;
      if (best == null || of(t) > of(best)) best = t;
    }
    return best ?? dom;
  }

  /// Traits sorted strongest-first.
  List<DnaTrait> get ranked {
    final list = [...DnaTrait.values];
    list.sort((a, b) => of(b).compareTo(of(a)));
    return list;
  }

  /// A 0..1 share of the total for a trait (for bars / wheels).
  double share(DnaTrait trait) {
    final s = sum;
    if (s <= 0) return 0;
    return of(trait) / s;
  }

  /// A 0..1 strength of a trait relative to the strongest one (for bar fills).
  double relative(DnaTrait trait) {
    final top = of(dominant);
    if (top <= 0) return 0;
    return (of(trait) / top).clamp(0.0, 1.0);
  }

  /// "Balance" of the DNA - 1.0 means evenly spread, 0.0 means one-note.
  /// Used to flavour personality copy.
  double get balance {
    final s = sum;
    if (s <= 0) return 0;
    final n = DnaTrait.values.length;
    // Normalised entropy.
    double entropy = 0;
    for (final t in DnaTrait.values) {
      final p = of(t) / s;
      if (p > 0) entropy -= p * (math.log(p) / math.ln2);
    }
    final maxEntropy = math.log(n) / math.ln2;
    return (entropy / maxEntropy).clamp(0.0, 1.0);
  }

  Map<String, dynamic> toJson() =>
      {for (final entry in totals.entries) entry.key.name: entry.value};

  factory LifeDna.fromJson(Map<String, dynamic> json) {
    final map = {for (final t in DnaTrait.values) t: 0.0};
    json.forEach((key, value) {
      final trait = DnaTrait.values.where((t) => t.name == key);
      if (trait.isNotEmpty) {
        map[trait.first] = (value as num).toDouble();
      }
    });
    return LifeDna(map);
  }
}
