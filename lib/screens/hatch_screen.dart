import 'package:flutter/material.dart';

import '../logic/dna_engine.dart';
import '../logic/memory_generator.dart';
import '../models/contexts.dart';
import '../models/dna_trait.dart';
import '../models/memory_card.dart';
import '../models/walk.dart';
import '../state/app_scope.dart';
import '../theme/app_colors.dart';
import '../widgets/app_background.dart';
import '../widgets/companion_avatar.dart';
import '../widgets/dna_widgets.dart';
import '../widgets/selectors.dart';

enum _Step { intro, scan, hatching, reveal }

/// First-run experience: scan a place context, hatch a companion, and instantly
/// see why its first traits came from that place.
class HatchScreen extends StatefulWidget {
  const HatchScreen({super.key});

  @override
  State<HatchScreen> createState() => _HatchScreenState();
}

class _HatchScreenState extends State<HatchScreen> {
  _Step _step = _Step.intro;

  PlaceType _place = PlaceType.station;
  TimeContext _time = TimeContext.morning;
  WeatherContext _weather = WeatherContext.clear;

  void _goScan() => setState(() => _step = _Step.scan);

  void _startHatch() {
    setState(() => _step = _Step.hatching);
    Future.delayed(const Duration(milliseconds: 1900), () {
      if (mounted) setState(() => _step = _Step.reveal);
    });
  }

  void _enterApp() {
    AppScope.read(context).hatch(_place, _time, _weather);
    // _RootGate will switch to the home shell automatically.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        night: _step == _Step.hatching || _step == _Step.reveal,
        child: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: _buildStep(),
          ),
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case _Step.intro:
        return _intro();
      case _Step.scan:
        return _scan();
      case _Step.hatching:
        return _hatching();
      case _Step.reveal:
        return _reveal();
    }
  }

  // ---------------------------------------------------------------- intro
  Widget _intro() {
    return Padding(
      key: const ValueKey('intro'),
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        children: [
          const Spacer(),
          const CompanionAvatar(
            primary: DnaTrait.calm,
            secondary: DnaTrait.warmth,
            mood: 'Waiting',
            stageRing: 0,
            seed: 1,
            hatched: false,
            size: 180,
          ),
          const SizedBox(height: 28),
          Text('GeoFamiliar', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 10),
          Text(
            'Your ordinary places - the station, the river, the late-night shop - quietly become a companion only your life could make.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const Spacer(),
          _featureRow(
            Icons.my_location_rounded,
            'Your places become its personality',
          ),
          const SizedBox(height: 10),
          _featureRow(
            Icons.auto_stories_rounded,
            'Your week becomes its memories',
          ),
          const SizedBox(height: 10),
          _featureRow(
            Icons.eco_rounded,
            'Gentle by design - no risky routes, ever',
          ),
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: _goScan,
            icon: const Icon(Icons.radar_rounded),
            label: const Text("Scan today's place"),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.mintDeep,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _featureRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.hairline),
          ),
          child: Icon(icon, size: 19, color: AppColors.coralDeep),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.inkSoft,
            ),
          ),
        ),
      ],
    );
  }

  // ----------------------------------------------------------------- scan
  Widget _scan() {
    final preview = DnaEngine.contextLifeDna(_place, _time, _weather);
    return ListView(
      key: const ValueKey('scan'),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => setState(() => _step = _Step.intro),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            Text(
              'Scan your place',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
        const SizedBox(height: 4),
        _mockLocationBanner(),
        const SizedBox(height: 18),
        Text(
          'Where are you right now?',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.55,
          children: PlaceType.values.map((p) {
            return PlaceTile(
              icon: p.icon,
              label: p.label,
              tagline: p.tagline,
              selected: _place == p,
              onTap: () => setState(() => _place = p),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        Text('Time of day', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        ChoicePills<TimeContext>(
          items: TimeContext.values,
          selected: _time,
          labelOf: (t) => t.label,
          iconOf: (t) => t.icon,
          onSelect: (t) => setState(() => _time = t),
        ),
        const SizedBox(height: 20),
        Text('Weather', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        ChoicePills<WeatherContext>(
          items: WeatherContext.values,
          selected: _weather,
          labelOf: (w) => w.label,
          iconOf: (w) => w.icon,
          accent: AppColors.amber,
          onSelect: (w) => setState(() => _weather = w),
        ),
        const SizedBox(height: 22),
        SoftCard(
          color: AppColors.mint.withValues(alpha: 0.10),
          borderColor: AppColors.mint.withValues(alpha: 0.4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.auto_awesome_rounded,
                    size: 18,
                    color: AppColors.mintDeep,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'From this moment',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // A vivid read-back of the chosen context.
              Row(
                children: [
                  _ctxIcon(_place.icon),
                  _ctxIcon(_time.icon),
                  _ctxIcon(_weather.icon),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${_place.label}, ${_time.label.toLowerCase()}, ${_weather.label.toLowerCase()}.',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${_place.tagline} A companion born here would carry that with it.',
                style: const TextStyle(
                  fontSize: 12.5,
                  height: 1.35,
                  color: AppColors.inkSoft,
                ),
              ),
              const Divider(height: 20, color: AppColors.hairline),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: preview.ranked
                    .where((t) => preview.of(t) > 0)
                    .map((t) => DnaChip(trait: t, value: preview.of(t)))
                    .toList(),
              ),
              const SizedBox(height: 10),
              Text(
                'It will hatch as a ${DnaEngine.formName(preview.dominant)} - ${DnaEngine.personality(preview).title}.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: _startHatch,
          icon: const Icon(Icons.egg_alt_rounded),
          label: const Text('Hatch my companion'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.coralDeep,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _mockLocationBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.shield_moon_rounded,
            size: 18,
            color: AppColors.mintDeep,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Using simulated location for this preview. Real GPS stays opt-in and private - pick the place that fits your day.',
              style: const TextStyle(
                fontSize: 12,
                height: 1.3,
                color: AppColors.inkMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------- hatching
  Widget _hatching() {
    return Center(
      key: const ValueKey('hatching'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CompanionAvatar(
            primary: _place.dna.keys.first,
            secondary: DnaTrait.warmth,
            mood: 'Waiting',
            stageRing: 0,
            seed: _place.index + 1,
            hatched: false,
            sparkle: true,
            size: 200,
          ),
          const SizedBox(height: 24),
          const SizedBox(
            width: 26,
            height: 26,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppColors.amber,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Reading your Life DNA...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------- reveal
  Widget _reveal() {
    final dna = DnaEngine.contextLifeDna(_place, _time, _weather);
    final personality = DnaEngine.personality(dna);
    final form = DnaEngine.formName(dna.dominant);
    final MemoryCard firstMemory = _previewFirstMemory();

    final contributions = <MapEntry<DnaTrait, String>>[
      ..._place.dna.entries.map(
        (e) => MapEntry(
          e.key,
          '${_place.label} -> +${e.value.toStringAsFixed(0)}',
        ),
      ),
      ..._time.boost.entries.map(
        (e) =>
            MapEntry(e.key, '${_time.label} -> +${e.value.toStringAsFixed(0)}'),
      ),
      ..._weather.boost.entries.map(
        (e) => MapEntry(
          e.key,
          '${_weather.label} -> +${e.value.toStringAsFixed(1)}',
        ),
      ),
    ];

    return ListView(
      key: const ValueKey('reveal'),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      children: [
        Center(
          child: CompanionAvatar(
            primary: personality.dominant,
            secondary: personality.secondary,
            mood: 'Buzzing',
            stageRing: 1,
            seed: _place.index + 1,
            sparkle: true,
            size: 190,
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'It hatched!',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.amber,
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            'A $form is born',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(color: Colors.white),
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: Text(
            personality.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.amber,
            ),
          ),
        ),
        const SizedBox(height: 18),
        // The bond moment - a first hello, before any trait accounting.
        SoftCard(
          color: AppColors.surface,
          borderColor: AppColors.amber.withValues(alpha: 0.55),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.waving_hand_rounded,
                size: 20,
                color: AppColors.coralDeep,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _greeting(personality.dominant),
                  style: const TextStyle(
                    fontSize: 14.5,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Why these traits',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              Text(
                personality.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Divider(height: 22, color: AppColors.hairline),
              ...contributions.map(
                (c) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(c.key.icon, size: 16, color: c.key.color),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          c.value,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.inkSoft,
                          ),
                        ),
                      ),
                      Text(
                        c.key.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color.lerp(c.key.color, AppColors.ink, 0.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SoftCard(
          color: AppColors.surface,
          borderColor: AppColors.amber.withValues(alpha: 0.5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.auto_stories_rounded,
                    size: 16,
                    color: AppColors.coralDeep,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Its first memory',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '"${firstMemory.diary}"',
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  fontStyle: FontStyle.italic,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        FilledButton.icon(
          onPressed: _enterApp,
          icon: const Icon(Icons.home_rounded),
          label: Text('Meet $form'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.mintDeep,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  MemoryCard _previewFirstMemory() {
    // Mirror AppState.hatch's seed so the reveal matches what gets saved.
    final walk = Walk(
      stops: [RouteStop(_place)],
      time: _time,
      weather: _weather,
    );
    return MemoryGenerator.generate(walk, seed: _place.index + 3, dayIndex: 1);
  }

  /// A small context icon chip used in the scan preview read-back.
  Widget _ctxIcon(IconData icon) => Padding(
    padding: const EdgeInsets.only(right: 6),
    child: Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Icon(icon, size: 15, color: AppColors.mintDeep),
    ),
  );

  /// A warm first hello in the companion's voice, by dominant trait.
  String _greeting(DnaTrait dominant) {
    switch (dominant) {
      case DnaTrait.vitality:
        return 'Oh - hi! I feel like I could run already. Are you the one I get to follow?';
      case DnaTrait.calm:
        return '...oh. Hello. It is quiet and kind here. I think I will like it, with you.';
      case DnaTrait.curiosity:
        return 'Hello! Where are we? What is that? I think I am going to ask you everything.';
      case DnaTrait.warmth:
        return 'Hi. You feel a little like home already. I am glad it is you.';
      case DnaTrait.focus:
        return 'Hello. I can see you clearly. Let us find our rhythm together.';
      case DnaTrait.wonder:
        return 'Oh... hello. The light is lovely from here. I am glad I woke up to you.';
    }
  }
}
