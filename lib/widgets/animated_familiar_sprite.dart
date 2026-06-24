import 'dart:async';

import 'package:flutter/material.dart';

import '../models/dna_trait.dart';

class AnimatedFamiliarSprite extends StatefulWidget {
  const AnimatedFamiliarSprite({
    super.key,
    required this.trait,
    required this.seed,
    this.size = 48,
  });

  final DnaTrait trait;
  final int seed;
  final double size;

  @override
  State<AnimatedFamiliarSprite> createState() => _AnimatedFamiliarSpriteState();
}

class _AnimatedFamiliarSpriteState extends State<AnimatedFamiliarSprite> {
  static const _frames = [
    _SpriteFrame('normal', 0, 1, 0),
    _SpriteFrame('happy', -3, 1.08, -0.08),
    _SpriteFrame('normal', 1, 1.02, 0.07),
    _SpriteFrame('rest', 3, 0.96, 0),
  ];

  Timer? _timer;
  int _tick = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 320), (_) {
      if (!mounted) return;
      setState(() => _tick++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 90),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: _buildFrame(_frames[(_tick + widget.seed) % _frames.length]),
      ),
    );
  }

  Widget _buildFrame(_SpriteFrame frame) {
    final path =
        'assets/companion/hatchling/${widget.trait.name}_${frame.assetKey}.png';

    return Transform.translate(
      key: ValueKey('familiar-sprite-${widget.trait.name}-${frame.assetKey}'),
      offset: Offset(0, widget.size * frame.yFactor / 48),
      child: Transform.rotate(
        angle: frame.turn,
        child: Transform.scale(
          scale: frame.scale,
          child: Image.asset(
            path,
            width: widget.size,
            height: widget.size,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            errorBuilder: (context, error, stackTrace) => Icon(
              Icons.auto_awesome_rounded,
              color: widget.trait.color,
              size: widget.size * 0.78,
            ),
          ),
        ),
      ),
    );
  }
}

class _SpriteFrame {
  const _SpriteFrame(this.assetKey, this.yFactor, this.scale, this.turn);

  final String assetKey;
  final double yFactor;
  final double scale;
  final double turn;
}
