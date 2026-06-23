import '../models/contexts.dart';
import '../models/dna_trait.dart';
import '../models/memory_card.dart';
import '../models/walk.dart';

/// Turns a completed [Walk] into a [MemoryCard] - a diary line written in the
/// companion's voice. Fully deterministic given a walk + seed, so it is unit
/// testable and never produces unsafe AI text (curated templates only).
class MemoryGenerator {
  const MemoryGenerator();

  /// Generate a memory for [walk]. [seed] varies the wording; [dayIndex] labels it.
  static MemoryCard generate(
    Walk walk, {
    required int seed,
    required int dayIndex,
    bool premium = false,
  }) {
    final lead = walk.lead;
    final leadPlace =
        walk.stops.isNotEmpty ? walk.stops.first.place : PlaceType.park;
    final lastPlace =
        walk.stops.isNotEmpty ? walk.stops.last.place : leadPlace;

    final templates = _diaryTemplates[lead]!;
    final base = templates[seed.abs() % templates.length];
    var diary = base
        .replaceAll('{first}', leadPlace.label.toLowerCase())
        .replaceAll('{last}', lastPlace.label.toLowerCase())
        .replaceAll('{time}', walk.time.label.toLowerCase())
        .replaceAll('{weather}', walk.weather.label.toLowerCase());

    if (premium) {
      diary = '$diary ${_voiceFlourish[lead]!}';
    }

    final titles = _titles[lead]!;
    final title = titles[seed.abs() % titles.length];

    return MemoryCard(
      id: 'mem-$dayIndex-${seed.abs()}',
      title: title,
      diary: diary,
      lead: lead,
      places: walk.stops.map((s) => s.place).toList(),
      time: walk.time,
      weather: walk.weather,
      dayLabel: 'Day $dayIndex',
      premium: premium,
    );
  }

  static const Map<DnaTrait, List<String>> _titles = {
    DnaTrait.vitality: ['A quick bright loop', 'Streets full of go', 'Morning momentum'],
    DnaTrait.calm: ['A slow, easy hour', 'Quiet by the water', 'Nothing to rush'],
    DnaTrait.curiosity: ['Something new today', 'Down an unknown turn', 'Wide-eyed wandering'],
    DnaTrait.warmth: ['A soft, kind day', 'Close to home', 'Golden and gentle'],
    DnaTrait.focus: ['Clear and ordered', 'A steady line', 'Everything in place'],
    DnaTrait.wonder: ['Small magic at dusk', 'Lights and quiet', 'A dreamy detour'],
  };

  static const Map<DnaTrait, List<String>> _diaryTemplates = {
    DnaTrait.vitality: [
      'We started at the {first} and the whole {time} felt fast and alive. I could keep going!',
      'So much movement around the {first} today. My heart was racing in a good way.',
      'The {first} buzzed under {weather} skies - I felt like I could take on anything.',
    ],
    DnaTrait.calm: [
      'We drifted from the {first} to the {last} and I just breathed. A {time} like this is enough.',
      'The {weather} made the {first} so still. I felt myself slow down and settle.',
      'No hurry at all by the {first}. I want to remember how quiet it was.',
    ],
    DnaTrait.curiosity: [
      'The {first} had a corner I had never noticed. I keep wondering what else is out there.',
      'We wandered to the {last} and everything looked new. I asked a hundred little questions.',
      'A {time} full of small surprises near the {first}. My curiosity is wide awake.',
    ],
    DnaTrait.warmth: [
      'Home felt close from the {first} all the way to the {last}. A warm, kind {time}.',
      'The {first} smelled like comfort under {weather} air. I felt looked after.',
      'Soft light around the {first} today. I just wanted to stay near the people.',
    ],
    DnaTrait.focus: [
      'From the {first} to the {last}, every step felt ordered. My thoughts went clear.',
      'A {time} with a clean rhythm near the {first}. I knew exactly where I was going.',
      'The {first} helped me line everything up. Calm, sharp, sure.',
    ],
    DnaTrait.wonder: [
      'The {first} glowed in the {time}. For a moment the ordinary felt a little magic.',
      'Quiet lights from the {first} to the {last}. I held my breath at how lovely it was.',
      '{weather} on the glass near the {first} - the whole {time} felt like a small dream.',
    ],
  };

  static const Map<DnaTrait, String> _voiceFlourish = {
    DnaTrait.vitality: '(said in a bright, breathless rush)',
    DnaTrait.calm: '(murmured, almost a sigh)',
    DnaTrait.curiosity: '(eyes wide, already asking what next)',
    DnaTrait.warmth: '(said with a soft, contented smile)',
    DnaTrait.focus: '(spoken slow and certain)',
    DnaTrait.wonder: '(whispered, like a secret)',
  };
}
