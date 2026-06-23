import 'package:flutter/material.dart';

import 'screens/hatch_screen.dart';
import 'screens/home_shell.dart';
import 'state/app_scope.dart';
import 'state/app_state.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';

/// Root of the app. Wraps the tree in an [AppScope] and routes between the
/// first-run hatch flow and the main home shell.
class GeoFamiliarApp extends StatelessWidget {
  const GeoFamiliarApp({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: state,
      child: MaterialApp(
        title: 'GeoFamiliar',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const _RootGate(),
      ),
    );
  }
}

/// Decides the first screen: a brief loading state, then either onboarding
/// (no companion yet) or the home shell.
class _RootGate extends StatelessWidget {
  const _RootGate();

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
      duration: const Duration(milliseconds: 400),
      child: state.hasHatched
          ? const HomeShell(key: ValueKey('home'))
          : const HatchScreen(key: ValueKey('hatch')),
    );
  }
}
