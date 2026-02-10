import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

class BilateralSimulationPage extends StatefulWidget {
  final String environmentImage;
  final String visualObject;
  final double speedInSeconds;
  final String audioAsset;

  const BilateralSimulationPage({
    super.key,
    required this.environmentImage,
    required this.visualObject,
    required this.speedInSeconds,
    required this.audioAsset,
  });

  @override
  State<BilateralSimulationPage> createState() => _BilateralSimulationPageState();
}

class _BilateralSimulationPageState extends State<BilateralSimulationPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final AudioPlayer _audioPlayer = AudioPlayer(); // Early initialization

  @override
  void initState() {
    super.initState();

    // 1. Audio Setup
    _initAudio();

    // 2. Animation Controller logic
    _controller = AnimationController(
      // milliseconds use karna zyada accurate hota hai
      duration: Duration(milliseconds: (widget.speedInSeconds * 1000).toInt().clamp(1, 10000)),
      vsync: this,
    )..repeat(reverse: true);

    // 3. Smooth Linear Animation
    _animation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    // 4. Critical: Listener with 'mounted' check to prevent memory leaks
    _controller.addListener(() {
      if (mounted) {
        // Audio Panning Sync
        // _audioPlayer.setPan(_animation.value);
      }
    });
  }

  Future<void> _initAudio() async {
    try {
      await _audioPlayer.setAsset(widget.audioAsset);
      await _audioPlayer.setLoopMode(LoopMode.all);
      await _audioPlayer.play();
    } catch (e) {
      debugPrint("Audio Error: $e");
    }
  }

  @override
  void dispose() {
    // Controller dispose karne se pehle stop karein
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Status bar hide karne ke liye
      body: AnnotatedRegion(
        value: const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
        child: Stack(
          children: [
            // Background Environment
            Positioned.fill(
              child: Image.asset(
                widget.environmentImage,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(color: Colors.grey), // Error fallback
              ),
            ),

            // Bilateral Object Movement
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Align(
                  // Y-axis 0.2 par rakha hai takki object height par dikhe
                  alignment: Alignment(_animation.value, 0.2),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    child: Image.asset(
                      widget.visualObject,
                      width: 80,
                      height: 80,
                    ),
                  ),
                );
              },
            ),

            // Top Header UI
            _buildTopBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Mountain Sanctuary",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Serif'
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        if (_controller.isAnimating) {
                          _controller.stop();
                          _audioPlayer.pause();
                        } else {
                          _controller.repeat(reverse: true);
                          _audioPlayer.play();
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5A7D63),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)
                      ),
                    ),
                    child: Text(
                      _controller.isAnimating ? "Pause" : "Play",
                      style: const TextStyle(color: Colors.white),
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