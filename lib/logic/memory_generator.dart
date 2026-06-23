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
    final leadPlace = walk.stops.isNotEmpty
        ? walk.stops.first.place
        : PlaceType.park;
    final lastPlace = walk.stops.isNotEmpty ? walk.stops.last.place : leadPlace;

    final templates = _diaryTemplates[lead]!;
    final base = templates[seed.abs() % templates.length];
    var diary = base
        .replaceAll('{first}', leadPlace.label)
        .replaceAll('{last}', lastPlace.label)
        .replaceAll('{time}', walk.time.label)
        .replaceAll('{weather}', walk.weather.label);

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
      dayLabel: '$dayIndex日目',
      premium: premium,
    );
  }

  static const Map<DnaTrait, List<String>> _titles = {
    DnaTrait.vitality: ['明るく早いひと回り', '動き出す道', '朝の勢い'],
    DnaTrait.calm: ['ゆっくりした時間', '水辺の静けさ', '急がなくていい日'],
    DnaTrait.curiosity: ['今日は新しい発見', '知らない角を曲がって', '目が覚めるさんぽ'],
    DnaTrait.warmth: ['やさしい一日', '家の近くで', '金色で穏やか'],
    DnaTrait.focus: ['整った道すじ', 'まっすぐな時間', '頭が片づく日'],
    DnaTrait.wonder: ['夕暮れの小さな魔法', '明かりと静けさ', '夢みたいな寄り道'],
  };

  static const Map<DnaTrait, List<String>> _diaryTemplates = {
    DnaTrait.vitality: [
      '{first}から始まった{time}は、体の中まで明るく動いていました。まだ行けそうです。',
      '今日は{first}のまわりに人の流れがあって、胸がいい感じに弾みました。',
      '{weather}の下の{first}はにぎやかで、なんでもできそうな気がしました。',
    ],
    DnaTrait.calm: [
      '{first}から{last}まで、ただ息をするだけでよかったです。こんな{time}で十分です。',
      '{weather}の{first}はとても静かで、心がゆっくり落ち着いていきました。',
      '{first}では急ぐ必要がありませんでした。あの静けさを覚えていたいです。',
    ],
    DnaTrait.curiosity: [
      '{first}に、今まで気づかなかった角がありました。ほかにも何があるのか気になります。',
      '{last}まで歩いたら、全部が少し新しく見えました。小さな質問がたくさん生まれました。',
      '{first}の近くの{time}は、小さな驚きでいっぱいでした。好奇心が起きています。',
    ],
    DnaTrait.warmth: [
      '{first}から{last}まで、帰る場所が近く感じました。あたたかくてやさしい{time}です。',
      '{weather}の空気の中で、{first}は安心する匂いがしました。守られている気がしました。',
      '今日は{first}のまわりの光がやわらかくて、人のそばにいたくなりました。',
    ],
    DnaTrait.focus: [
      '{first}から{last}まで、一歩ずつ順番に整っていく感じがしました。頭が澄みました。',
      '{first}の近くの{time}には、きれいなリズムがありました。行き先がはっきりしました。',
      '{first}が、ばらばらだったものを並べ直してくれました。静かで、冴えて、確かです。',
    ],
    DnaTrait.wonder: [
      '{time}の{first}が少し光って見えました。いつもの場所が、少しだけ魔法みたいでした。',
      '{first}から{last}まで、静かな明かりが続いていました。きれいで、息を止めました。',
      '{first}の近くの窓に{weather}の気配があって、{time}全体が小さな夢みたいでした。',
    ],
  };

  static const Map<DnaTrait, String> _voiceFlourish = {
    DnaTrait.vitality: '（息を弾ませながら、明るく）',
    DnaTrait.calm: '（ため息みたいに、そっと）',
    DnaTrait.curiosity: '（目を丸くして、次を聞きたそうに）',
    DnaTrait.warmth: '（満ち足りた笑顔で、やわらかく）',
    DnaTrait.focus: '（ゆっくり、確かめるように）',
    DnaTrait.wonder: '（秘密を話すみたいに、小さな声で）',
  };
}
