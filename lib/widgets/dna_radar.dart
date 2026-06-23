import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/dna_trait.dart';
import '../models/life_dna.dart';
import '../theme/app_colors.dart';

/// A six-axis radar chart of the companion's Life DNA. Gives the DNA screen a
/// game-like "trait wheel" rather than a flat list.
class DnaRadar extends StatelessWidget {
  const DnaRadar({super.key, required this.dna, this.size = 240});

  final LifeDna dna;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RadarPainter(dna),
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  _RadarPainter(this.dna);

  final LifeDna dna;
  static final _traits = DnaTrait.values;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.34;
    final n = _traits.length;

    // Grid rings
    final gridPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = AppColors.hairline;
    for (int ring = 1; ring <= 3; ring++) {
      final r = radius * ring / 3;
      final path = Path();
      for (int i = 0; i <= n; i++) {
        final a = _angle(i % n);
        final p = center + Offset(math.cos(a), math.sin(a)) * r;
        if (i == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      canvas.drawPath(path, gridPaint);
    }

    // Spokes + labels
    final spokePaint = Paint()
      ..strokeWidth = 1
      ..color = AppColors.hairline;
    for (int i = 0; i < n; i++) {
      final a = _angle(i);
      final edge = center + Offset(math.cos(a), math.sin(a)) * radius;
      canvas.drawLine(center, edge, spokePaint);

      final labelPos = center + Offset(math.cos(a), math.sin(a)) * (radius + 20);
      _drawLabel(canvas, _traits[i], labelPos);
    }

    // Data polygon
    final hasData = dna.sum > 0;
    final dataPath = Path();
    for (int i = 0; i < n; i++) {
      final trait = _traits[i];
      final value = hasData ? dna.relative(trait).clamp(0.12, 1.0) : 0.12;
      final a = _angle(i);
      final p = center + Offset(math.cos(a), math.sin(a)) * radius * value;
      if (i == 0) {
        dataPath.moveTo(p.dx, p.dy);
      } else {
        dataPath.lineTo(p.dx, p.dy);
      }
    }
    dataPath.close();

    final dom = hasData ? dna.dominant.color : AppColors.mint;
    canvas.drawPath(
      dataPath,
      Paint()
        ..style = PaintingStyle.fill
        ..color = dom.withValues(alpha: 0.22),
    );
    canvas.drawPath(
      dataPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round
        ..color = dom.withValues(alpha: 0.9),
    );

    // Vertices
    for (int i = 0; i < n; i++) {
      final trait = _traits[i];
      final value = hasData ? dna.relative(trait).clamp(0.12, 1.0) : 0.12;
      final a = _angle(i);
      final p = center + Offset(math.cos(a), math.sin(a)) * radius * value;
      canvas.drawCircle(p, 3.5, Paint()..color = trait.color);
    }
  }

  double _angle(int i) => -math.pi / 2 + (2 * math.pi * i / _traits.length);

  void _drawLabel(Canvas canvas, DnaTrait trait, Offset pos) {
    final tp = TextPainter(
      text: TextSpan(
        text: trait.short,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Color.lerp(trait.color, AppColors.ink, 0.35),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(_RadarPainter old) => old.dna != dna;
}
