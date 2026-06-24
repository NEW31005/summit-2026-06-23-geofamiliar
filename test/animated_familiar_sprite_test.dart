import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geofamiliar/models/dna_trait.dart';
import 'package:geofamiliar/widgets/animated_familiar_sprite.dart';

void main() {
  testWidgets('AnimatedFamiliarSprite advances through visible frames', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(
          child: AnimatedFamiliarSprite(
            trait: DnaTrait.calm,
            seed: 0,
            size: 64,
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('familiar-sprite-calm-normal')),
      findsOneWidget,
    );

    await tester.pump(const Duration(milliseconds: 340));

    expect(
      find.byKey(const ValueKey('familiar-sprite-calm-happy')),
      findsOneWidget,
    );

    await tester.pump(const Duration(milliseconds: 660));

    expect(
      find.byKey(const ValueKey('familiar-sprite-calm-rest')),
      findsOneWidget,
    );
  });
}
