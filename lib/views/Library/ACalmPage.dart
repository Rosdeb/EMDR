import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class ACalmPage extends StatefulWidget {
  const ACalmPage({super.key});

  @override
  State<ACalmPage> createState() => _ACalmPageState();
}

class _ACalmPageState extends State<ACalmPage> {
  late AudioPlayer _audioPlayer;
  String currentAudio = "Calm_place.mp3";

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      // Asset path update karein apne naming convention ke hisaab se
      await _audioPlayer.setAsset('assets/audio/calm_place.mp3');
    } catch (e) {
      debugPrint("Audio load error: $e");
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Stack(
        children: [
          // 1. Full Background Illustration
          Positioned.fill(
            child: Image.asset(
              'assets/images/home_bg1.jpg', // Yeh landscape illustration hai
              fit: BoxFit.cover,
            ),
          ),

          // 2. Main Content
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                const Spacer(),

                // Outer Glass Container
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white.withOpacity(0.3)),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Inner Card - Image Placeholder
                            Container(
                              height: 400, // Matching the tall image in UI
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFAF3E0).withOpacity(0.6),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.asset(
                                  'assets/images/home_bg2.jpg', // Inner drawing
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            // Audio Controller Card
                            _buildAudioPlayerCard(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF333333)),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            "My Calm Space",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w400,
              fontFamily: 'Serif', // Serif font use karein image matching ke liye
              color: Color(0xFF333333),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioPlayerCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Play Button
              StreamBuilder<PlayerState>(
                stream: _audioPlayer.playerStateStream,
                builder: (context, snapshot) {
                  final playing = snapshot.data?.playing ?? false;
                  return GestureDetector(
                    onTap: () => playing ? _audioPlayer.pause() : _audioPlayer.play(),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFF5A7D63), // Muted green
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 15),
              // Title and Slider
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentAudio,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    _buildSlider(),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Description Text from Image
          const Text(
            "The air is crisp and I can hear the wind in the trees. It smells like pine and damp earth.",
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: Color(0xFF444444),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider() {
    return StreamBuilder<Duration>(
      stream: _audioPlayer.positionStream,
      builder: (context, snapshot) {
        final position = snapshot.data ?? Duration.zero;
        final duration = _audioPlayer.duration ?? Duration.zero;
        return Column(
          children: [
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 8,
                thumbShape: SliderComponentShape.noThumb,
                overlayShape: SliderComponentShape.noOverlay,
                activeTrackColor: const Color(0xFF5A7D63),
                inactiveTrackColor: const Color(0xFFBCCBBF),
              ),
              child: Slider(
                value: duration.inMilliseconds > 0
                    ? position.inMilliseconds / duration.inMilliseconds
                    : 0,
                onChanged: (v) {
                  _audioPlayer.seek(Duration(milliseconds: (v * duration.inMilliseconds).toInt()));
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatDuration(position), style: const TextStyle(fontSize: 10)),
                Text(_formatDuration(duration), style: const TextStyle(fontSize: 10)),
              ],
            ),
          ],
        );
      },
    );
  }

  String _formatDuration(Duration d) =>
      "${d.inMinutes.remainder(60)}:${d.inSeconds.remainder(60).toString().padLeft(2, '0')}";
}