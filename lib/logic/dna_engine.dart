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
  ) => LifeDna.from(contextDna(place, time, weather));

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
        return 'ハシリコ';
      case DnaTrait.calm:
        return 'ユラリコ';
      case DnaTrait.curiosity:
        return 'サガシコ';
      case DnaTrait.warmth:
        return 'ホノリコ';
      case DnaTrait.focus:
        return 'スミリコ';
      case DnaTrait.wonder:
        return 'ユメリコ';
    }
  }

  /// A short mood line driven by the most recent context the companion lived.
  static String moodFor(
    PlaceType place,
    TimeContext time,
    WeatherContext weather,
  ) => moodForTrait(contextLifeDna(place, time, weather).dominant);

  /// The mood word a given trait evokes.
  static String moodForTrait(DnaTrait lead) {
    switch (lead) {
      case DnaTrait.vitality:
        return 'そわそわ';
      case DnaTrait.calm:
        return 'ほっとしている';
      case DnaTrait.curiosity:
        return 'きょろきょろ';
      case DnaTrait.warmth:
        return 'ぬくぬく';
      case DnaTrait.focus:
        return 'すっきり';
      case DnaTrait.wonder:
        return 'うっとり';
    }
  }

  static String _titleFor(DnaTrait dom, DnaTrait sec) {
    const lead = {
      DnaTrait.vitality: '弾む',
      DnaTrait.calm: 'おだやかな',
      DnaTrait.curiosity: '探したがりの',
      DnaTrait.warmth: 'やさしい',
      DnaTrait.focus: 'まっすぐな',
      DnaTrait.wonder: '夢みる',
    };
    const noun = {
      DnaTrait.vitality: '火花',
      DnaTrait.calm: '水面',
      DnaTrait.curiosity: '探検家',
      DnaTrait.warmth: '灯り',
      DnaTrait.focus: '羅針盤',
      DnaTrait.wonder: '夢',
    };
    return '${lead[dom]} ${noun[sec]}';
  }

  static String _descriptionFor(DnaTrait dom, DnaTrait sec, double balance) {
    final domPhrase = _phrase[dom]!;
    final secPhrase = _phrase[sec]!;
    final temper = balance > 0.78
        ? 'いろいろな場所の気配を少しずつ持っています。'
        : balance < 0.45
        ? 'ひとつの場所の色がかなり強く出ています。'
        : '芯が見えつつ、まだ伸びしろがあります。';
    return '$domPhrase が強く、$secPhrase も少し混ざっています。$temper';
  }

  static const Map<DnaTrait, String> _phrase = {
    DnaTrait.vitality: '明るく動き出したい感じ',
    DnaTrait.calm: 'ゆっくり息をつける感じ',
    DnaTrait.curiosity: '知らないものを見つけたい感じ',
    DnaTrait.warmth: 'やわらかく安心する感じ',
    DnaTrait.focus: '頭がすっと整う感じ',
    DnaTrait.wonder: '少し夢を見ているような感じ',
  };
}
