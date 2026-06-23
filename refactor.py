import re

with open('lib/views/Library/simulation_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Add imports
imports = """import 'package:jonssony/views/Library/bls/bilateral_animation_controller.dart';
import 'package:jonssony/views/Library/bls/bilateral_audio_sync.dart';
import 'package:jonssony/views/Library/bls/bilateral_session_orchestrator.dart';
"""
if "import 'package:jonssony/views/Library/bls/bilateral_animation_controller.dart';" not in content:
    content = re.sub(r"(import 'package:flutter/material.dart';)", r"\1\n" + imports, content)

new_state_content = """class _SimulationScreenState extends State<SimulationScreen>
    with TickerProviderStateMixin {
  static const Color _inkText = Color(0xFF151515);
  
  late final BilateralAnimationController _blsAnimation;
  late final BilateralAudioSync _blsAudio;
  late final BilateralSessionOrchestrator _blsSession;
  
  Animation<double> get _animation => _blsAnimation.animation;

  late AnimationController _wingController;
  late Animation<double> _wingAnimation;
  late AnimationController _effectController;
  final VoiceService _voice = VoiceService();
  final ValueNotifier<bool> _videoPlayingNotifier = ValueNotifier(false);
  Widget? _stableVideoVisual;
  Widget? _sessionMovingVisual;

  late int _selectedDurationMinutes;
  bool _showIntroGuidance = false;
  bool _showClosingGuidance = false;
  bool _showCompletionQuestions = false;
  bool _showSudsRating = false;
  int _sudsRating = 5;
  bool _guidanceAudioPlaying = false;
  bool _guidanceAudioCompleted = false;
  bool _showStuckScreen = false;
  bool _summaryAudioPlaying = false;
  late AnimationDirection _currentDirection;
  VoidCallback? _onGuidanceAudioComplete;
  final AudioPlayer _guidanceAudioPlayer = AudioPlayer();

  late AnimationController _turnController;
  Animation<double>? _activeTurn;
  final ValueNotifier<double> _displayFacingAngle = ValueNotifier(0.0);

  bool get _setComplete => _blsSession.setComplete;
  bool get _isPaused => _blsSession.isPaused;
  bool get _motionStarted => _blsSession.motionStarted;
  int get _moveCount => _blsSession.moveCount;
  Duration get _sessionRemaining => _blsSession.sessionRemaining;

  @override
  void initState() {
    super.initState();
    _currentDirection = widget.settings.direction;
    _guidanceAudioPlayer.onPlayerComplete.listen((_) {
      if (!mounted) return;
      setState(() {
        _guidanceAudioPlaying = false;
        _guidanceAudioCompleted = true;
      });
      if (_onGuidanceAudioComplete != null) {
        _onGuidanceAudioComplete!();
      }
    });

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

    _selectedDurationMinutes = widget.settings.maxDurationMinutes == 90 ? 90 : 60;
    _showIntroGuidance = widget.settings.showCompletionQuestions;

    _blsAnimation = BilateralAnimationController(
      vsync: this,
      halfCycleDuration: _halfCycleDuration,
    );
    
    _blsAudio = BilateralAudioSync();
    
    _blsSession = BilateralSessionOrchestrator(
      totalSets: widget.settings.totalSets,
      sessionLimit: _selectedDurationMinutes > 0 ? Duration(minutes: _selectedDurationMinutes) : Duration.zero,
      setDuration: _resolveSetDuration(),
      animationController: _blsAnimation,
      onSetComplete: _onSetComplete,
      onSessionComplete: _onSessionComplete,
    );
    
    _blsSession.addListener(() {
      if (mounted) setState(() {});
    });

    _blsAnimation.endpointStream.listen((event) {
      if (!_blsSession.motionStarted || _blsSession.setComplete || _blsSession.isPaused) return;
      
      _blsAudio.playEndpoint(
        isRight: event.endpoint == BlsEndpoint.right,
        speedSeconds: widget.settings.speed,
      );

      _beginFacingTurn(faceLeft: event.endpoint == BlsEndpoint.right);
    });

    _turnController = AnimationController(
      duration: const Duration(milliseconds: 420),
      vsync: this,
    )..addListener(_onTurnTick);

    _wingController = AnimationController(
      duration: const Duration(milliseconds: 360),
      vsync: this,
    );
    _wingAnimation = CurvedAnimation(
      parent: _wingController,
      curve: Curves.easeInOutSine,
    );
    _effectController = AnimationController(
      duration: const Duration(hours: 1),
      vsync: this,
    );
    if (_needsEffectAnimation) {
      _effectController.repeat();
    }
    
    _setupVisuals();

    _blsAudio.initPlayers(
      soundKey: _resolvedSoundKey,
      audioAsset: _resolvedAudioAsset,
    ).then((_) {
      if (!widget.settings.showCompletionQuestions) {
        _startMotion();
      }
    });
  }

  void _setupVisuals() {
    if (_usesAssetAnimatedVisual || _usesVideoVisual) {
      _videoPlayingNotifier.value = true;
      if (_usesAssetAnimatedVisual) {
        final visualSource = resolveLocalVisualAsset(_resolvedVisualObject);
        final visual = resolveLocalVisual(visualSource);
        if (visual?.usesSpriteFrames == true) {
          _stableVideoVisual = CanvasSpriteVisual(
            key: ValueKey(visual!.id),
            frameAssets: visual.spriteFrameAssets,
            size: _objectSize,
            playing: true,
            fps: visual.fps,
          );
        } else {
          _stableVideoVisual = AssetAnimatedVisualLayer(
            assetPath: visualSource,
            size: _objectSize,
            playingListenable: _videoPlayingNotifier,
            stripWhiteBackground: !shouldUseSpriteVisual(visualSource),
          );
        }
      } else {
        _stableVideoVisual = TransparentSessionVisualLayer(
          candidates: _sessionVisualCandidates,
          size: _objectSize,
          playingListenable: _videoPlayingNotifier,
          fallback: _buildVideoFallback(_objectSize),
        );
      }
    }
    _sessionMovingVisual = RepaintBoundary(
      child: TickerMode(
        enabled: true,
        child: _stableVideoVisual ?? _buildVisualObject(size: _objectSize),
      ),
    );
  }

  Duration get _halfCycleDuration {
    final milliseconds = (widget.settings.speed * 1000).round();
    return Duration(milliseconds: milliseconds.clamp(1, 20000));
  }

  Duration get _fullCycleDuration => _halfCycleDuration * 2;

  Duration _resolveSetDuration() {
    if (widget.settings.totalSets > 0) {
      final totalSets = widget.settings.totalSets;
      final milliseconds = _fullCycleDuration.inMilliseconds * totalSets;
      return Duration(milliseconds: milliseconds < 1000 ? 1000 : milliseconds);
    }
    return const Duration(seconds: 45);
  }

  @override
  void didUpdateWidget(SimulationScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.settings.audioAsset != widget.settings.audioAsset ||
        oldWidget.settings.soundKey != widget.settings.soundKey) {
      _blsAudio.initPlayers(
        soundKey: _resolvedSoundKey,
        audioAsset: _resolvedAudioAsset,
      );
    }
  }

  String get _resolvedSoundKey {
    final rawKey = widget.settings.soundKey.trim();
    if (rawKey.isEmpty || rawKey == 'none') return rawKey;
    final normalized = BlsBuiltInSounds.normalizeKey(rawKey);
    if (kBlsToneProfiles.containsKey(normalized)) return normalized;
    if (kBlsToneProfiles.containsKey(rawKey)) return rawKey;
    if (BlsBuiltInSounds.isBuiltInKey(rawKey)) return normalized;
    return normalized;
  }

  String get _resolvedAudioAsset {
    final asset = widget.settings.audioAsset.trim();
    if (asset.isNotEmpty) return asset;
    final rawKey = widget.settings.soundKey.trim();
    if (_isNetworkUrl(rawKey)) return rawKey;
    return asset;
  }

  List<SessionVisualCandidate> get _sessionVisualCandidates {
    final configured = widget.settings.visualPlaybackUrl?.trim();
    final source = configured?.isNotEmpty == true ? configured! : widget.settings.visualObject.trim();
    return buildSessionVisualCandidates(
      source: source,
      transparentUrl: widget.settings.visualTransparentUrl,
      label: widget.settings.visualLabel,
      mediaType: widget.settings.visualMediaType,
    );
  }

  String get _videoPlaybackUrl {
    final candidates = _sessionVisualCandidates;
    if (candidates.isNotEmpty) return candidates.first.url;
    final configured = widget.settings.visualPlaybackUrl?.trim();
    final source = configured?.isNotEmpty == true ? configured! : widget.settings.visualObject.trim();
    return resolveSimulationVisualUrl(
      source,
      label: widget.settings.visualLabel,
      mediaType: widget.settings.visualMediaType,
    );
  }

  bool _looksLikeVideo(String source) {
    final path = _mediaPath(source);
    return path.endsWith('.mp4') || path.endsWith('.mov') || path.endsWith('.webm') || path.contains('/video/upload/');
  }

  bool get _usesAssetAnimatedVisual {
    final source = _resolvedVisualObject;
    if (isBlsLocalVisualAsset(source) || resolveLocalVisual(source) != null) return true;
    return source.startsWith('assets/') && isAnimatedAssetVisual(source);
  }

  bool get _usesVideoVisual {
    if (_usesAssetAnimatedVisual) return false;
    if (widget.settings.visualMediaType.toLowerCase() == 'video') return _sessionVisualCandidates.isNotEmpty;
    return _isVideoVisual(_videoPlaybackUrl);
  }

  bool get _needsEffectAnimation => bilateralObjectFromSource(_resolvedVisualObject) != null;

  void _startMotion() {
    if (!mounted || _setComplete || _isPaused) return;
    if (!_motionStarted) {
      _currentDirection = widget.settings.direction;
    }
    
    _blsSession.motionStarted = true;
    _blsAnimation.start();
    _blsAudio.startContinuous();
    _blsSession.startSetTimer();
    _blsSession.startSessionTimer();
    
    if (_needsEffectAnimation && !_effectController.isAnimating) {
      _effectController.repeat();
    }
    _videoPlayingNotifier.value = true;
    if (_shouldFlapWings) _wingController.repeat(reverse: true);
    
    _blsAnimation.animation.addListener(() {
      _blsAudio.updateContinuousBalance(_blsAnimation.animation.value);
    });
  }

  Future<void> _handleIntroStart() async {
    await _guidanceAudioPlayer.stop();
    await _voice.stop();
    if (!mounted) return;

    setState(() {
      _summaryAudioPlaying = false;
      _showIntroGuidance = false;
      _displayFacingAngle.value = 0;
    });

    _turnController.stop();
    _turnController.reset();
    _effectController..reset()..repeat();
    
    _blsSession.restartSet();
    _startMotion();
  }

  void _onSetComplete() {
    _blsAnimation.stop();
    _wingController.stop();
    _effectController.stop();
    _videoPlayingNotifier.value = false;
    _blsAudio.stop();
    
    if (widget.settings.showCompletionQuestions) {
      setState(() {
        _showCompletionQuestions = true;
      });
      _voice.speak('Take a gentle breath. Notice what you experienced. Is it changing and still connected to your original image?');
    }
  }

  void _onSessionComplete() {
    _blsAnimation.stop();
    _wingController.stop();
    _effectController.stop();
    _videoPlayingNotifier.value = false;
    _blsAudio.stop();
    _voice.stop();
    
    setState(() {
      _showCompletionQuestions = false;
      _showClosingGuidance = true;
    });
    
    _voice.speak('You have reached the session time you chose. Return to your calm place now. Bring up your pincode and spend a minute finding that calm feeling in your body.');
  }

  Future<void> _stopSessionAudio() async {
    try {
      _blsAudio.stop();
      await _voice.stop();
      await _guidanceAudioPlayer.stop();
    } catch (_) {}
  }

  bool _isNetworkUrl(String value) {
    final uri = Uri.tryParse(value.trim());
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https') && uri.host.isNotEmpty;
  }

  String _mediaPath(String value) {
    final trimmed = value.trim();
    final uri = Uri.tryParse(trimmed);
    return (uri?.path.isNotEmpty == true ? uri!.path : trimmed).toLowerCase();
  }

  bool _isImageVisual(String value) {
    final source = _mediaPath(value);
    return source.endsWith('.png') || source.endsWith('.jpg') || source.endsWith('.jpeg') || source.endsWith('.webp') || source.endsWith('.gif');
  }

  bool _isAnimatedImageVisual(String value) {
    return _mediaPath(value).endsWith('.gif');
  }

  bool _isVideoVisual(String value) {
    if (_isImageVisual(value)) return false;
    final source = _mediaPath(value);
    return widget.settings.visualMediaType.toLowerCase() == 'video' || source.endsWith('.mp4') || source.endsWith('.mov') || source.endsWith('.webm') || source.contains('video');
  }

  Future<void> _restartSet() async {
    _blsAudio.stop();
    if (!mounted) return;

    setState(() {
      _showCompletionQuestions = false;
      _showClosingGuidance = false;
      _showSudsRating = false;
      _sudsRating = 5;
      _displayFacingAngle.value = 0;
    });

    _turnController.stop();
    _turnController.reset();
    _effectController..reset()..repeat();
    _videoPlayingNotifier.value = true;
    
    _blsSession.restartSet();
    _startMotion();
  }

  Future<void> _handleFirstCompletionAnswer(bool answer) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    if (answer) {
      await _playGuidance(
        audioPath: 'assets/audio/changing_guidance.mp3',
        fallbackText: 'Ok, good. Go with that, or go with where you left off.',
        onDone: () {
          Future.delayed(const Duration(milliseconds: 400), () {
            if (mounted) _restartSet();
          });
        },
      );
    }
  }

  Future<void> _handleSudsContinue() async {
    if (_sudsRating <= 1) {
      await _guidanceAudioPlayer.stop();
      await _voice.stop();
      if (!mounted) return;
      Navigator.pop(context, true);
      return;
    }

    if (_blsSession.sessionComplete) return;

    await _restartSet();
  }

  void _togglePause() {
    if (_showCompletionQuestions) return;
    if (_setComplete) {
      Navigator.pop(context);
      return;
    }

    if (_blsSession.isPaused) {
      _blsSession.resume();
      _blsAnimation.resume();
      _blsAudio.resume();
      _effectController.repeat();
      _videoPlayingNotifier.value = true;
      if (_shouldFlapWings) _wingController.repeat(reverse: true);
    } else {
      _blsSession.pause();
      _blsAnimation.pause();
      _blsAudio.pause();
      _turnController.stop();
      _effectController.stop();
      _videoPlayingNotifier.value = false;
      if (_shouldFlapWings) _wingController.stop();
      _voice.stop();
    }
  }

  bool get _isSpriteVisual => shouldUseSpriteVisual(_resolvedVisualObject);

  void _onTurnTick() {
    final turn = _activeTurn;
    if (turn == null || !mounted) return;
    _displayFacingAngle.value = turn.value;
  }

  void _beginFacingTurn({required bool faceLeft}) {
    final end = faceLeft ? math.pi : 0.0;
    final begin = _displayFacingAngle.value;
    if ((begin - end).abs() < 0.01) return;

    _activeTurn = Tween<double>(begin: begin, end: end).animate(
      CurvedAnimation(parent: _turnController, curve: Curves.easeInOutCubic),
    );
    _turnController..stop()..reset()..forward();
  }

  Matrix4 _facingTransformMatrix() {
    final matrix = Matrix4.identity()..setEntry(3, 2, 0.0018);
    switch (_currentDirection) {
      case AnimationDirection.vertical:
        matrix.rotateX(_displayFacingAngle.value);
        break;
      case AnimationDirection.horizontal:
      case AnimationDirection.diagonal:
      case AnimationDirection.diagonalReverse:
        matrix.rotateY(_displayFacingAngle.value);
        break;
    }
    return matrix;
  }

  Widget _wrapFacingTurn(Widget child) {
    return Transform(
      alignment: Alignment.center,
      transform: _facingTransformMatrix(),
      child: child,
    );
  }

  bool get _facesLeft => _displayFacingAngle.value > (math.pi / 2);

  Offset _objectPosition(double value, Size screenSize, EdgeInsets padding) {
    final t = (value + 1) / 2;
    final horizontalCorrection = _horizontalEndpointCorrection;
    final usableWidth = screenSize.width - padding.left - padding.right;
    final usableHeight = screenSize.height - padding.top - padding.bottom;
    final minX = -horizontalCorrection;
    final maxX = math.max(minX, usableWidth - _objectSize - horizontalCorrection);
    final maxY = math.max(0.0, usableHeight - _objectSize);
    final x = minX + (t * (maxX - minX));

    switch (_currentDirection) {
      case AnimationDirection.horizontal:
        return Offset(padding.left + x, padding.top + maxY / 2);
      case AnimationDirection.vertical:
        return Offset(padding.left + (usableWidth - _objectSize) / 2, padding.top + t * maxY);
      case AnimationDirection.diagonal:
        return Offset(padding.left + x, padding.top + t * maxY);
      case AnimationDirection.diagonalReverse:
        return Offset(padding.left + x, padding.top + (1 - t) * maxY);
    }
  }

  double get _horizontalEndpointCorrection {
    if (_isSpriteVisual) return _objectSize * 0.18;
    return _objectSize * 0.45;
  }

  bool get _hasObjectReflection {
    final advancedObject = bilateralObjectFromSource(_resolvedVisualObject);
    if (advancedObject != null) return bilateralObjectHasReflection(advancedObject);
    return blsObjectHasReflection(widget.settings.visualObject.trim());
  }

  @override
  void dispose() {
    _stopSessionAudio();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _displayFacingAngle.dispose();
    _blsAnimation.dispose();
    _blsAudio.dispose();
    _blsSession.dispose();
    _turnController.dispose();
    _wingController.dispose();
    _effectController.dispose();
    _guidanceAudioPlayer.dispose();
    _videoPlayingNotifier.dispose();
    _voice.dispose();
    super.dispose();
  }
"""

start_pattern = r"class _SimulationScreenState extends State<SimulationScreen>\s+with TickerProviderStateMixin \{"
end_pattern = r"  Widget _buildBackground\(\) \{"

match = re.search(start_pattern + r".*?(?=  Widget _buildBackground\(\) \{)", content, re.DOTALL)
if match:
    content = content[:match.start()] + new_state_content + "\n" + content[match.end():]
    with open('lib/views/Library/simulation_screen.dart', 'w', encoding='utf-8') as f:
        f.write(content)
    print("Refactoring successful!")
else:
    print("Could not find the section to replace.")
