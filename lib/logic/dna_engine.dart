import '../models/contexts.dart';
import '../models/dna_trait.dart';
import '../models/life_dna.dart';

/// A short, human description of who the companion is, derived from Life DNA.
class Personality {
  const Personality({
    required this.title,
    required this.description,
    required this.dominant,
    required this.secondary,
  });

  final String title;
  final String description;
  final DnaTrait dominant;
  final DnaTrait secondary;
}

/// Pure functions that translate place/time/weather context into Life DNA, and
/// Life DNA into personality and mood. No Flutter, no I/O - fully unit testable.
class DnaEngine {
  const DnaEngine();

  /// Merge a single day's context (place + time + weather) into trait points.
  static Map<DnaTrait, double> contextDna(
    PlaceType place,
    TimeContext time,
    WeatherContext weather,
  ) {
    final result = <DnaTrait, double>{};
    void addAll(Map<DnaTrait, double> src) {
      src.forEach((trait, value) {
        result[trait] = (result[trait] ?? 0) + value;
      });
    }

    addAll(place.dna);
    addAll(time.boost);
    addAll(weather.boost);
    return result;
  }

  /// Convenience: context as a [LifeDna] value object.
  static LifeDna contextLifeDna(
    PlaceType place,
    TimeContext time,
    WeatherContext weather,
  ) =>
      LifeDna.from(contextDna(place, time, weather));

  /// Derive a personality from accumulated Life DNA.
  static Personality personality(LifeDna dna) {
    final dom = dna.dominant;
    final sec = dna.secondary;
    final title = _titleFor(dom, sec);
    final description = _descriptionFor(dom, sec, dna.balance);
    return Personality(
      title: title,
      description: description,
      dominant: dom,
      secondary: sec,
    );
  }

  /// The companion's "form" name - its species at a glance, from its strongest trait.
  static String formName(DnaTrait dominant) {
    switch (dominant) {
      case DnaTrait.vitality:
        return 'Sparkling';
      case DnaTrait.calm:
        return 'Driftling';
      case DnaTrait.curiosity:
        return 'Seekling';
      case DnaTrait.warmth:
        return 'Emberling';
      case DnaTrait.focus:
        return 'Clearling';
      case DnaTrait.wonder:
        return 'Dreamling';
    }
  }

  /// A short mood line driven by the most recent context the companion lived.
  static String moodFor(PlaceType place, TimeContext time, WeatherContext weather) =>
      moodForTrait(contextLifeDna(place, time, weather).dominant);

  /// The mood word a given trait evokes.
  static String moodForTrait(DnaTrait lead) {
    switch (lead) {
      case DnaTrait.vitality:
        return 'Buzzing';
      case DnaTrait.calm:
        return 'Settled';
      case DnaTrait.curiosity:
        return 'Inquisitive';
      case DnaTrait.warmth:
        return 'Cosy';
      case DnaTrait.focus:
        return 'Sharp';
      case DnaTrait.wonder:
        return 'Dreamy';
    }
  }

  static String _titleFor(DnaTrait dom, DnaTrait sec) {
    const lead = {
      DnaTrait.vitality: 'Restless',
      DnaTrait.calm: 'Gentle',
      DnaTrait.curiosity: 'Wandering',
      DnaTrait.warmth: 'Tender',
      DnaTrait.focus: 'Steady',
      DnaTrait.wonder: 'Quiet',
    };
    const noun = {
      DnaTrait.vitality: 'Spark',
      DnaTrait.calm: 'Drift',
      DnaTrait.curiosity: 'Explorer',
      DnaTrait.warmth: 'Heart',
      DnaTrait.focus: 'Mind',
      DnaTrait.wonder: 'Dreamer',
    };
    return '${lead[dom]} ${noun[sec]}';
  }

  static String _descriptionFor(DnaTrait dom, DnaTrait sec, double balance) {
    final domPhrase = _phrase[dom]!;
    final secPhrase = _phrase[sec]!;
    final temper = balance > 0.78
        ? 'It carries a little of everywhere you go.'
        : balance < 0.45
            ? 'It leans hard into one kind of place.'
            : 'It has a clear shape with room to grow.';
    return 'Mostly $domPhrase, touched by $secPhrase. $temper';
  }

  static const Map<DnaTrait, String> _phrase = {
    DnaTrait.vitality: 'bright and quick',
    DnaTrait.calm: 'slow and easy',
    DnaTrait.curiosity: 'eager to wander',
    DnaTrait.warmth: 'soft and kind',
    DnaTrait.focus: 'clear-headed',
    DnaTrait.wonder: 'a little dreamy',
  };
}
