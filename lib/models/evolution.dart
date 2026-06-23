import 'dna_trait.dart';

/// The life-stages a companion grows through. Stage is earned through lived
/// walks, never through speed or risky behaviour.
enum EvolutionStage {
  egg(label: 'たまご', blurb: 'まだ生まれていない。', minWalks: -1, ring: 0),
  hatchling(
    label: 'うまれたて',
    blurb: '生まれたばかり。やわらかく、少しそわそわしている。',
    minWalks: 0,
    ring: 1,
  ),
  wanderer(label: 'さんぽ者', blurb: 'あなたの生活圏を覚えはじめている。', minWalks: 5, ring: 2),
  kindred(label: '相棒', blurb: '日々の道に形づくられ、少しあなたに似てきた。', minWalks: 12, ring: 3),
  luminary(
    label: '灯りの継承者',
    blurb: '記憶を受け渡せるほど育った、完成形の相棒。',
    minWalks: 22,
    ring: 4,
  );

  const EvolutionStage({
    required this.label,
    required this.blurb,
    required this.minWalks,
    required this.ring,
  });

  final String label;
  final String blurb;
  final int minWalks;
  final int ring;

  static EvolutionStage fromName(String name) =>
      EvolutionStage.values.firstWhere(
        (s) => s.name == name,
        orElse: () => EvolutionStage.hatchling,
      );
}

/// A weekly evolution card - the collectible report of how the companion changed
/// across a week of walks.
class WeeklyCard {
  const WeeklyCard({
    required this.week,
    required this.stage,
    required this.headline,
    required this.summary,
    required this.topTrait,
    required this.walks,
    required this.memories,
    required this.evolved,
  });

  final int week;
  final EvolutionStage stage;
  final String headline;
  final String summary;
  final DnaTrait topTrait;
  final int walks;
  final int memories;

  /// Whether the companion advanced a stage during this week.
  final bool evolved;

  Map<String, dynamic> toJson() => {
    'week': week,
    'stage': stage.name,
    'headline': headline,
    'summary': summary,
    'topTrait': topTrait.name,
    'walks': walks,
    'memories': memories,
    'evolved': evolved,
  };

  factory WeeklyCard.fromJson(Map<String, dynamic> json) => WeeklyCard(
    week: json['week'] as int,
    stage: EvolutionStage.fromName(json['stage'] as String),
    headline: json['headline'] as String,
    summary: json['summary'] as String,
    topTrait: DnaTrait.fromName(json['topTrait'] as String),
    walks: json['walks'] as int,
    memories: json['memories'] as int,
    evolved: json['evolved'] as bool? ?? false,
  );
}
