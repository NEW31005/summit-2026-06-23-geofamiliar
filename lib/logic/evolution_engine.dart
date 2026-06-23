import '../models/dna_trait.dart';
import '../models/evolution.dart';
import '../models/life_dna.dart';

/// Pure logic for companion progression. Stages and weekly cards are functions
/// of lived walks - testable and free of side effects.
class EvolutionEngine {
  const EvolutionEngine();

  /// How many walks complete one weekly evolution cycle. Gentle on purpose:
  /// we never pressure the user to walk more than a handful of times.
  static const int walksPerWeek = 5;

  /// The stage earned by [totalWalks] completed walks.
  static EvolutionStage stageFor(int totalWalks) {
    EvolutionStage stage = EvolutionStage.hatchling;
    for (final s in EvolutionStage.values) {
      if (s == EvolutionStage.egg) continue;
      if (totalWalks >= s.minWalks) stage = s;
    }
    return stage;
  }

  /// Progress (0..1) toward the next weekly evolution given [walksThisWeek].
  static double weeklyProgress(int walksThisWeek) =>
      (walksThisWeek / walksPerWeek).clamp(0.0, 1.0);

  /// Whether the current week's evolution is ready to claim.
  static bool weekReady(int walksThisWeek) => walksThisWeek >= walksPerWeek;

  /// Walks still needed before the next weekly card unlocks.
  static int walksRemaining(int walksThisWeek) =>
      (walksPerWeek - walksThisWeek).clamp(0, walksPerWeek);

  /// Build the weekly evolution card from the week's lived data.
  static WeeklyCard buildWeeklyCard({
    required int week,
    required int totalWalksBefore,
    required int walksThisWeek,
    required int memoriesThisWeek,
    required LifeDna weekDna,
  }) {
    final totalAfter = totalWalksBefore + walksThisWeek;
    final stageBefore = stageFor(totalWalksBefore);
    final stageAfter = stageFor(totalAfter);
    final evolved = stageAfter.ring > stageBefore.ring;
    final top = weekDna.sum > 0 ? weekDna.dominant : DnaTrait.calm;

    final headline = evolved
        ? '相棒が「${stageAfter.label}」になりました'
        : '${top.label}が濃い一週間';

    final summary = _summary(top, evolved, stageAfter, walksThisWeek);

    return WeeklyCard(
      week: week,
      stage: stageAfter,
      headline: headline,
      summary: summary,
      topTrait: top,
      walks: walksThisWeek,
      memories: memoriesThisWeek,
      evolved: evolved,
    );
  }

  static String _summary(
    DnaTrait top,
    bool evolved,
    EvolutionStage stage,
    int walks,
  ) {
    final lead = {
      DnaTrait.vitality: '明るくにぎやかな場所が、相棒を元気にしました',
      DnaTrait.calm: '静かでひらけた場所が、相棒を落ち着かせました',
      DnaTrait.curiosity: '新しい角や発見が、相棒をきょろきょろさせました',
      DnaTrait.warmth: '見慣れたあたたかい場所が、相棒をやさしくしました',
      DnaTrait.focus: '整った用事や道すじが、相棒をすっきりさせました',
      DnaTrait.wonder: '夕暮れや明かりが、相棒に夢みたいな余韻を残しました',
    }[top]!;
    final tail = evolved
        ? '今週、「${stage.label}」まで成長しました。'
        : 'どんな相棒になるか、まだゆっくり形を作っています。';
    return '$walks回のさんぽで、$lead。$tail';
  }
}
