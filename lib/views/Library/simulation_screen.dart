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

class _SimulationScreenState extends State<SimulationScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
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

    _controller.forward(); // Start animation
    _setupAudio();
  }

  Future<void> _setupAudio() async {
    try {
      if (widget.settings.audioAsset.isEmpty) return;
      
      if (widget.settings.isNetworkImage || widget.settings.audioAsset.startsWith('http')) {
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
        _audioPlayer.pause();
      } else {
        if (_isReversing) {
          _controller.reverse();
        } else {
          _controller.forward();
        }
        _audioPlayer.resume();
      }
    });
  }

  Alignment _getAlignment(double value) {
    switch (widget.settings.direction) {
      case AnimationDirection.vertical: return Alignment(0.0, value);
      case AnimationDirection.diagonal: return Alignment(value, value);
      case AnimationDirection.diagonalReverse: return Alignment(value, -value);
      case AnimationDirection.horizontal:
      default: return Alignment(value, 0.2);
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: widget.settings.environmentImage.startsWith('http')
                ? CachedNetworkImage(
                    imageUrl: widget.settings.environmentImage, 
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => Container(color: Colors.grey),
                  )
                : Image.asset(widget.settings.environmentImage, fit: BoxFit.cover),
          ),

          // Moving Object
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Align(
                alignment: _getAlignment(_animation.value),
                child: widget.settings.visualObject.startsWith('http')
                    ? CachedNetworkImage(
                        imageUrl: widget.settings.visualObject, 
                        width: 70,
                        placeholder: (context, url) => const SizedBox(width: 70, child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) => const Icon(Icons.error, size: 70),
                      )
                    : Image.asset(widget.settings.visualObject, width: 70),
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