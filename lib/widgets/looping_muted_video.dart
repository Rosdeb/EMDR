import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class LoopingMutedVideo extends StatefulWidget {
  const LoopingMutedVideo({
    super.key,
    required this.url,
    this.fallbackUrls = const [],
    this.fit = BoxFit.contain,
    this.autoplay = true,
    this.playing = true,
    this.fallback,
    this.loadTimeout = const Duration(seconds: 8),
    this.onAllCandidatesFailed,
  });

  final String url;
  final List<String> fallbackUrls;
  final BoxFit fit;
  final bool autoplay;
  final bool playing;
  final Widget? fallback;
  final Duration loadTimeout;
  final VoidCallback? onAllCandidatesFailed;

  @override
  State<LoopingMutedVideo> createState() => _LoopingMutedVideoState();
}

class _LoopingMutedVideoState extends State<LoopingMutedVideo> {
  VideoPlayerController? _controller;
  Future<void>? _initialise;
  bool _failed = false;
  int _candidateIndex = 0;
  late List<String> _candidates;

  @override
  void initState() {
    super.initState();
    _candidates = _buildCandidates();
    _loadVideo();
  }

  @override
  void didUpdateWidget(covariant LoopingMutedVideo oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextCandidates = _buildCandidates();
    if (!_sameCandidates(nextCandidates, _candidates)) {
      _candidates = nextCandidates;
      _candidateIndex = 0;
      unawaited(_disposeController());
      _failed = false;
      _loadVideo();
      return;
    }

    if (widget.playing != oldWidget.playing) {
      unawaited(_syncPlayback());
    } else if (widget.autoplay && !oldWidget.autoplay) {
      unawaited(_syncPlayback());
    } else if (!widget.autoplay && oldWidget.autoplay) {
      unawaited(_controller?.pause());
    }
  }

  List<String> _buildCandidates() {
    final urls = <String>[];
    void add(String value) {
      final trimmed = value.trim();
      if (trimmed.isNotEmpty && !urls.contains(trimmed)) {
        urls.add(trimmed);
      }
    }

    add(widget.url);
    for (final url in widget.fallbackUrls) {
      add(url);
    }
    return urls;
  }

  bool _sameCandidates(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  String? get _currentUrl {
    if (_candidateIndex >= _candidates.length) return null;
    return _candidates[_candidateIndex];
  }

  void _loadVideo() {
    final source = _currentUrl;
    if (source == null) {
      setState(() => _failed = true);
      return;
    }

    final controller = source.startsWith('assets/')
        ? VideoPlayerController.asset(source)
        : VideoPlayerController.networkUrl(Uri.parse(source));

    _controller = controller;
    _initialise = controller
        .initialize()
        .timeout(widget.loadTimeout)
        .then((_) async {
          await controller.setLooping(true);
          await controller.setVolume(0);
          await _syncPlayback();
          if (mounted) setState(() {});
        })
        .catchError((_) async {
          await controller.dispose();
          if (!mounted) return;
          if (_candidateIndex + 1 < _candidates.length) {
            _candidateIndex++;
            _loadVideo();
            return;
          }
          setState(() => _failed = true);
          widget.onAllCandidatesFailed?.call();
        });
  }

  Future<void> _syncPlayback() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    if (widget.autoplay && widget.playing) {
      if (!controller.value.isPlaying) {
        await controller.play();
      }
    } else {
      await controller.pause();
    }
  }

  Future<void> _disposeController() async {
    final controller = _controller;
    _controller = null;
    _initialise = null;
    await controller?.dispose();
  }

  @override
  void dispose() {
    unawaited(_disposeController());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) {
      return widget.fallback ?? const SizedBox.shrink();
    }

    final controller = _controller;
    final initialise = _initialise;
    if (controller == null || initialise == null) {
      return widget.fallback ??
          const Center(
            child: SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
    }

    return FutureBuilder<void>(
      future: initialise,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done ||
            !controller.value.isInitialized) {
          return widget.fallback ??
              const Center(
                child: SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
        }

        return ValueListenableBuilder<VideoPlayerValue>(
          valueListenable: controller,
          builder: (context, value, child) {
            return FittedBox(
              fit: widget.fit,
              child: SizedBox(
                width: value.size.width,
                height: value.size.height,
                child: child,
              ),
            );
          },
          child: VideoPlayer(controller),
        );
      },
    );
  }
}

/// Keeps a session video widget stable while the parent animates movement.
class StableSessionVideo extends StatelessWidget {
  const StableSessionVideo({
    super.key,
    required this.url,
    this.fallbackUrls = const [],
    required this.size,
    required this.playing,
    this.fallback,
  });

  final String url;
  final List<String> fallbackUrls;
  final double size;
  final bool playing;
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: LoopingMutedVideo(
        key: ValueKey('$url:${fallbackUrls.join('|')}'),
        url: url,
        fallbackUrls: fallbackUrls,
        fit: BoxFit.contain,
        autoplay: true,
        playing: playing,
        fallback: fallback,
      ),
    );
  }
}

class StableSessionVideoLayer extends StatelessWidget {
  const StableSessionVideoLayer({
    super.key,
    required this.url,
    this.fallbackUrls = const [],
    required this.size,
    required this.playingListenable,
    this.fallback,
  });

  final String url;
  final List<String> fallbackUrls;
  final double size;
  final ValueListenable<bool> playingListenable;
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: playingListenable,
      builder: (context, playing, _) {
        return StableSessionVideo(
          url: url,
          fallbackUrls: fallbackUrls,
          size: size,
          playing: playing,
          fallback: fallback,
        );
      },
    );
  }
}
