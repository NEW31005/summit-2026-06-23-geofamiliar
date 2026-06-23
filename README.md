# GeoFamiliar

**Walk through real places and grow an AI companion shaped by the life you actually live.**

GeoFamiliar turns ordinary movement into a character-growing loop. The places you pass
through - a station, a riverside, a late-night store - become **Life DNA** that shapes a
companion's personality, mood, memories, and weekly evolution. The point is not "where did I
go?" but "what kind of companion is being born from my everyday life?"

> Status: this is a **demo / prototype build**. Location, weather, AI text, accounts and
> payments are all **simulated** - there is no real GPS, backend, or charge. The experience is
> intentionally complete and persistent so it feels real to play.

---

## The core loop

1. **Hatch** - scan today's place context (place + time of day + weather) and meet a companion
   born from it. The reveal shows *why* it got its first traits.
2. **Home** - see your companion, its mood and stage, today's Life DNA, and weekly progress.
3. **Walk** - build a gentle route of places you pass through. Each stop adds Life DNA.
4. **Memory** - finishing a walk writes a diary line in the companion's voice and shows what
   changed (top trait gained, weekly progress, the new memory).
5. **DNA / Evolution / Premium** - watch traits accumulate on a trait wheel, claim a weekly
   evolution card, and preview the premium value.

## Life DNA

Six trait axes - **Vitality, Calm, Curiosity, Warmth, Focus, Wonder** - are nudged by every
place, time and weather context. The blend gives the companion its personality, its "form"
(Driftling, Sparkling, Seekling ...), its mood, and its eventual evolution stage
(Hatchling -> Wanderer -> Kindred -> Luminary).

## Privacy & safety stance

- **Simulated location only.** No real GPS is requested in this build. Any future real-location
  feature would be strictly opt-in and treated as private/local data.
- **No unsafe movement incentives.** The game never rewards speed, distance, risky detours,
  trespassing, night wandering, or repeated loops. Walk only where it is safe for you.
- **Warm, never manipulative.** The companion invites; it does not guilt. Premium unlocks depth
  and expression, never a penalty for playing free.
- **Curated text.** Memory lines come from curated templates, not free-form generation, so the
  content stays family-safe.

## Tech

- Flutter (stable) + Dart, Material 3 with custom UI.
- Lightweight local state: `ChangeNotifier` + a small `InheritedNotifier` scope. No external
  state-management package.
- Local persistence via `shared_preferences`.
- Custom-painted companion and DNA radar (`CustomPainter`) - no image assets required.
- Official target is Android/iOS native mobile; Flutter Web is used as the verification preview.

## Run it

From the project root:

```bash
flutter pub get
flutter run            # choose a device, or: flutter run -d chrome
```

## Verify it

```bash
flutter pub get
flutter analyze
flutter test
flutter build web
```

## Project layout

```
lib/
  main.dart, app.dart
  models/    dna_trait, contexts, life_dna, walk, memory_card, evolution, companion
  logic/     dna_engine, memory_generator, evolution_engine   (pure, unit-tested)
  state/     app_state, app_scope, persistence
  theme/     app_colors, app_theme
  widgets/   companion_avatar, companion_panel, dna_radar, dna_widgets,
             selectors, section_header, misc_widgets, app_background
  screens/   hatch, home_shell, home, walk, dna, memories, evolution, premium
test/        dna_engine, memory_generator, evolution_engine, widget/app-state loop
```

## Demo limitations

- Location, weather, AI generation, authentication, backend and payments are mocked.
- Premium "unlock" is a labelled demo toggle - no real transaction occurs.
- Inheritance / legacy is surfaced as a premium teaser, not yet a playable mechanic.
- Real-GPS, push notifications and account sync are intentionally out of scope for this build.
