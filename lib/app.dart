import 'package:flutter/material.dart';

import 'screens/map_screen.dart';
import 'state/app_scope.dart';
import 'state/app_state.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';

/// Root of the app. Wraps the tree in an [AppScope] and routes between the
/// first-run hatch flow and the main home shell.
class GeoFamiliarApp extends StatelessWidget {
  const GeoFamiliarApp({
    super.key,
    required this.state,
    this.showMapTiles = true,
  });

  final AppState state;
  final bool showMapTiles;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: state,
      child: MaterialApp(
        title: 'GeoFamiliar 生活圏の相棒',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: _RootGate(showMapTiles: showMapTiles),
      ),
    );
  }
}

/// Decides the first screen: a brief loading state, then either onboarding
/// (no companion yet) or the home shell.
class _RootGate extends StatelessWidget {
  const _RootGate({required this.showMapTiles});

  final bool showMapTiles;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);

    if (state.loading) {
      return const Scaffold(
        backgroundColor: AppColors.cream,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.mintDeep),
        ),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: MapScreen(key: const ValueKey('map'), showTiles: showMapTiles),
    );
  }
}
