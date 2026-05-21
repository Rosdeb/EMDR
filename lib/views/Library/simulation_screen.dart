import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'bls_pdf_visuals.dart';
import 'simulation_settings.dart';

class SimulationScreen extends StatefulWidget {
  final SimulationSettings settings;
  const SimulationScreen({super.key, required this.settings});

  @override
  State<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends State<SimulationScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late AnimationController _wingController;
  late Animation<double> _wingAnimation;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayer _tonePlayer = AudioPlayer();

  Timer? _setTimer;
  late Duration _setDuration;
  late Duration _remainingSetTime;
  int _moveCount = 0;
  bool _isPaused = false; // Track pause state
  bool _isReversing = false; // Track animation direction
  bool _setComplete = false;
  bool _showCompletionQuestions = false;
  bool _hasAudioSource = false;
  bool? _firstCompletionAnswer;
  bool? _secondCompletionAnswer;
  bool _showSecondCompletionQuestion = false;

  static const Map<String, _HtmlToneProfile> _htmlToneProfiles = {
    'gentle-tone': _HtmlToneProfile(432, 528, 0.04, 0.25, 0.025),
    'soft-chime': _HtmlToneProfile(660, 880, 0.01, 0.45, 0.018),
    'water': _HtmlToneProfile(340, 400, 0.02, 0.2, 0.022),
    'breath': _HtmlToneProfile(180, 180, 0.15, 0.45, 0.028),
    'bowl': _HtmlToneProfile(396, 528, 0.05, 0.8, 0.02),
  };

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    _setDuration = _resolveSetDuration();
    _remainingSetTime = _setDuration;
    _controller = AnimationController(
      duration: Duration(milliseconds: (widget.settings.speed * 1000).toInt()),
      vsync: this,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _isReversing = true;
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _isReversing = false;
        _controller.forward();
      }
    });

    _animation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

    _wingController = AnimationController(
      duration: const Duration(milliseconds: 360),
      vsync: this,
    );
    _wingAnimation = CurvedAnimation(
      parent: _wingController,
      curve: Curves.easeInOut,
    );

    if (widget.settings.showCompletionQuestions) {
      Future.delayed(const Duration(milliseconds: 500), _startMotion);
    } else {
      _startMotion();
    }
  }

  void _startMotion() {
    if (!mounted || _setComplete || _isPaused) return;
    _controller.forward();
    if (_shouldFlapWings) {
      _wingController.repeat(reverse: true);
    }
    if (!_usesHtmlTone) {
      _setupAudio();
    }
    _startSetTimer();
  }

  bool get _usesHtmlTone =>
      widget.settings.soundKey.isNotEmpty && widget.settings.soundKey != 'none';

  Duration _resolveSetDuration() {
    if (widget.settings.totalSets > 0) {
      final totalMoves = widget.settings.totalSets * 2;
      final milliseconds = (widget.settings.speed * 1000 * totalMoves).round();
      return Duration(milliseconds: milliseconds < 1000 ? 1000 : milliseconds);
    }

    return const Duration(seconds: 45);
  }

  void _startSetTimer() {
    _setTimer?.cancel();
    if (_setComplete || _isPaused) return;

    if (widget.settings.totalSets > 0) {
      final totalMoves = widget.settings.totalSets * 2;
      final step = Duration(
        milliseconds: (widget.settings.speed * 1000).round().clamp(1, 10000),
      );

      _registerBlsMove(step, totalMoves);
      _setTimer = Timer.periodic(
        step,
        (_) => _registerBlsMove(step, totalMoves),
      );
      return;
    }

    _setTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_remainingSetTime.inSeconds <= 1) {
        unawaited(_completeSet());
        return;
      }
      setState(() {
        _remainingSetTime -= const Duration(seconds: 1);
      });
    });
  }

  void _registerBlsMove(Duration step, int totalMoves) {
    if (!mounted || _setComplete || _isPaused) return;
    if (_moveCount >= totalMoves) {
      unawaited(_completeSet());
      return;
    }

    setState(() {
      _moveCount++;
      final remainingMs =
          _setDuration.inMilliseconds - (step.inMilliseconds * _moveCount);
      _remainingSetTime = Duration(
        milliseconds: remainingMs < 0 ? 0 : remainingMs,
      );
    });

    if (_usesHtmlTone) {
      unawaited(_playHtmlTone(isRight: _moveCount.isOdd));
    }

    if (_moveCount >= totalMoves) {
      unawaited(_completeSet());
    }
  }

  Future<void> _completeSet() async {
    if (!mounted || _setComplete) return;
    _setTimer?.cancel();
    _controller.stop();
    _wingController.stop();
    await _audioPlayer.pause();
    await _tonePlayer.stop();
    if (!mounted) return;
    if (widget.settings.showCompletionQuestions) {
      setState(() {
        _showCompletionQuestions = true;
        _isPaused = true;
        _remainingSetTime = Duration.zero;
      });
      return;
    }

    setState(() {
      _setComplete = true;
      _isPaused = true;
      _remainingSetTime = Duration.zero;
    });
  }

  Future<void> _setupAudio() async {
    try {
      if (widget.settings.audioAsset.isEmpty) return;

      if (_isNetworkUrl(widget.settings.audioAsset)) {
        await _audioPlayer.setSource(UrlSource(widget.settings.audioAsset));
      } else if (widget.settings.requireNetworkAudio) {
        debugPrint('Skipping non-API bilateral audio source.');
        return;
      } else {
        String assetPath = widget.settings.audioAsset;
        if (assetPath.startsWith('assets/')) {
          assetPath = assetPath.substring(7);
        }
        await _audioPlayer.setSource(AssetSource(assetPath));
      }
      _hasAudioSource = true;
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);

      _controller.addListener(() {
        if (mounted && !_isPaused) _audioPlayer.setBalance(_animation.value);
      });
      await _audioPlayer.resume();
    } catch (e) {
      debugPrint("Audio Error: $e");
    }
  }

  Future<void> _playHtmlTone({required bool isRight}) async {
    final profile = _htmlToneProfiles[widget.settings.soundKey];
    if (profile == null) return;

    final frequency = isRight ? profile.rightFrequency : profile.leftFrequency;
    final bytes = _buildToneWav(
      frequency: frequency,
      attackSeconds: profile.attackSeconds,
      decaySeconds: profile.decaySeconds,
      volume: profile.volume,
    );

    try {
      await _tonePlayer.stop();
      await _tonePlayer.play(BytesSource(bytes, mimeType: 'audio/wav'));
    } catch (e) {
      debugPrint('Tone Error: $e');
    }
  }

  Uint8List _buildToneWav({
    required double frequency,
    required double attackSeconds,
    required double decaySeconds,
    required double volume,
  }) {
    const sampleRate = 44100;
    const channels = 1;
    const bitsPerSample = 16;
    final durationSeconds = math.max(decaySeconds, attackSeconds + 0.05) + 0.05;
    final sampleCount = (sampleRate * durationSeconds).ceil();
    final dataSize = sampleCount * channels * (bitsPerSample ~/ 8);
    final bytes = ByteData(44 + dataSize);

    void writeAscii(int offset, String value) {
      for (var i = 0; i < value.length; i++) {
        bytes.setUint8(offset + i, value.codeUnitAt(i));
      }
    }

    writeAscii(0, 'RIFF');
    bytes.setUint32(4, 36 + dataSize, Endian.little);
    writeAscii(8, 'WAVE');
    writeAscii(12, 'fmt ');
    bytes.setUint32(16, 16, Endian.little);
    bytes.setUint16(20, 1, Endian.little);
    bytes.setUint16(22, channels, Endian.little);
    bytes.setUint32(24, sampleRate, Endian.little);
    bytes.setUint32(
      28,
      sampleRate * channels * (bitsPerSample ~/ 8),
      Endian.little,
    );
    bytes.setUint16(32, channels * (bitsPerSample ~/ 8), Endian.little);
    bytes.setUint16(34, bitsPerSample, Endian.little);
    writeAscii(36, 'data');
    bytes.setUint32(40, dataSize, Endian.little);

    final decayWindow = math.max(decaySeconds - attackSeconds, 0.001);
    for (var i = 0; i < sampleCount; i++) {
      final t = i / sampleRate;
      final envelope = t < attackSeconds
          ? (attackSeconds <= 0 ? 1.0 : t / attackSeconds)
          : t < decaySeconds
          ? 1.0 - ((t - attackSeconds) / decayWindow)
          : 0.0;
      final value = math.sin(2 * math.pi * frequency * t) * volume * envelope;
      final sample = (value * 32767).clamp(-32768, 32767).round();
      bytes.setInt16(44 + (i * 2), sample, Endian.little);
    }

    return bytes.buffer.asUint8List();
  }

  bool _isNetworkUrl(String value) {
    final uri = Uri.tryParse(value.trim());
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  Future<void> _restartSet() async {
    _setTimer?.cancel();
    await _audioPlayer.pause();
    await _tonePlayer.stop();
    if (!mounted) return;

    setState(() {
      _showCompletionQuestions = false;
      _firstCompletionAnswer = null;
      _secondCompletionAnswer = null;
      _showSecondCompletionQuestion = false;
      _setComplete = false;
      _isPaused = false;
      _remainingSetTime = _setDuration;
      _moveCount = 0;
      _isReversing = false;
    });

    _controller.reset();
    if (widget.settings.showCompletionQuestions) {
      Future.delayed(const Duration(milliseconds: 500), _startMotion);
    } else {
      _startMotion();
    }
  }

  Future<void> _handleFirstCompletionAnswer(bool answer) async {
    setState(() {
      _firstCompletionAnswer = answer;
    });
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() {
      _showSecondCompletionQuestion = true;
    });
  }

  Future<void> _handleSecondCompletionAnswer(bool answer) async {
    setState(() {
      _secondCompletionAnswer = answer;
    });
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    if (_firstCompletionAnswer == true && answer) {
      await _restartSet();
      return;
    }

    if (!mounted) return;
    Navigator.pop(context, false);
  }

  void _togglePause() {
    if (_showCompletionQuestions) return;

    if (_setComplete) {
      Navigator.pop(context);
      return;
    }

    setState(() {
      _isPaused = !_isPaused;
      if (_isPaused) {
        _setTimer?.cancel();
        _controller.stop();
        if (_shouldFlapWings) {
          _wingController.stop();
        }
        _audioPlayer.pause();
        _tonePlayer.stop();
      } else {
        if (_isReversing) {
          _controller.reverse();
        } else {
          _controller.forward();
        }
        if (_shouldFlapWings) {
          _wingController.repeat(reverse: true);
        }
        if (_hasAudioSource) {
          _audioPlayer.resume();
        }
        _startSetTimer();
      }
    });
  }

  Alignment _getAlignment(double value) {
    final t = (value + 1) / 2;
    double lerp(double start, double end) => start + ((end - start) * t);

    switch (widget.settings.direction) {
      case AnimationDirection.vertical:
        return Alignment(0.0, lerp(-0.7, 0.4));
      case AnimationDirection.diagonal:
        return Alignment(lerp(-0.7, 0.7), lerp(-0.7, 0.1));
      case AnimationDirection.diagonalReverse:
        return Alignment(lerp(-0.7, 0.7), lerp(0.1, -0.7));
      case AnimationDirection.horizontal:
        return Alignment(lerp(-0.7, 0.7), _objectBaseAlignmentY);
    }
  }

  Alignment _getReflectionAlignment(double value) {
    final t = (value + 1) / 2;
    double lerp(double start, double end) => start + ((end - start) * t);

    switch (widget.settings.direction) {
      case AnimationDirection.vertical:
        return const Alignment(0, 0.72);
      case AnimationDirection.diagonal:
      case AnimationDirection.diagonalReverse:
      case AnimationDirection.horizontal:
        return Alignment(lerp(-0.7, 0.7), 0.72);
    }
  }

  double get _objectBaseAlignmentY {
    final visualObject = _resolvedVisualObject;
    if (!isBlsObjectSource(visualObject)) return -0.4;

    switch (blsSourceId(visualObject)) {
      case 'moon':
        return -0.7;
      case 'sun':
      case 'star':
        return -0.64;
      case 'bird':
        return -0.56;
      case 'feather':
        return -0.48;
      case 'butterfly':
      case 'dragonfly':
        return -0.4;
      case 'leaf':
        return -0.36;
      default:
        return -0.4;
    }
  }

  bool get _hasObjectReflection =>
      blsObjectHasReflection(widget.settings.visualObject.trim());

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _controller.dispose();
    _wingController.dispose();
    _setTimer?.cancel();
    _audioPlayer.dispose();
    _tonePlayer.dispose();
    super.dispose();
  }

  Widget _buildBackground() {
    final background = isBlsSceneSource(widget.settings.environmentImage)
        ? BlsSceneCanvas(source: widget.settings.environmentImage)
        : widget.settings.environmentImage.startsWith('http')
        ? CachedNetworkImage(
            imageUrl: widget.settings.environmentImage,
            fit: BoxFit.cover,
            placeholder: (context, url) =>
                const Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) => Container(color: Colors.grey),
          )
        : Image.asset(widget.settings.environmentImage, fit: BoxFit.cover);

    return background;
  }

  String get _resolvedVisualObject {
    final visualObject = widget.settings.visualObject.trim();
    if (isBlsObjectSource(visualObject)) return visualObject;

    final lowerVisualObject = visualObject.toLowerCase();

    if (visualObject.isEmpty) {
      return '${blsObjectPrefix}sun';
    }

    if (lowerVisualObject.contains('butterfly.png') ||
        lowerVisualObject.contains('butterfly lottie') ||
        (lowerVisualObject.contains('butterfly') &&
            !lowerVisualObject.endsWith('.gif'))) {
      return '${blsObjectPrefix}butterfly';
    }

    return visualObject;
  }

  Widget _buildVisualObject({double? size}) {
    final visualObject = _resolvedVisualObject;
    final resolvedSize = size ?? _objectSize;

    if (isBlsObjectSource(visualObject)) {
      return BlsObjectCanvas(source: visualObject, size: resolvedSize);
    }

    if (visualObject.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: visualObject,
        width: resolvedSize,
        height: resolvedSize,
        fit: BoxFit.contain,
        placeholder: (context, url) => const SizedBox(
          width: 70,
          height: 70,
          child: CircularProgressIndicator(),
        ),
        errorWidget: (context, url, error) => const Icon(Icons.error, size: 70),
      );
    }

    return Image.asset(
      visualObject,
      width: resolvedSize,
      height: resolvedSize,
      fit: BoxFit.contain,
    );
  }

  double get _objectSize {
    final visualObject = _resolvedVisualObject;
    if (!isBlsObjectSource(visualObject)) return 74;

    switch (blsSourceId(visualObject)) {
      case 'sun':
        return 140;
      case 'moon':
      case 'butterfly':
        return 120;
      case 'bird':
        return 100;
      case 'leaf':
        return 90;
      case 'feather':
        return 105;
      case 'star':
        return 110;
      case 'dragonfly':
        return 130;
      default:
        return 110;
    }
  }

  bool get _shouldFlapWings {
    final visualObject = _resolvedVisualObject.toLowerCase();
    if (isBlsObjectSource(visualObject)) return false;
    return visualObject.contains('butterfly') && !visualObject.endsWith('.gif');
  }

  Widget _buildWingHalf({
    required bool isLeft,
    required double wingScale,
    required double wingAngle,
  }) {
    return Transform(
      alignment: isLeft ? Alignment.centerRight : Alignment.centerLeft,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateY(isLeft ? wingAngle : -wingAngle),
      child: Transform.scale(
        scaleX: wingScale,
        alignment: isLeft ? Alignment.centerRight : Alignment.centerLeft,
        child: ClipRect(
          child: Align(
            alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
            widthFactor: 0.5,
            child: _buildVisualObject(size: 74),
          ),
        ),
      ),
    );
  }

  Widget _buildButterflyBodyStrip() {
    return ClipRect(
      child: Align(widthFactor: 0.22, child: _buildVisualObject(size: 74)),
    );
  }

  Widget _buildFlappingButterfly() {
    final wingScale = 0.72 + (_wingAnimation.value * 0.34);
    final wingRise = (1 - _wingAnimation.value) * 3.5;
    final wingAngle = -0.42 + (_wingAnimation.value * 0.84);

    return SizedBox(
      width: 96,
      height: 88,
      child: Center(
        child: Transform.translate(
          offset: Offset(0, -wingRise),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildWingHalf(
                    isLeft: true,
                    wingScale: wingScale,
                    wingAngle: wingAngle,
                  ),
                  _buildWingHalf(
                    isLeft: false,
                    wingScale: wingScale,
                    wingAngle: wingAngle,
                  ),
                ],
              ),
              _buildButterflyBodyStrip(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedVisualObject() {
    final centerWeight = 1 - _animation.value.abs();
    final scale = 0.98 + (centerWeight * 0.08);
    final glowOpacity = 0.14 + (centerWeight * 0.1);

    return Transform.rotate(
      angle: _animation.value * 0.08,
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: _objectSize + 24,
          height: _objectSize + 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: glowOpacity),
                blurRadius: 28,
                spreadRadius: 8,
              ),
            ],
          ),
          child: _shouldFlapWings
              ? _buildFlappingButterfly()
              : _buildVisualObject(),
        ),
      ),
    );
  }

  Widget _buildObjectReflection() {
    return IgnorePointer(
      child: Opacity(
        opacity: 0.25,
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Transform.scale(
            scaleY: -0.35,
            child: _buildVisualObject(size: _objectSize),
          ),
        ),
      ),
    );
  }

  Widget _buildPaperTexture() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Opacity(
          opacity: 0.04,
          child: CustomPaint(painter: _PaperTexturePainter()),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned.fill(child: _buildBackground()),

          if (_hasObjectReflection)
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Align(
                  alignment: _getReflectionAlignment(_animation.value),
                  child: _buildObjectReflection(),
                );
              },
            ),

          // Moving Object
          AnimatedBuilder(
            animation: Listenable.merge([_animation, _wingAnimation]),
            builder: (context, child) {
              return Align(
                alignment: _getAlignment(_animation.value),
                child: _buildAnimatedVisualObject(),
              );
            },
          ),

          if (widget.settings.showCompletionQuestions) _buildPaperTexture(),
          widget.settings.showCompletionQuestions
              ? _buildPdfSessionChrome()
              : _buildTopBar(),
          if (_showCompletionQuestions) _buildCompletionOverlay(),
        ],
      ),
    );
  }

  Widget _buildPdfSessionChrome() {
    final totalSets = widget.settings.totalSets <= 0
        ? 34
        : widget.settings.totalSets;
    final currentSet = (_moveCount / 2).ceil().clamp(1, totalSets);
    final textColor = _sceneUsesLightText
        ? Colors.white
        : const Color(0xFF4B463C);
    final shadow = [
      Shadow(
        color: Colors.black.withValues(
          alpha: _sceneUsesLightText ? 0.25 : 0.08,
        ),
        blurRadius: 8,
        offset: const Offset(0, 1),
      ),
    ];

    return SafeArea(
      child: Stack(
        children: [
          Positioned(
            top: 28,
            left: 38,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPdfBackButton(textColor),
                const SizedBox(height: 16),
                Text(
                  'THE UK INKIND PSYCHOLOGY CLINIC',
                  style: TextStyle(
                    color: textColor.withValues(alpha: 0.72),
                    fontSize: 9,
                    letterSpacing: 2,
                    shadows: shadow,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _sceneTitle,
                  style: TextStyle(
                    color: textColor.withValues(alpha: 0.94),
                    fontSize: 20,
                    fontFamily: 'Serif',
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w300,
                    shadows: shadow,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 32,
            right: 38,
            child: Text(
              '$currentSet of $totalSets',
              style: TextStyle(
                color: textColor.withValues(alpha: 0.78),
                fontSize: 13,
                fontStyle: FontStyle.italic,
                shadows: shadow,
              ),
            ),
          ),
          Positioned(
            right: 38,
            bottom: 32,
            child: _buildPdfPauseButton(textColor),
          ),
        ],
      ),
    );
  }

  Widget _buildPdfBackButton(Color textColor) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: TextButton.icon(
          onPressed: () => Navigator.pop(context, false),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 15,
            color: textColor.withValues(alpha: 0.9),
          ),
          label: Text(
            'Back',
            style: TextStyle(
              color: textColor.withValues(alpha: 0.9),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: TextButton.styleFrom(
            backgroundColor: _sceneUsesLightText
                ? Colors.white.withValues(alpha: 0.22)
                : Colors.black.withValues(alpha: 0.06),
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
              side: BorderSide(
                color: _sceneUsesLightText
                    ? Colors.white.withValues(alpha: 0.35)
                    : Colors.black.withValues(alpha: 0.1),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPdfPauseButton(Color textColor) {
    final label = _isPaused ? 'Resume' : 'Pause';
    final icon = _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded;

    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: TextButton.icon(
          onPressed: _togglePause,
          icon: Icon(icon, size: 18, color: const Color(0xFF151515)),
          label: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF151515),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: TextButton.styleFrom(
            backgroundColor: Colors.white.withValues(alpha: 0.72),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
              side: BorderSide(color: Colors.black.withValues(alpha: 0.16)),
            ),
          ),
        ),
      ),
    );
  }

  bool get _sceneUsesLightText {
    final source = widget.settings.environmentImage;
    return isBlsSceneSource(source) &&
        const {'night', 'forest'}.contains(blsSourceId(source));
  }

  String get _sceneTitle {
    if (!isBlsSceneSource(widget.settings.environmentImage)) {
      return 'Bilateral Stimulation';
    }

    switch (blsSourceId(widget.settings.environmentImage)) {
      case 'ocean':
        return 'Ocean Horizon';
      case 'night':
        return 'Starlit Lake';
      case 'forest':
        return 'Enchanted Forest';
      case 'meadow':
        return 'Wildflower Meadow';
      case 'autumn':
        return 'Autumn Valley';
      case 'mountains':
      default:
        return 'Mountain Sanctuary';
    }
  }

  Widget _buildCompletionOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF8F5F0), Color(0xFFE8EFE8)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Take a gentle breath.\nNotice what you experienced.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF5A5550),
                      fontSize: 19,
                      fontStyle: FontStyle.italic,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildQuestionCard(
                    text: 'Is it changing?',
                    selectedAnswer: _firstCompletionAnswer,
                    onYes: () => _handleFirstCompletionAnswer(true),
                    onNo: () => _handleFirstCompletionAnswer(false),
                  ),
                  if (_showSecondCompletionQuestion) ...[
                    const SizedBox(height: 16),
                    _buildQuestionCard(
                      text: 'Is it still connected to your original image?',
                      selectedAnswer: _secondCompletionAnswer,
                      onYes: () => _handleSecondCompletionAnswer(true),
                      onNo: () => _handleSecondCompletionAnswer(false),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionCard({
    required String text,
    required bool? selectedAnswer,
    required VoidCallback onYes,
    required VoidCallback onNo,
  }) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 420),
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF5A5550),
              fontSize: 16,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _buildQuestionButton(
                  'Yes',
                  onYes,
                  selected: selectedAnswer == true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuestionButton(
                  'No',
                  onNo,
                  selected: selectedAnswer == false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionButton(
    String text,
    VoidCallback onTap, {
    required bool selected,
  }) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: selected
            ? const Color(0xFF5A6A50)
            : const Color(0xFF6A655D),
        backgroundColor: selected
            ? const Color(0xFF7A9A6A).withValues(alpha: 0.18)
            : Colors.white,
        side: BorderSide(
          color: selected ? const Color(0xFF7A9A6A) : const Color(0xFFD8D2C8),
          width: 1.6,
        ),
        padding: const EdgeInsets.symmetric(vertical: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      ),
      child: Text(text),
    );
  }

  Widget _buildTopBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  // Back button + Title
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.black87,
                      size: 18,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Bilateral set',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Text(
                      _setComplete
                          ? 'Set complete'
                          : '${_remainingSetTime.inSeconds}s',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  // Pause / Resume button
                  ElevatedButton(
                    onPressed: _togglePause,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF537E5D),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      _setComplete
                          ? 'Done'
                          : _isPaused
                          ? 'Resume'
                          : 'Pause',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
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

class _PaperTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 0.6;

    for (var i = 0; i < 700; i++) {
      final x = ((i * 37) % 1000) / 1000 * size.width;
      final y = ((i * 61) % 1000) / 1000 * size.height;
      canvas.drawCircle(Offset(x, y), (i % 3 + 1) * 0.35, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HtmlToneProfile {
  const _HtmlToneProfile(
    this.leftFrequency,
    this.rightFrequency,
    this.attackSeconds,
    this.decaySeconds,
    this.volume,
  );

  final double leftFrequency;
  final double rightFrequency;
  final double attackSeconds;
  final double decaySeconds;
  final double volume;
}
