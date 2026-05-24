import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jonssony/data/bls_local_visuals.dart';
import 'package:jonssony/widgets/canvas_sprite_visual.dart';
import 'package:jonssony/widgets/white_key_asset_image.dart';

/// Plays local visuals during bilateral sessions.
class AssetAnimatedVisual extends StatelessWidget {
  const AssetAnimatedVisual({
    super.key,
    required this.assetPath,
    required this.size,
    required this.playing,
    this.fit = BoxFit.contain,
    this.mirror = false,
    this.stripWhiteBackground = true,
  });

  final String assetPath;
  final double size;
  final bool playing;
  final BoxFit fit;
  final bool mirror;
  final bool stripWhiteBackground;

  @override
  Widget build(BuildContext context) {
    final visual = resolveLocalVisual(assetPath);
    if (visual?.usesSpriteFrames == true) {
      return CanvasSpriteVisual(
        frameAssets: visual!.spriteFrameAssets,
        size: size,
        playing: playing,
        fps: visual.fps,
        mirror: mirror,
      );
    }

    final resolvedPath = resolveLocalVisualAsset(assetPath);
    return SizedBox.square(
      dimension: size,
      child: TickerMode(
        enabled: playing,
        child: WhiteKeyAssetImage(
          assetPath: resolvedPath,
          fit: fit,
          width: size,
          height: size,
          enabled: stripWhiteBackground,
        ),
      ),
    );
  }
}

class AssetAnimatedVisualLayer extends StatelessWidget {
  const AssetAnimatedVisualLayer({
    super.key,
    required this.assetPath,
    required this.size,
    required this.playingListenable,
    this.fit = BoxFit.contain,
    this.mirror = false,
    this.stripWhiteBackground = true,
  });

  final String assetPath;
  final double size;
  final ValueListenable<bool> playingListenable;
  final BoxFit fit;
  final bool mirror;
  final bool stripWhiteBackground;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: playingListenable,
      builder: (context, playing, _) {
        return AssetAnimatedVisual(
          key: ValueKey('$assetPath|$mirror'),
          assetPath: assetPath,
          size: size,
          playing: playing,
          fit: fit,
          mirror: mirror,
          stripWhiteBackground: stripWhiteBackground,
        );
      },
    );
  }
}
