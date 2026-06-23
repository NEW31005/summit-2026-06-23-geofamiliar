import 'package:flutter/material.dart';

import '../state/app_scope.dart';
import '../theme/app_colors.dart';
import 'dna_screen.dart';
import 'evolution_screen.dart';
import 'home_screen.dart';
import 'memories_screen.dart';
import 'premium_screen.dart';
import 'walk_screen.dart';

/// The main app frame after hatching: five primary destinations behind a custom
/// bottom navigation bar. Premium is reachable from the app bar and Home banner.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _destinations = [
    _Dest('ホーム', Icons.home_rounded, Icons.home_outlined),
    _Dest('さんぽ', Icons.directions_walk_rounded, Icons.directions_walk_outlined),
    _Dest('DNA', Icons.science_rounded, Icons.science_outlined),
    _Dest('記憶', Icons.auto_stories_rounded, Icons.auto_stories_outlined),
    _Dest('進化', Icons.eco_rounded, Icons.eco_outlined),
  ];

  void _goTo(int i) => setState(() => _index = i);

  void _openPremium() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const PremiumScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(onNavigate: _goTo, onOpenPremium: _openPremium),
      const WalkScreen(),
      const DnaScreen(),
      const MemoriesScreen(),
      EvolutionScreen(onOpenPremium: _openPremium),
    ];

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        bottom: false,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: KeyedSubtree(key: ValueKey(_index), child: pages[_index]),
        ),
      ),
      bottomNavigationBar: _BottomBar(
        destinations: _destinations,
        index: _index,
        onTap: _goTo,
      ),
    );
  }
}

class _Dest {
  const _Dest(this.label, this.active, this.inactive);
  final String label;
  final IconData active;
  final IconData inactive;
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.destinations,
    required this.index,
    required this.onTap,
  });

  final List<_Dest> destinations;
  final int index;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    // Premium owners get a subtle crown accent on the bar.
    final isPremium = AppScope.of(context).isPremium;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.hairline)),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(destinations.length, (i) {
              final d = destinations[i];
              final selected = i == index;
              final accent = isPremium
                  ? AppColors.coralDeep
                  : AppColors.mintDeep;
              return Expanded(
                child: InkWell(
                  onTap: () => onTap(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? accent.withValues(alpha: 0.14)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          selected ? d.active : d.inactive,
                          size: 22,
                          color: selected ? accent : AppColors.inkMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        d.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: selected ? accent : AppColors.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
