import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

/// Canvas sprite player — same idea as the HTML `createPlayer()` export.
class CanvasSpriteVisual extends StatefulWidget {
  const CanvasSpriteVisual({
    super.key,
    required this.frameAssets,
    required this.size,
    required this.playing,
    this.fps = 12,
    this.mirror = false,
  });

  final List<String> frameAssets;
  final double size;
  final bool playing;
  final double fps;
  final bool mirror;

  @override
  State<CanvasSpriteVisual> createState() => _CanvasSpriteVisualState();
}

class _CanvasSpriteVisualState extends State<CanvasSpriteVisual>
    with SingleTickerProviderStateMixin {
  List<ui.Image>? _frames;
  Ticker? _ticker;
  var _index = 0;
  var _frameAccumulator = 0.0;
  Duration _lastTick = Duration.zero;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    unawaited(_loadFrames());
  }

  @override
  void didUpdateWidget(covariant CanvasSpriteVisual oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.frameAssets, widget.frameAssets)) {
      _stopTicker();
      _disposeFrames();
      _index = 0;
      _frameAccumulator = 0;
      _lastTick = Duration.zero;
      unawaited(_loadFrames());
      return;
    }
    if (oldWidget.playing != widget.playing || oldWidget.fps != widget.fps) {
      _syncTicker();
    }
  }

  @override
  void dispose() {
    _stopTicker();
    _disposeFrames();
    super.dispose();
  }

  Future<void> _loadFrames() async {
    if (!mounted) return;
    if (_frames == null || _frames!.isEmpty) {
      setState(() => _loading = true);
    }

    final loaded = await Future.wait(
      widget.frameAssets.map(_decodeFrame),
      eagerError: false,
    );

    final frames = loaded.whereType<ui.Image>().toList(growable: false);
    if (!mounted) {
      for (final image in frames) {
        image.dispose();
      }
      return;
    }

    if (frames.isEmpty) {
      setState(() => _loading = false);
      return;
    }

    final previous = _frames;
    setState(() {
      _frames = frames;
      _index = 0;
      _frameAccumulator = 0;
      _lastTick = Duration.zero;
      _loading = false;
    });
    if (previous != null) {
      for (final image in previous) {
        image.dispose();
      }
    }
    _syncTicker();
  }

  Future<ui.Image?> _decodeFrame(String asset) async {
    try {
      final data = await rootBundle.load(asset);
      final codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(),
      );
      final frame = await codec.getNextFrame();
      return frame.image;
    } catch (_) {
      return null;
    }
  }

  void _disposeFrames() {
    final frames = _frames;
    if (frames == null) return;
    for (final image in frames) {
      image.dispose();
    }
    _frames = null;
  }

  void _syncTicker() {
    if (!mounted) return;
    if (widget.playing && (_frames?.isNotEmpty ?? false)) {
      _lastTick = Duration.zero;
      _ticker?.start();
      return;
    }
    _stopTicker();
  }

  void _stopTicker() {
    _ticker?.stop();
  }

  void _onTick(Duration elapsed) {
    final frames = _frames;
    if (!widget.playing || frames == null || frames.isEmpty) return;

    if (_lastTick == Duration.zero) {
      _lastTick = elapsed;
      return;
    }

    final deltaSeconds = (elapsed - _lastTick).inMicroseconds / 1000000.0;
    _lastTick = elapsed;
    if (deltaSeconds <= 0) return;

    _frameAccumulator += deltaSeconds;
    final frameDuration = 1.0 / widget.fps;
    var advanced = false;
    while (_frameAccumulator >= frameDuration) {
      _frameAccumulator -= frameDuration;
      _index = (_index + 1) % frames.length;
      advanced = true;
    }

    if (advanced && mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final frames = _frames;
    if (_loading || frames == null || frames.isEmpty) {
      return SizedBox.square(dimension: widget.size);
    }

    return RepaintBoundary(
      child: SizedBox.square(
        dimension: widget.size,
        child: CustomPaint(
          isComplex: true,
          willChange: true,
          painter: _SpritePainter(
            image: frames[_index],
            mirror: widget.mirror,
          ),
        ),
      ),
    );
  }
}

class CanvasSpriteVisualLayer extends StatelessWidget {
  const CanvasSpriteVisualLayer({
    super.key,
    required this.frameAssets,
    required this.size,
    required this.playingListenable,
    this.fps = 12,
    this.mirror = false,
  });

  final List<String> frameAssets;
  final double size;
  final ValueListenable<bool> playingListenable;
  final double fps;
  final bool mirror;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: playingListenable,
      builder: (context, playing, _) {
        return CanvasSpriteVisual(
          key: ValueKey(frameAssets.join('|')),
          frameAssets: frameAssets,
          size: size,
          playing: playing,
          fps: fps,
          mirror: mirror,
        );
      },
    );
  }
}

class _SpritePainter extends CustomPainter {
  const _SpritePainter({required this.image, required this.mirror});

  final ui.Image image;
  final bool mirror;

  @override
  void paint(Canvas canvas, Size size) {
    final src = Rect.fromLTWH(
      0,
      0,
      image.width.toDouble(),
      image.height.toDouble(),
    );

    final scale = math.min(size.width / src.width, size.height / src.height);
    final dstWidth = src.width * scale;
    final dstHeight = src.height * scale;
    final dst = Rect.fromLTWH(
      (size.width - dstWidth) / 2,
      (size.height - dstHeight) / 2,
      dstWidth,
      dstHeight,
    );

    final paint = Paint()
      ..isAntiAlias = true
      ..filterQuality = FilterQuality.high
      ..blendMode = BlendMode.srcOver;

    if (mirror) {
      canvas.save();
      canvas.translate(size.width, 0);
      canvas.scale(-1, 1);
      canvas.drawImageRect(image, src, dst, paint);
      canvas.restore();
      return;
    }

    canvas.drawImageRect(image, src, dst, paint);
  }

  @override
  bool shouldRepaint(covariant _SpritePainter oldDelegate) {
    return oldDelegate.image != image || oldDelegate.mirror != mirror;
  }
}
