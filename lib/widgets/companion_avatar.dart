import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/dna_trait.dart';

/// The companion creature, drawn with [CustomPaint] so its colours, markings and
/// accessories shift with its Life DNA and evolution stage. A soft breathing +
/// bobbing animation keeps it alive.
///
/// Identity is layered so it reads as an ownable mascot, not a generic blob:
/// - body colour comes from the dominant trait, blended toward the secondary;
/// - a belly **marking** is shaped by the dominant trait (bolt, wave, heart...);
/// - **stage** adds legible accessories: a head sprout, a collar, then a crown,
///   plus growing aura rings.
///
/// Stable footprint: always lays out at [size] x [size]. Fully deterministic for
/// a given (primary, secondary, mood, stageRing, seed, phase).
class CompanionAvatar extends StatefulWidget {
  const CompanionAvatar({
    super.key,
    required this.primary,
    required this.secondary,
    required this.mood,
    required this.stageRing,
    required this.seed,
    this.size = 168,
    this.hatched = true,
    this.sparkle = false,
  });

  final DnaTrait primary;
  final DnaTrait secondary;
  final String mood;
  final int stageRing;
  final int seed;
  final double size;
  final bool hatched;
  final bool sparkle;

  @override
  State<CompanionAvatar> createState() => _CompanionAvatarState();
}

class _CompanionAvatarState extends State<CompanionAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          return CustomPaint(
            painter: _CompanionPainter(
              primaryTrait: widget.primary,
              primary: widget.primary.color,
              secondary: widget.secondary.color,
              mood: widget.mood,
              stageRing: widget.stageRing,
              seed: widget.seed,
              hatched: widget.hatched,
              sparkle: widget.sparkle,
              phase: t,
            ),
          );
        },
      ),
    );
  }
}

class _CompanionPainter extends CustomPainter {
  _CompanionPainter({
    required this.primaryTrait,
    required this.primary,
    required this.secondary,
    required this.mood,
    required this.stageRing,
    required this.seed,
    required this.hatched,
    required this.sparkle,
    required this.phase,
  });

  final DnaTrait primaryTrait;
  final Color primary;
  final Color secondary;
  final String mood;
  final int stageRing;
  final int seed;
  final bool hatched;
  final bool sparkle;
  final double phase;

  static const _ink = Color(0xFF1E2433);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final breathe = math.sin(phase * 2 * math.pi);
    final bob = breathe * h * 0.012;
    final scaleY = 1 + breathe * 0.015;

    final center = Offset(w / 2, h * 0.54 + bob);
    final bodyW = w * 0.56;
    final bodyH = h * 0.56 * scaleY;

    // Ground shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w / 2, h * 0.86),
        width: bodyW * (0.9 - breathe * 0.04),
        height: h * 0.06,
      ),
      shadowPaint,
    );

    if (!hatched) {
      _paintEgg(canvas, size, center, bodyW, bodyH);
      return;
    }

    // Aura rings grow with stage (legible progression).
    if (stageRing >= 2) {
      canvas.drawCircle(
        center,
        bodyW * 0.78,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = secondary.withValues(alpha: 0.25),
      );
    }
    if (stageRing >= 4) {
      final glow = 0.5 + 0.5 * math.sin(phase * 2 * math.pi);
      canvas.drawCircle(
        center,
        bodyW * 0.92,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = primary.withValues(alpha: 0.14 + glow * 0.16),
      );
    }

    // Head sprout (wanderer+) sits behind the body so it reads as growing out.
    if (stageRing >= 2) _paintSprout(canvas, center, bodyW, bodyH);

    // Ears / antennae - grow slightly longer with stage.
    final earGrow = 1 + (stageRing.clamp(1, 4) - 1) * 0.08;
    _paintEar(canvas, center, bodyW, bodyH, -1, earGrow);
    _paintEar(canvas, center, bodyW, bodyH, 1, earGrow);

    // Body (rounded blob with vertical gradient).
    final bodyRect = Rect.fromCenter(
      center: center,
      width: bodyW,
      height: bodyH,
    );
    final bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.lerp(primary, Colors.white, 0.18)!,
          primary,
          Color.lerp(primary, secondary, 0.35)!,
        ],
      ).createShader(bodyRect);
    final bodyPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(bodyRect, Radius.circular(bodyW * 0.5)),
      );
    canvas.drawPath(bodyPath, bodyPaint);

    // DNA-dependent dappling: faint trait-coloured patches over the body.
    _paintDappling(canvas, center, bodyW, bodyH);

    // Belly patch.
    final bellyPaint = Paint()..color = Colors.white.withValues(alpha: 0.24);
    final bellyRect = Rect.fromCenter(
      center: center.translate(0, bodyH * 0.13),
      width: bodyW * 0.52,
      height: bodyH * 0.46,
    );
    canvas.drawOval(bellyRect, bellyPaint);

    // Belly marking - shape is chosen by the dominant trait (core identity).
    _paintMarking(canvas, center.translate(0, bodyH * 0.15), bodyW, bodyH);

    // Cheeks.
    final cheekPaint = Paint()..color = secondary.withValues(alpha: 0.55);
    final cheekY = center.dy + bodyH * 0.04;
    canvas.drawCircle(
      Offset(center.dx - bodyW * 0.26, cheekY),
      bodyW * 0.07,
      cheekPaint,
    );
    canvas.drawCircle(
      Offset(center.dx + bodyW * 0.26, cheekY),
      bodyW * 0.07,
      cheekPaint,
    );

    // Collar / scarf (kindred+).
    if (stageRing >= 3) _paintCollar(canvas, center, bodyW, bodyH);

    // Face.
    _paintFace(canvas, center, bodyW, bodyH);

    // Crown (luminary).
    if (stageRing >= 4) _paintCrown(canvas, center, bodyW, bodyH);

    // Sparkles (premium / wonder / late stages).
    if (sparkle || stageRing >= 3) _paintSparkles(canvas, center, bodyW);
  }

  void _paintEgg(
    Canvas canvas,
    Size size,
    Offset center,
    double bodyW,
    double bodyH,
  ) {
    final eggRect = Rect.fromCenter(
      center: center,
      width: bodyW * 1.05,
      height: bodyH * 1.25,
    );
    final eggPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.white, const Color(0xFFEFF5F2)],
      ).createShader(eggRect);
    final path = Path()
      ..addRRect(
        RRect.fromRectAndCorners(
          eggRect,
          topLeft: Radius.circular(bodyW * 0.5),
          topRight: Radius.circular(bodyW * 0.5),
          bottomLeft: Radius.circular(bodyW * 0.42),
          bottomRight: Radius.circular(bodyW * 0.42),
        ),
      );
    canvas.drawPath(path, eggPaint);

    // Trait-tinted shell spots hint at the DNA waiting inside.
    final spot = Paint()..color = secondary.withValues(alpha: 0.5);
    canvas.drawCircle(
      center.translate(-bodyW * 0.18, -bodyH * 0.1),
      bodyW * 0.06,
      spot,
    );
    canvas.drawCircle(
      center.translate(bodyW * 0.16, bodyH * 0.12),
      bodyW * 0.05,
      spot,
    );
    canvas.drawCircle(
      center.translate(bodyW * 0.05, -bodyH * 0.28),
      bodyW * 0.04,
      Paint()..color = primary.withValues(alpha: 0.5),
    );

    // Gentle pulse outline.
    final glow = 0.5 + 0.5 * math.sin(phase * 2 * math.pi);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = primary.withValues(alpha: 0.25 + glow * 0.25),
    );
  }

  void _paintEar(
    Canvas canvas,
    Offset center,
    double bodyW,
    double bodyH,
    int side,
    double grow,
  ) {
    final base = Offset(
      center.dx + side * bodyW * 0.22,
      center.dy - bodyH * 0.46,
    );
    final tip = Offset(
      base.dx + side * bodyW * 0.12,
      base.dy - bodyH * 0.28 * grow,
    );
    canvas.drawLine(
      base,
      tip,
      Paint()
        ..strokeWidth = bodyW * 0.06
        ..strokeCap = StrokeCap.round
        ..color = Color.lerp(primary, secondary, 0.4)!,
    );
    canvas.drawCircle(tip, bodyW * 0.05, Paint()..color = secondary);
  }

  /// Faint trait-coloured patches over the body so two companions with different
  /// DNA never look identical even at the same dominant colour.
  void _paintDappling(
    Canvas canvas,
    Offset center,
    double bodyW,
    double bodyH,
  ) {
    final rnd = math.Random(seed * 31 + primaryTrait.index);
    final patch = Paint()..color = secondary.withValues(alpha: 0.18);
    final count = 3 + (seed % 3);
    for (int i = 0; i < count; i++) {
      final ax = (rnd.nextDouble() - 0.5) * bodyW * 0.6;
      final ay = (rnd.nextDouble() - 0.55) * bodyH * 0.5;
      final r = bodyW * (0.05 + rnd.nextDouble() * 0.05);
      canvas.drawCircle(center.translate(ax, ay), r, patch);
    }
  }

  /// The belly emblem - its silhouette is the companion's dominant trait.
  void _paintMarking(Canvas canvas, Offset c, double bodyW, double bodyH) {
    final color = Color.lerp(secondary, _ink, 0.18)!.withValues(alpha: 0.85);
    final s = bodyW * 0.13;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = bodyW * 0.03
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..color = color;
    final fill = Paint()
      ..style = PaintingStyle.fill
      ..color = color;

    switch (primaryTrait) {
      case DnaTrait.vitality:
        // Lightning bolt.
        final p = Path()
          ..moveTo(c.dx + s * 0.3, c.dy - s)
          ..lineTo(c.dx - s * 0.4, c.dy + s * 0.15)
          ..lineTo(c.dx + s * 0.05, c.dy + s * 0.15)
          ..lineTo(c.dx - s * 0.3, c.dy + s);
        canvas.drawPath(p, stroke);
        break;
      case DnaTrait.calm:
        // Two calm waves.
        for (int row = 0; row < 2; row++) {
          final y = c.dy - s * 0.35 + row * s * 0.7;
          final p = Path()..moveTo(c.dx - s, y);
          p.cubicTo(
            c.dx - s * 0.4,
            y - s * 0.5,
            c.dx + s * 0.4,
            y + s * 0.5,
            c.dx + s,
            y,
          );
          canvas.drawPath(p, stroke);
        }
        break;
      case DnaTrait.curiosity:
        // A small constellation of dots.
        final rnd = math.Random(seed + 7);
        for (int i = 0; i < 5; i++) {
          final ax = (rnd.nextDouble() - 0.5) * s * 2;
          final ay = (rnd.nextDouble() - 0.5) * s * 2;
          canvas.drawCircle(c.translate(ax, ay), bodyW * 0.018, fill);
        }
        break;
      case DnaTrait.warmth:
        // Heart.
        final p = Path()
          ..moveTo(c.dx, c.dy + s * 0.8)
          ..cubicTo(
            c.dx - s * 1.4,
            c.dy - s * 0.2,
            c.dx - s * 0.2,
            c.dy - s * 0.9,
            c.dx,
            c.dy - s * 0.25,
          )
          ..cubicTo(
            c.dx + s * 0.2,
            c.dy - s * 0.9,
            c.dx + s * 1.4,
            c.dy - s * 0.2,
            c.dx,
            c.dy + s * 0.8,
          );
        canvas.drawPath(p, fill);
        break;
      case DnaTrait.focus:
        // Diamond.
        final p = Path()
          ..moveTo(c.dx, c.dy - s)
          ..lineTo(c.dx + s * 0.7, c.dy)
          ..lineTo(c.dx, c.dy + s)
          ..lineTo(c.dx - s * 0.7, c.dy)
          ..close();
        canvas.drawPath(p, stroke);
        break;
      case DnaTrait.wonder:
        // Four-point star.
        _drawSparkStar(canvas, c, s, fill);
        break;
    }
  }

  void _paintSprout(Canvas canvas, Offset center, double bodyW, double bodyH) {
    final stemTop = Offset(center.dx, center.dy - bodyH * 0.62);
    final stemBase = Offset(center.dx, center.dy - bodyH * 0.5);
    canvas.drawLine(
      stemBase,
      stemTop,
      Paint()
        ..strokeWidth = bodyW * 0.035
        ..strokeCap = StrokeCap.round
        ..color = Color.lerp(secondary, const Color(0xFF2BB99A), 0.5)!,
    );
    final leaf = Paint()..color = const Color(0xFF4DD0B1);
    canvas.drawOval(
      Rect.fromCenter(
        center: stemTop.translate(-bodyW * 0.05, 0),
        width: bodyW * 0.12,
        height: bodyW * 0.07,
      ),
      leaf,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: stemTop.translate(bodyW * 0.05, -bodyH * 0.02),
        width: bodyW * 0.12,
        height: bodyW * 0.07,
      ),
      leaf,
    );
  }

  void _paintCollar(Canvas canvas, Offset center, double bodyW, double bodyH) {
    final y = center.dy + bodyH * 0.30;
    final rect = Rect.fromCenter(
      center: Offset(center.dx, y),
      width: bodyW * 0.66,
      height: bodyH * 0.10,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(bodyH * 0.05)),
      Paint()
        ..color = Color.lerp(secondary, _ink, 0.1)!.withValues(alpha: 0.85),
    );
    // Little tag.
    canvas.drawCircle(
      Offset(center.dx, y + bodyH * 0.02),
      bodyW * 0.03,
      Paint()..color = primary,
    );
  }

  void _paintCrown(Canvas canvas, Offset center, double bodyW, double bodyH) {
    final y = center.dy - bodyH * 0.5;
    final crown = Paint()..color = const Color(0xFFFFC04D);
    for (int i = -1; i <= 1; i++) {
      canvas.drawCircle(
        Offset(center.dx + i * bodyW * 0.12, y - (i == 0 ? bodyH * 0.05 : 0)),
        bodyW * (i == 0 ? 0.035 : 0.028),
        crown,
      );
    }
  }

  void _paintFace(Canvas canvas, Offset center, double bodyW, double bodyH) {
    final eyeY = center.dy - bodyH * 0.06;
    final eyeDx = bodyW * 0.16;
    final eyeR = bodyW * 0.09;

    final whitePaint = Paint()..color = Colors.white;
    final pupilPaint = Paint()..color = _ink;

    final happy = mood == 'ぬくぬく' || mood == 'そわそわ' || mood == 'ほっとしている';
    final dreamy = mood == 'うっとり';

    for (final side in [-1, 1]) {
      final eyeC = Offset(center.dx + side * eyeDx, eyeY);
      if (dreamy) {
        final p = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = bodyW * 0.03
          ..strokeCap = StrokeCap.round
          ..color = _ink;
        final path = Path()
          ..moveTo(eyeC.dx - eyeR, eyeC.dy)
          ..quadraticBezierTo(
            eyeC.dx,
            eyeC.dy + eyeR * 0.9,
            eyeC.dx + eyeR,
            eyeC.dy,
          );
        canvas.drawPath(path, p);
      } else {
        canvas.drawCircle(eyeC, eyeR, whitePaint);
        canvas.drawCircle(
          eyeC.translate(side * eyeR * 0.15, eyeR * 0.12),
          eyeR * 0.55,
          pupilPaint,
        );
        canvas.drawCircle(
          eyeC.translate(-eyeR * 0.2, -eyeR * 0.25),
          eyeR * 0.22,
          Paint()..color = Colors.white,
        );
      }
    }

    // Mouth.
    final mouthPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = bodyW * 0.028
      ..strokeCap = StrokeCap.round
      ..color = _ink;
    final mouthY = center.dy + bodyH * 0.12;
    final mouth = Path();
    if (happy || dreamy) {
      mouth
        ..moveTo(center.dx - bodyW * 0.08, mouthY)
        ..quadraticBezierTo(
          center.dx,
          mouthY + bodyH * 0.06,
          center.dx + bodyW * 0.08,
          mouthY,
        );
    } else {
      mouth
        ..moveTo(center.dx - bodyW * 0.06, mouthY)
        ..quadraticBezierTo(
          center.dx,
          mouthY + bodyH * 0.03,
          center.dx + bodyW * 0.06,
          mouthY,
        );
    }
    canvas.drawPath(mouth, mouthPaint);
  }

  void _paintSparkles(Canvas canvas, Offset center, double bodyW) {
    final rnd = math.Random(seed);
    for (int i = 0; i < 4; i++) {
      final angle = rnd.nextDouble() * 2 * math.pi;
      final dist = bodyW * (0.7 + rnd.nextDouble() * 0.5);
      final twinkle = (math.sin((phase * 2 * math.pi) + i) + 1) / 2;
      final pos = Offset(
        center.dx + math.cos(angle) * dist,
        center.dy + math.sin(angle) * dist * 0.7,
      );
      final r = bodyW * (0.02 + 0.02 * twinkle);
      final p = Paint()
        ..color = secondary.withValues(alpha: 0.4 + twinkle * 0.5)
        ..strokeWidth = r * 0.5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      _drawSparkStar(canvas, pos, r, p, stroke: true);
    }
  }

  void _drawSparkStar(
    Canvas canvas,
    Offset c,
    double r,
    Paint paint, {
    bool stroke = false,
  }) {
    if (stroke) {
      final path = Path();
      for (int i = 0; i < 4; i++) {
        final a = i * math.pi / 2;
        path.moveTo(c.dx, c.dy);
        path.lineTo(c.dx + math.cos(a) * r, c.dy + math.sin(a) * r);
      }
      canvas.drawPath(path, paint);
      return;
    }
    // Filled four-point star.
    final path = Path();
    for (int i = 0; i < 4; i++) {
      final a = i * math.pi / 2;
      final aNext = (i + 0.5) * math.pi / 2;
      if (i == 0) path.moveTo(c.dx + r, c.dy);
      path.lineTo(
        c.dx + math.cos(aNext) * r * 0.36,
        c.dy + math.sin(aNext) * r * 0.36,
      );
      path.lineTo(
        c.dx + math.cos(a + math.pi / 2) * r,
        c.dy + math.sin(a + math.pi / 2) * r,
      );
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CompanionPainter old) =>
      old.phase != phase ||
      old.primaryTrait != primaryTrait ||
      old.primary != primary ||
      old.secondary != secondary ||
      old.mood != mood ||
      old.hatched != hatched ||
      old.stageRing != stageRing;
}
