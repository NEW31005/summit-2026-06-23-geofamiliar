import 'package:flutter/material.dart';

import '../models/contexts.dart';
import '../models/dna_trait.dart';
import '../models/map_familiar.dart';
import '../theme/app_colors.dart';
import '../widgets/animated_familiar_sprite.dart';

class FamiliarDetailScreen extends StatelessWidget {
  const FamiliarDetailScreen({
    super.key,
    required this.familiar,
    required this.trait,
  });

  final MapFamiliar familiar;
  final DnaTrait trait;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      appBar: AppBar(
        title: const Text('相棒'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.ink,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: trait.color.withValues(alpha: 0.22),
                          blurRadius: 28,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: AnimatedFamiliarSprite(
                        trait: trait,
                        seed: familiar.visualSeed,
                        size: 144,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    _placeTitle(familiar.place),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _placeCopy(familiar.place),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.inkMuted,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String _placeTitle(PlaceType place) {
  return switch (place) {
    PlaceType.station => '駅前で出会った相棒',
    PlaceType.park => '公園で出会った相棒',
    PlaceType.office => '仕事場の近くで出会った相棒',
    PlaceType.river => '水辺で出会った相棒',
    PlaceType.cafe => 'カフェで出会った相棒',
    PlaceType.residential => 'いつもの道で出会った相棒',
    PlaceType.shopping => '商店街で出会った相棒',
    PlaceType.nightStore => 'コンビニの近くで出会った相棒',
    PlaceType.travel => '旅先で出会った相棒',
  };
}

String _placeCopy(PlaceType place) {
  return switch (place) {
    PlaceType.station => '人の流れと出発の気配から、元気な子が寄ってきた。',
    PlaceType.park => 'ひらけた緑とゆっくりした空気から、おだやかな子が来た。',
    PlaceType.office => '集中した時間の近くで、きりっとした子が目を覚ました。',
    PlaceType.river => '流れる水のそばで、静かな気配の子が生まれた。',
    PlaceType.cafe => 'あたたかい休憩の場所で、やわらかな子が来た。',
    PlaceType.residential => '見慣れた道の安心感から、なつく子が顔を出した。',
    PlaceType.shopping => 'にぎわいと発見の中から、好奇心の強い子が来た。',
    PlaceType.nightStore => '夜の小さな明かりから、少し不思議な子が現れた。',
    PlaceType.travel => '知らない景色の入口で、冒険好きな子が寄ってきた。',
  };
}
