import 'dart:math' as math;

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

class _AnimatedFamiliarSpriteState extends State<AnimatedFamiliarSprite>
    with SingleTickerProviderStateMixin {
  static const _frames = ['normal', 'happy', 'normal', 'rest'];

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 960),
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
          final phase = (_controller.value + (widget.seed % 11) * 0.037) % 1.0;
          final frame = _frames[(phase * _frames.length).floor()];
          final bob = math.sin(phase * math.pi * 2) * widget.size * 0.05;
          final squash = math.sin(phase * math.pi * 2) * 0.025;
          final path =
              'assets/companion/hatchling/${widget.trait.name}_$frame.png';

          return Transform.translate(
            offset: Offset(0, bob),
            child: Transform.scale(
              scaleX: 1 + squash,
              scaleY: 1 - squash,
              child: Image.asset(
                path,
                key: ValueKey('familiar-sprite-${widget.trait.name}-$frame'),
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
          );
        },
      ),
    );
  }
}
