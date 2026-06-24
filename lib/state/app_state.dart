import 'package:flutter/foundation.dart';

import '../logic/evolution_engine.dart';
import '../logic/memory_generator.dart';
import '../models/companion.dart';
import '../models/contexts.dart';
import '../models/evolution.dart';
import '../models/life_dna.dart';
import '../models/map_familiar.dart';
import '../models/map_spot.dart';
import '../models/memory_card.dart';
import '../models/place_context.dart';
import '../models/walk.dart';
import '../services/entitlement_service.dart';
import 'persistence.dart';

/// The single source of truth for the running game. A lightweight
/// [ChangeNotifier] - no external state-management package, per spec.
class AppState extends ChangeNotifier {
  AppState();

  Companion _companion = Companion.egg();
  final List<MemoryCard> _memories = [];
  final List<WeeklyCard> _weeklyCards = [];
  final List<MapFamiliar> _familiars = [];
  LifeDna _weekDna = LifeDna.empty();
  int _memoriesThisWeek = 0;
  bool _isPremium = false;
  bool _premiumTeaserSeen = false;
  bool _loading = true;

  Companion get companion => _companion;
  List<MemoryCard> get memories => List.unmodifiable(_memories);
  List<WeeklyCard> get weeklyCards => List.unmodifiable(_weeklyCards);
  List<MapFamiliar> get familiars => List.unmodifiable(_familiars);
  Set<String> get capturedSpotIds =>
      _familiars.map((familiar) => familiar.spotId).toSet();
  LifeDna get weekDna => _weekDna;
  int get memoriesThisWeek => _memoriesThisWeek;
  bool get isPremium => _isPremium;
  bool get premiumTeaserSeen => _premiumTeaserSeen;
  bool get loading => _loading;

  bool get hasHatched => _companion.hatched;
  int get walksRemaining =>
      EvolutionEngine.walksRemaining(_companion.walksThisWeek);

  /// Load any saved game from local storage.
  Future<void> init() async {
    final snapshot = await Persistence.load();
    if (snapshot != null) {
      _companion = snapshot.companion;
      _memories
        ..clear()
        ..addAll(snapshot.memories);
      _weeklyCards
        ..clear()
        ..addAll(snapshot.weeklyCards);
      _familiars
        ..clear()
        ..addAll(snapshot.familiars);
      _weekDna = snapshot.weekDna;
      _memoriesThisWeek = snapshot.memoriesThisWeek;
      _isPremium = snapshot.isPremium;
      _premiumTeaserSeen = snapshot.premiumTeaserSeen;
    }
    _loading = false;
    notifyListeners();
  }

  /// Hatch the companion from the first scanned place context.
  /// Returns the very first memory the companion writes.
  MemoryCard hatch(
    PlaceType place,
    TimeContext time,
    WeatherContext weather, {
    PlaceContext? placeContext,
  }) {
    final firstStop = RouteStop(place, context: placeContext);
    final seedDna = Walk(stops: [firstStop], time: time, weather: weather).dna;
    _companion = Companion(
      id: 'companion-1',
      name: '', // set below from its form
      generation: 1,
      visualSeed: place.index + 1,
      dna: seedDna,
      totalWalks: 0,
      walksThisWeek: 0,
      week: 1,
      hatched: true,
      lastPlace: place,
      lastTime: time,
      lastWeather: weather,
    );
    _companion.name = _companion.formName;

    _weekDna = seedDna;

    final firstWalk = Walk(stops: [firstStop], time: time, weather: weather);
    final memory = MemoryGenerator.generate(
      firstWalk,
      seed: place.index + 3,
      dayIndex: 1,
      premium: _isPremium,
    );
    _memories.insert(0, memory);
    _memoriesThisWeek = 1;

    _persist();
    notifyListeners();
    return memory;
  }

  /// Complete a simulated walk: grow the companion and write a new memory.
  MemoryCard completeWalk(Walk walk) {
    final walkDna = walk.dna;
    _companion.dna = _companion.dna.combine(walkDna);
    _companion.totalWalks += 1;
    _companion.walksThisWeek += 1;
    if (walk.stops.isNotEmpty) {
      _companion.lastPlace = walk.stops.last.place;
    }
    _companion.lastTime = walk.time;
    _companion.lastWeather = walk.weather;

    _weekDna = _weekDna.combine(walkDna);

    final dayIndex = _memories.length + 1;
    final memory = MemoryGenerator.generate(
      walk,
      seed: _companion.totalWalks * 7 + walk.stops.length,
      dayIndex: dayIndex,
      premium: _isPremium,
    );
    _memories.insert(0, memory);
    _memoriesThisWeek += 1;

    _persist();
    notifyListeners();
    return memory;
  }

  MapFamiliar? collectSpot(
    MapSpot spot, {
    TimeContext? time,
    WeatherContext weather = WeatherContext.clear,
    PlaceContext? placeContext,
  }) {
    if (capturedSpotIds.contains(spot.id)) return null;

    final resolvedTime =
        time ??
        TimeContext.fromName(DateTime.now().hour < 16 ? 'noon' : 'sunset');
    final context = placeContext ?? spot.toPlaceContext();
    final stop = RouteStop(spot.place, context: context);
    final walk = Walk(stops: [stop], time: resolvedTime, weather: weather);

    if (!hasHatched) {
      hatch(spot.place, resolvedTime, weather, placeContext: context);
    } else {
      completeWalk(walk);
    }

    final familiar = MapFamiliar(
      id: 'familiar-${_familiars.length + 1}',
      spotId: spot.id,
      latitude: spot.latitude,
      longitude: spot.longitude,
      place: spot.place,
      acquiredAt: DateTime.now(),
      visualSeed: spot.place.index + _familiars.length + 1,
    );
    _familiars.insert(0, familiar);

    _persist();
    notifyListeners();
    return familiar;
  }

  /// Claim the weekly evolution card once enough walks are lived. Returns null
  /// if the week is not ready yet.
  WeeklyCard? claimWeeklyEvolution() {
    if (!_companion.weekReady) return null;
    final card = EvolutionEngine.buildWeeklyCard(
      week: _companion.week,
      totalWalksBefore: _companion.totalWalks - _companion.walksThisWeek,
      walksThisWeek: _companion.walksThisWeek,
      memoriesThisWeek: _memoriesThisWeek,
      weekDna: _weekDna,
    );
    _weeklyCards.insert(0, card);
    _companion.week += 1;
    _companion.walksThisWeek = 0;
    _weekDna = LifeDna.empty();
    _memoriesThisWeek = 0;

    _persist();
    notifyListeners();
    return card;
  }

  void renameCompanion(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    _companion.name = trimmed;
    _persist();
    notifyListeners();
  }

  /// Mock premium unlock (no real payment in first build).
  void setPremium(bool value) {
    _isPremium = value;
    _premiumTeaserSeen = true;
    _persist();
    notifyListeners();
  }

  Future<EntitlementResult> purchasePremiumDemo({
    EntitlementService service = const DemoEntitlementService(),
  }) async {
    final result = await service.purchasePremium();
    _applyEntitlement(result);
    return result;
  }

  Future<EntitlementResult> restorePremiumDemo({
    EntitlementService service = const DemoEntitlementService(),
  }) async {
    final result = await service.restorePremium();
    _applyEntitlement(result);
    return result;
  }

  Future<EntitlementResult> cancelPremiumDemo({
    EntitlementService service = const DemoEntitlementService(),
  }) async {
    final result = await service.cancelPremium();
    _applyEntitlement(result);
    return result;
  }

  void dismissPremiumTeaser() {
    _premiumTeaserSeen = true;
    _persist();
    notifyListeners();
  }

  void _applyEntitlement(EntitlementResult result) {
    _isPremium = result.isActive;
    _premiumTeaserSeen = true;
    _persist();
    notifyListeners();
  }

  /// Start over from a fresh egg.
  Future<void> resetGame() async {
    _companion = Companion.egg();
    _memories.clear();
    _weeklyCards.clear();
    _familiars.clear();
    _weekDna = LifeDna.empty();
    _memoriesThisWeek = 0;
    _isPremium = false;
    _premiumTeaserSeen = false;
    await Persistence.clear();
    notifyListeners();
  }

  void _persist() {
    Persistence.save(
      GameSnapshot(
        companion: _companion,
        memories: _memories,
        weeklyCards: _weeklyCards,
        weekDna: _weekDna,
        familiars: _familiars,
        memoriesThisWeek: _memoriesThisWeek,
        isPremium: _isPremium,
        premiumTeaserSeen: _premiumTeaserSeen,
      ),
    );
  }
}
