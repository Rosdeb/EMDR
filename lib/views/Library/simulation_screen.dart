import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
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

  @override
  void initState() {
    super.initState();
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
        if (mounted) _audioPlayer.setBalance(_animation.value);
      });
      await _audioPlayer.resume();
    } catch (e) {
      debugPrint("Audio Error: $e");
    }
  }

  Alignment _getAlignment(double value) {
    switch (widget.settings.direction) {
      case AnimationDirection.vertical: return Alignment(0.0, value);
      case AnimationDirection.diagonal: return Alignment(value, value);
      case AnimationDirection.horizontal:
      default: return Alignment(value, 0.2); // 0.2 height-e rakha hoyeche
    }
  }

  @override
  void dispose() {
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

          // Custom Top Bar (Figma-r moto)
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
            const Text("Mountain Sanctuary", style: TextStyle(color: Colors.white, fontSize: 18, backgroundColor: Colors.black26)),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white24),
              child: const Text("Pause", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }
}