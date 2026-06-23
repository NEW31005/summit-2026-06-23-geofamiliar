import 'package:flutter/material.dart';

import '../logic/evolution_engine.dart';
import '../logic/walk_advisor.dart';
import '../models/contexts.dart';
import '../models/dna_trait.dart';
import '../models/life_dna.dart';
import '../models/memory_card.dart';
import '../models/walk.dart';
import '../state/app_scope.dart';
import '../theme/app_colors.dart';
import '../widgets/dna_widgets.dart';
import '../widgets/section_header.dart';
import '../widgets/selectors.dart';

/// Build and finish a gentle simulated walk. Stops contribute Life DNA; finishing
/// generates a memory. We never reward speed, distance, loops or risky routes.
class WalkScreen extends StatefulWidget {
  const WalkScreen({super.key});

  @override
  State<WalkScreen> createState() => _WalkScreenState();
}

class _WalkScreenState extends State<WalkScreen> {
  final List<RouteStop> _route = [];
  TimeContext _time = TimeContext.morning;
  WeatherContext _weather = WeatherContext.clear;
  bool _initialised = false;

  static const _maxStops = 5;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialised) {
      final c = AppScope.of(context).companion;
      _time = c.lastTime ?? TimeContext.morning;
      _weather = c.lastWeather ?? WeatherContext.clear;
      _initialised = true;
    }
  }

  void _addStop(PlaceType place) {
    if (_route.length >= _maxStops) return;
    setState(() => _route.add(RouteStop(place)));
  }

  void _removeStop(int index) => setState(() => _route.removeAt(index));

  void _suggestRoute() {
    // A calm, curated everyday route - safe by design.
    setState(() {
      _route
        ..clear()
        ..addAll(const [
          RouteStop(PlaceType.residential),
          RouteStop(PlaceType.park),
          RouteStop(PlaceType.cafe),
        ]);
    });
  }

  Walk get _walk => Walk(stops: _route, time: _time, weather: _weather);

  void _finishWalk() {
    final state = AppScope.read(context);
    final walk = _walk;
    final lead = walk.lead;
    final leadGain = walk.dna.of(lead);
    final memory = state.completeWalk(walk);
    final recap = _WalkRecap(
      memory: memory,
      lead: lead,
      leadGain: leadGain,
      walksThisWeek: state.companion.walksThisWeek,
      walksPerWeek: EvolutionEngine.walksPerWeek,
      weekReady: state.companion.weekReady,
    );
    setState(() => _route.clear());
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _WalkRecapSheet(recap: recap),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dna = _walk.dna;
    final hasRoute = _route.isNotEmpty;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        Text("Today's walk", style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 4),
        const Text(
          'Add a few places you actually pass through. Each one shapes your companion.',
          style: TextStyle(fontSize: 13, color: AppColors.inkMuted, height: 1.35),
        ),
        const SizedBox(height: 16),

        _suggestionBanner(AppScope.of(context).companion.dna),
        const SizedBox(height: 18),

        // Context
        const SectionHeader(eyebrow: 'Context', title: 'Time & weather'),
        const SizedBox(height: 10),
        ChoicePills<TimeContext>(
          items: TimeContext.values,
          selected: _time,
          labelOf: (t) => t.label,
          iconOf: (t) => t.icon,
          onSelect: (t) => setState(() => _time = t),
        ),
        const SizedBox(height: 8),
        ChoicePills<WeatherContext>(
          items: WeatherContext.values,
          selected: _weather,
          labelOf: (w) => w.label,
          iconOf: (w) => w.icon,
          accent: AppColors.amber,
          onSelect: (w) => setState(() => _weather = w),
        ),
        const SizedBox(height: 22),

        // Route builder
        SectionHeader(
          eyebrow: 'Route',
          title: 'Your stops',
          trailing: TextButton.icon(
            onPressed: _suggestRoute,
            icon: const Icon(Icons.auto_fix_high_rounded, size: 16),
            label: const Text('Suggest'),
          ),
        ),
        const SizedBox(height: 10),
        _routeArea(hasRoute),
        const SizedBox(height: 18),

        Text('Add a place',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: PlaceType.values.map((p) {
            final full = _route.length >= _maxStops;
            return GestureDetector(
              onTap: full ? null : () => _addStop(p),
              child: Opacity(
                opacity: full ? 0.4 : 1,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: AppColors.hairline),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(p.icon, size: 16, color: AppColors.inkSoft),
                      const SizedBox(width: 6),
                      Text(p.label,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.inkSoft)),
                      const SizedBox(width: 4),
                      const Icon(Icons.add_rounded,
                          size: 15, color: AppColors.mintDeep),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 22),

        // Route forecast - tells the user what finishing will do before they do it.
        if (hasRoute) ...[
          _forecastCard(dna),
          const SizedBox(height: 14),
        ],

        _safetyNote(),
        const SizedBox(height: 18),

        FilledButton.icon(
          onPressed: hasRoute ? _finishWalk : null,
          icon: const Icon(Icons.check_circle_rounded),
          label: Text(hasRoute ? 'Finish walk & make a memory' : 'Add a stop to begin'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.coralDeep,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.hairline,
          ),
        ),
      ],
    );
  }

  /// A gentle, safe "today's idea" - suggests the companion's weakest trait and
  /// an optional place to round it out. Never pushes distance, speed or timing.
  Widget _suggestionBanner(LifeDna dna) {
    final suggestion = WalkAdvisor.gentleSuggestion(dna);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.amber.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.amber.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: suggestion.weakest.color.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(suggestion.place.icon,
                size: 19, color: suggestion.weakest.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('Gentle idea',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.coralDeep)),
                    const SizedBox(width: 6),
                    Icon(suggestion.weakest.icon,
                        size: 13, color: suggestion.weakest.color),
                  ],
                ),
                const SizedBox(height: 2),
                Text(suggestion.message,
                    style: const TextStyle(
                        fontSize: 12.5, height: 1.3, color: AppColors.inkSoft)),
              ],
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: _route.length >= _maxStops
                ? null
                : () => _addStop(suggestion.place),
            icon: const Icon(Icons.add_circle_rounded,
                size: 24, color: AppColors.amber),
            tooltip: 'Add ${suggestion.place.label}',
          ),
        ],
      ),
    );
  }

  /// Pre-finish forecast: mood the route will create plus the DNA it adds.
  Widget _forecastCard(LifeDna dna) {
    final forecast = WalkAdvisor.moodForecast(_walk);
    final lead = _walk.lead;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: lead.color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: lead.color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.insights_rounded, size: 18, color: lead.color),
              const SizedBox(width: 8),
              Text('Route forecast',
                  style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              Text(_walk.strollLabel,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.inkMuted)),
            ],
          ),
          if (forecast != null) ...[
            const SizedBox(height: 8),
            Text(forecast,
                style: const TextStyle(
                    fontSize: 13, height: 1.35, color: AppColors.inkSoft)),
          ],
          const SizedBox(height: 12),
          Text('Life DNA this walk adds',
              style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.inkMuted)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: dna.ranked
                .where((t) => dna.of(t) > 0)
                .map<Widget>((t) => DnaChip(trait: t, value: dna.of(t), dense: true))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _routeArea(bool hasRoute) {
    if (!hasRoute) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.hairline,
          ),
        ),
        child: const Column(
          children: [
            Icon(Icons.route_rounded, size: 28, color: AppColors.inkMuted),
            SizedBox(height: 8),
            Text('No stops yet',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.inkSoft)),
            SizedBox(height: 2),
            Text('Tap a place below or use Suggest',
                style: TextStyle(fontSize: 12.5, color: AppColors.inkMuted)),
          ],
        ),
      );
    }

    return Column(
      children: [
        for (int i = 0; i < _route.length; i++) _routeStopRow(i),
      ],
    );
  }

  Widget _routeStopRow(int i) {
    final place = _route[i].place;
    final isLast = i == _route.length - 1;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline rail
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: AppColors.mintDeep,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text('${i + 1}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800)),
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 2, color: AppColors.hairline),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.hairline),
                ),
                child: Row(
                  children: [
                    Icon(place.icon, size: 20, color: AppColors.mintDeep),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(place.label,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink)),
                          Text(place.tagline,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 11.5, color: AppColors.inkMuted)),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _removeStop(i),
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.close_rounded,
                          size: 18, color: AppColors.inkMuted),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _safetyNote() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.volunteer_activism_rounded,
            size: 16, color: AppColors.mintDeep),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Walk only where it is safe and comfortable for you. GeoFamiliar never rewards rushing, detours into risky places, or wandering late at night.',
            style: const TextStyle(
                fontSize: 11.5, height: 1.35, color: AppColors.inkMuted),
          ),
        ),
      ],
    );
  }
}

/// The "what changed" data captured the moment a walk is finished.
class _WalkRecap {
  const _WalkRecap({
    required this.memory,
    required this.lead,
    required this.leadGain,
    required this.walksThisWeek,
    required this.walksPerWeek,
    required this.weekReady,
  });

  final MemoryCard memory;
  final DnaTrait lead;
  final double leadGain;
  final int walksThisWeek;
  final int walksPerWeek;
  final bool weekReady;
}

/// Bottom sheet shown after a walk - celebrates the memory AND makes the reward
/// legible: the top DNA gained, this week's progress, and the new diary line.
class _WalkRecapSheet extends StatelessWidget {
  const _WalkRecapSheet({required this.recap});

  final _WalkRecap recap;

  @override
  Widget build(BuildContext context) {
    final memory = recap.memory;
    final lead = recap.lead;
    final progress = (recap.walksThisWeek / recap.walksPerWeek).clamp(0.0, 1.0);

    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 14, 20, 28 + MediaQuery.of(context).viewInsets.bottom),
      constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.86),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.hairline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: lead.color.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_rounded, size: 32, color: lead.color),
          ),
          const SizedBox(height: 14),
          Text('Walk complete',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 4),
          const Text('Here is what changed',
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.inkMuted)),
          const SizedBox(height: 16),

          // What changed: top trait gain + weekly progress.
          Row(
            children: [
              Expanded(
                child: _changeTile(
                  icon: lead.icon,
                  color: lead.color,
                  big: '+${recap.leadGain.toStringAsFixed(0)}',
                  label: '${lead.label} gained',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _changeTile(
                  icon: Icons.eco_rounded,
                  color: AppColors.mintDeep,
                  big: '${recap.walksThisWeek}/${recap.walksPerWeek}',
                  label: 'Week progress',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                Container(height: 10, color: AppColors.surfaceAlt),
                FractionallySizedBox(
                  widthFactor: progress == 0 ? 0.04 : progress,
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [AppColors.mint, AppColors.amber]),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (recap.weekReady) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.amber.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.amber.withValues(alpha: 0.4)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.celebration_rounded, size: 18, color: AppColors.coralDeep),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Weekly evolution is ready - claim your card in the Evolve tab.',
                      style: TextStyle(
                          fontSize: 12.5, height: 1.3, fontWeight: FontWeight.w600,
                          color: AppColors.inkSoft),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),

          // The new memory.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(memory.icon, size: 18, color: lead.color),
                    const SizedBox(width: 8),
                    Text('${memory.dayLabel}  -  ${memory.title}',
                        style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.inkMuted)),
                  ],
                ),
                const SizedBox(height: 10),
                Text('"${memory.diary}"',
                    style: const TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        fontStyle: FontStyle.italic,
                        color: AppColors.ink)),
              ],
            ),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.mintDeep,
              foregroundColor: Colors.white,
            ),
            child: const Text('Lovely'),
          ),
          ],
        ),
      ),
    );
  }

  Widget _changeTile({
    required IconData icon,
    required Color color,
    required String big,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 5),
              Text(big,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink)),
            ],
          ),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.inkMuted)),
        ],
      ),
    );
  }
}
