import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
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
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    _setupAudio();
  }

  Future<void> _setupAudio() async {
    try {
      String assetPath = widget.settings.audioAsset;
      if (assetPath.startsWith('assets/')) {
        assetPath = assetPath.substring(7);
      }

      await _audioPlayer.setSource(AssetSource(assetPath));
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
        _controller.repeat(reverse: true);
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
          Positioned.fill(child: Image.asset(widget.settings.environmentImage, fit: BoxFit.cover)),

          // Moving Object
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Align(
                alignment: _getAlignment(_animation.value),
                child: Image.asset(widget.settings.visualObject, width: 70),
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
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            const Text("Mountain Sanctuary", style: TextStyle(color: Colors.white, fontSize: 18, backgroundColor: Colors.black26)),
            ElevatedButton(
              onPressed: _togglePause,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white24),
              child: Text(_isPaused ? "Resume" : "Pause", style: const TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }
}