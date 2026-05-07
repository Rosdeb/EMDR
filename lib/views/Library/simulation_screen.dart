import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'simulation_settings.dart';

class SimulationScreen extends StatefulWidget {
  final SimulationSettings settings;
  const SimulationScreen({super.key, required this.settings});

  @override
  State<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends State<SimulationScreen>
    with TickerProviderStateMixin {
  static const String _butterflyGif =
      'assets/images/Butterfly Lottie Animation.gif';
  late AnimationController _controller;
  late Animation<double> _animation;
  late AnimationController _wingController;
  late Animation<double> _wingAnimation;
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isPaused = false; // Track pause state
  bool _isReversing = false; // Track animation direction

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
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

    _animation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    _wingController = AnimationController(
      duration: const Duration(milliseconds: 360),
      vsync: this,
    );
    _wingAnimation = CurvedAnimation(
      parent: _wingController,
      curve: Curves.easeInOut,
    );

    _controller.forward(); // Start animation
    if (_shouldFlapWings) {
      _wingController.repeat(reverse: true);
    }
    _setupAudio();
  }

  Future<void> _setupAudio() async {
    try {
      if (widget.settings.audioAsset.isEmpty) return;

      if (widget.settings.audioAsset.startsWith('http')) {
        await _audioPlayer.setSource(UrlSource(widget.settings.audioAsset));
      } else {
        String assetPath = widget.settings.audioAsset;
        if (assetPath.startsWith('assets/')) {
          assetPath = assetPath.substring(7);
        }
        await _audioPlayer.setSource(AssetSource(assetPath));
      }
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);

      _controller.addListener(() {
        if (mounted && !_isPaused) _audioPlayer.setBalance(_animation.value);
      });
      await _audioPlayer.resume();
    } catch (e) {
      debugPrint("Audio Error: $e");
    }
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
      if (_isPaused) {
        _controller.stop();
        if (_shouldFlapWings) {
          _wingController.stop();
        }
        _audioPlayer.pause();
      } else {
        if (_isReversing) {
          _controller.reverse();
        } else {
          _controller.forward();
        }
        if (_shouldFlapWings) {
          _wingController.repeat(reverse: true);
        }
        _audioPlayer.resume();
      }
    });
  }

  Alignment _getAlignment(double value) {
    switch (widget.settings.direction) {
      case AnimationDirection.vertical:
        return Alignment(0.0, value);
      case AnimationDirection.diagonal:
        return Alignment(value, value);
      case AnimationDirection.diagonalReverse:
        return Alignment(value, -value);
      case AnimationDirection.horizontal:
      default:
        return Alignment(value, 0.2);
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _controller.dispose();
    _wingController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Widget _buildBackground() {
    final background = widget.settings.environmentImage.startsWith('http')
        ? CachedNetworkImage(
            imageUrl: widget.settings.environmentImage,
            fit: BoxFit.cover,
            placeholder: (context, url) =>
                const Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) => Container(color: Colors.grey),
          )
        : Image.asset(widget.settings.environmentImage, fit: BoxFit.cover);

    return AnimatedBuilder(
      animation: _controller,
      child: background,
      builder: (context, child) {
        final progress = _controller.value;
        final panX = (progress - 0.5) * 18;
        final scale = 1.04 + (progress * 0.015);

        return ClipRect(
          child: Transform.translate(
            offset: Offset(panX, 0),
            child: Transform.scale(
              scale: scale,
              child: child,
            ),
          ),
        );
      },
    );
  }

  String get _resolvedVisualObject {
    final visualObject = widget.settings.visualObject.trim();
    final lowerVisualObject = visualObject.toLowerCase();

    if (visualObject.isEmpty ||
        lowerVisualObject.contains('butterfly.png') ||
        lowerVisualObject.contains('butterfly lottie') ||
        (lowerVisualObject.contains('butterfly') &&
            !lowerVisualObject.endsWith('.gif'))) {
      return _butterflyGif;
    }

    return visualObject;
  }

  Widget _buildVisualObject({double size = 70}) {
    final visualObject = _resolvedVisualObject;

    if (visualObject.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: visualObject,
        width: size,
        height: size,
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
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }

  bool get _shouldFlapWings {
    final visualObject = _resolvedVisualObject.toLowerCase();
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
      child: Align(
        widthFactor: 0.22,
        child: _buildVisualObject(size: 74),
      ),
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
          width: 96,
          height: 96,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(glowOpacity),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned.fill(child: _buildBackground()),

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

          _buildTopBar(),
        ],
      ),
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
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  // Back button + Title
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.black87, size: 18),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Mountain Sanctuary',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const Spacer(),

                  // Pause / Resume button
                  ElevatedButton(
                    onPressed: _togglePause,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF537E5D),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 22, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      _isPaused ? 'Resume' : 'Pause',
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
