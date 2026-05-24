import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jonssony/utils/transparent_media.dart';
import 'package:jonssony/widgets/looping_muted_video.dart';

enum SessionVisualKind { animatedImage, image, video }

class SessionVisualCandidate {
  const SessionVisualCandidate({
    required this.url,
    required this.kind,
    this.timeout = const Duration(seconds: 8),
  });

  final String url;
  final SessionVisualKind kind;
  final Duration timeout;
}

/// Session visual that prefers transparent animated GIF/WebP over alpha video.
class TransparentSessionVisual extends StatefulWidget {
  const TransparentSessionVisual({
    super.key,
    required this.candidates,
    required this.size,
    required this.playing,
    this.fallback,
  });

  final List<SessionVisualCandidate> candidates;
  final double size;
  final bool playing;
  final Widget? fallback;

  @override
  State<TransparentSessionVisual> createState() =>
      _TransparentSessionVisualState();
}

class _TransparentSessionVisualState extends State<TransparentSessionVisual> {
  int _candidateIndex = 0;
  bool _imageFailed = false;

  SessionVisualCandidate? get _current {
    if (_candidateIndex >= widget.candidates.length) return null;
    return widget.candidates[_candidateIndex];
  }

  void _advanceCandidate() {
    if (!mounted) return;
    final next = _candidateIndex + 1;
    if (next < widget.candidates.length) {
      setState(() {
        _candidateIndex = next;
        _imageFailed = false;
      });
    } else {
      setState(() => _imageFailed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final candidate = _current;
    if (candidate == null || _imageFailed) {
      return widget.fallback ?? const SizedBox.shrink();
    }

    return SizedBox.square(
      dimension: widget.size,
      child: switch (candidate.kind) {
        SessionVisualKind.animatedImage || SessionVisualKind.image =>
          _AnimatedImageCandidate(
            key: ValueKey(candidate.url),
            url: candidate.url,
            timeout: candidate.timeout,
            playing: widget.playing,
            onFailed: _advanceCandidate,
            placeholder: widget.fallback,
          ),
        SessionVisualKind.video => LoopingMutedVideo(
          key: ValueKey(candidate.url),
          url: candidate.url,
          fit: BoxFit.contain,
          playing: widget.playing,
          loadTimeout: candidate.timeout,
          onAllCandidatesFailed: _advanceCandidate,
          fallback: widget.fallback,
        ),
      },
    );
  }
}

class TransparentSessionVisualLayer extends StatelessWidget {
  const TransparentSessionVisualLayer({
    super.key,
    required this.candidates,
    required this.size,
    required this.playingListenable,
    this.fallback,
  });

  final List<SessionVisualCandidate> candidates;
  final double size;
  final ValueListenable<bool> playingListenable;
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: playingListenable,
      builder: (context, playing, _) {
        return TransparentSessionVisual(
          candidates: candidates,
          size: size,
          playing: playing,
          fallback: fallback,
        );
      },
    );
  }
}

class _AnimatedImageCandidate extends StatefulWidget {
  const _AnimatedImageCandidate({
    super.key,
    required this.url,
    required this.timeout,
    required this.playing,
    required this.onFailed,
    this.placeholder,
  });

  final String url;
  final Duration timeout;
  final bool playing;
  final VoidCallback onFailed;
  final Widget? placeholder;

  @override
  State<_AnimatedImageCandidate> createState() =>
      _AnimatedImageCandidateState();
}

class _AnimatedImageCandidateState extends State<_AnimatedImageCandidate> {
  Timer? _timeoutTimer;
  bool _loaded = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _timeoutTimer = Timer(widget.timeout, () {
      if (!mounted || _loaded || _failed) return;
      _fail();
    });
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
  }

  void _fail() {
    if (_failed) return;
    _failed = true;
    _timeoutTimer?.cancel();
    widget.onFailed();
  }

  void _markLoaded() {
    if (_loaded || _failed) return;
    _loaded = true;
    _timeoutTimer?.cancel();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) {
      return widget.placeholder ?? const SizedBox.shrink();
    }

    return TickerMode(
      enabled: widget.playing,
      child: CachedNetworkImage(
        imageUrl: widget.url,
        fit: BoxFit.contain,
        fadeInDuration: Duration.zero,
        fadeOutDuration: Duration.zero,
        placeholder: (context, url) =>
            widget.placeholder ??
            const Center(
              child: SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        errorWidget: (context, url, error) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _fail());
          return widget.placeholder ?? const SizedBox.shrink();
        },
        imageBuilder: (context, imageProvider) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _markLoaded());
          return Image(
            image: imageProvider,
            fit: BoxFit.contain,
            gaplessPlayback: true,
          );
        },
      ),
    );
  }
}

List<SessionVisualCandidate> buildSessionVisualCandidates({
  required String source,
  String? transparentUrl,
  String? label,
  String mediaType = 'video',
}) {
  final results = <SessionVisualCandidate>[];
  void add(
    String value,
    SessionVisualKind kind, {
    Duration timeout = const Duration(seconds: 8),
  }) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    if (results.any((entry) => entry.url == trimmed)) return;
    results.add(
      SessionVisualCandidate(url: trimmed, kind: kind, timeout: timeout),
    );
  }

  SessionVisualKind kindForUrl(String url) {
    final path = mediaPath(url);
    if (path.endsWith('.gif') ||
        path.endsWith('.webp') ||
        path.contains('f_gif') ||
        path.contains('fl_animated')) {
      return SessionVisualKind.animatedImage;
    }
    if (looksLikeVideoMedia(url)) {
      return SessionVisualKind.video;
    }
    return SessionVisualKind.image;
  }

  final trimmed = source.trim();
  if (trimmed.startsWith('assets/')) {
    add(trimmed, kindForUrl(trimmed));
    return results;
  }

  final trimmedTransparent = transparentUrl?.trim() ?? '';
  if (trimmedTransparent.isNotEmpty) {
    add(
      trimmedTransparent,
      kindForUrl(trimmedTransparent),
      timeout: kindForUrl(trimmedTransparent) == SessionVisualKind.video
          ? const Duration(seconds: 6)
          : const Duration(seconds: 12),
    );
  }

  final raw = stripCloudinaryVideoTransforms(source);
  final isVideo = mediaType.toLowerCase() == 'video' || looksLikeVideoMedia(raw);

  if (isCloudinaryUrl(raw) && raw.contains('/video/upload/') && isVideo) {
    add(
      cloudinaryAnimatedTransparentGif(raw),
      SessionVisualKind.animatedImage,
      timeout: const Duration(seconds: 14),
    );
    add(
      cloudinaryAnimatedTransparentWebp(raw),
      SessionVisualKind.animatedImage,
      timeout: const Duration(seconds: 14),
    );
    add(
      cloudinaryTransparentVideoFrame(raw),
      SessionVisualKind.image,
      timeout: const Duration(seconds: 8),
    );
    add(raw, SessionVisualKind.video, timeout: const Duration(seconds: 10));
  } else if (isVideo) {
    add(raw, SessionVisualKind.video, timeout: const Duration(seconds: 10));
  } else {
    add(
      resolveTransparentVisualUrl(
        source,
        label: label,
        mediaType: mediaType,
      ),
      SessionVisualKind.image,
    );
  }

  return results;
}
