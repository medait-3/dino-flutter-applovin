import 'package:flame/components.dart';

import '../constant/animation_state.dart';

class AssetManager {
  /// Image assets.
  static const images = [
    'DinoSprites - tard.png',
    'AngryPig/Walk (36x30).png',
    'Bat/Flying (46x30).png',
    'Rino/Run (52x34).png',
    'game/bg.png',
    'game/road.png',
  ];

  /// Audio assets
  static const audios = [
    'start.mp3',
    'hurt.mp3',
    'jump.mp3',
  ];

  /// Parallax background
  static const background = [
    'game/bg.png',
    'game/road.png',
  ];

  static final animation = {
    TRexAnimationState.idle: SpriteAnimationData.sequenced(
      amount: 4,
      stepTime: 0.1,
      textureSize: Vector2.all(24),
    ),
    TRexAnimationState.run: SpriteAnimationData.sequenced(
      amount: 6,
      stepTime: 0.1,
      textureSize: Vector2.all(24),
      texturePosition: Vector2((4) * 24, 0),
    ),
    TRexAnimationState.kick: SpriteAnimationData.sequenced(
      amount: 4,
      stepTime: 0.1,
      textureSize: Vector2.all(24),
      texturePosition: Vector2((4 + 6) * 24, 0),
    ),
    TRexAnimationState.hit: SpriteAnimationData.sequenced(
      amount: 3,
      stepTime: 0.1,
      textureSize: Vector2.all(24),
      texturePosition: Vector2((4 + 6 + 4) * 24, 0),
    ),
    TRexAnimationState.sprint: SpriteAnimationData.sequenced(
      amount: 7,
      stepTime: 0.1,
      textureSize: Vector2.all(24),
      texturePosition: Vector2((4 + 6 + 4 + 3) * 24, 0),
    ),
  };
}
