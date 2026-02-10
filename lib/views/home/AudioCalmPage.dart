import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:just_audio/just_audio.dart';

import 'package:jonssony/utils/AppIcons/app_icons.dart';
import 'package:jonssony/utils/app_colors.dart';
import 'package:jonssony/utils/app_text.dart';

class AudioCalmPage extends StatefulWidget {
  const AudioCalmPage({super.key});

  @override
  State<AudioCalmPage> createState() => _AudioCalmPageState();
}

class _AudioCalmPageState extends State<AudioCalmPage> {
  late AudioPlayer _audioPlayer;

  String currentAudio = "calm place.wav";
  final List<String> audioList = [
    "calm place.wav",
    "puppies_v1.mp3",
  ];

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      await _audioPlayer.setAsset('assets/audio/$currentAudio');
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
    const double appBarImageHeight = 180;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          /// Top Image
          SizedBox(
            height: appBarImageHeight,
            width: double.infinity,
            child: Image.asset(
              'assets/images/my_emdr.png',
              fit: BoxFit.cover,
            ),
          ),

          /// Main Layout
          Column(
            children: [
              _buildAppBar(context),

              Expanded(
                child: Stack(
                  children: [
                    /// Background
                    Container(
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/home_bg1.jpg'),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(35),
                          topRight: Radius.circular(35),
                        ),
                      ),
                    ),

                    /// Scroll Content
                    SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          const SizedBox(height: 90),

                          _buildGlassContainer(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildAudioPlayerContent(),
                                  const SizedBox(height: 25),

                                  const AppText(
                                    "Describe this place",
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2E3E32),
                                  ),
                                  const SizedBox(height: 15),

                                  Container(
                                    height: 120,
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.3),
                                      ),
                                    ),
                                    child: const TextField(
                                      maxLines: 4,
                                      decoration: InputDecoration(
                                        hintText:
                                        "Why does this place make you feel safe? E.g., 'The air is crisp...'",
                                        border: InputBorder.none,
                                        hintStyle: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 150),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // AUDIO PLAYER CONTENT
  // ---------------------------------------------------------------------------

  Widget _buildAudioPlayerContent() {
    return Row(
      children: [
        /// Play / Pause
        StreamBuilder<PlayerState>(
          stream: _audioPlayer.playerStateStream,
          builder: (context, snapshot) {
            final playing = snapshot.data?.playing ?? false;
            return GestureDetector(
              onTap: () {
                playing ? _audioPlayer.pause() : _audioPlayer.play();
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFF537E5D),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  playing
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            );
          },
        ),

        const SizedBox(width: 15),

        /// Title + Progress
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                currentAudio,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 8),
              StreamBuilder<Duration>(
                stream: _audioPlayer.positionStream,
                builder: (context, snapshot) {
                  final position = snapshot.data ?? Duration.zero;
                  final duration = _audioPlayer.duration ?? Duration.zero;

                  return Column(
                    children: [
                      LinearProgressIndicator(
                        value: duration.inMilliseconds > 0
                            ? position.inMilliseconds /
                            duration.inMilliseconds
                            : 0,
                        backgroundColor: Colors.black12,
                        valueColor:
                        const AlwaysStoppedAnimation<Color>(
                          Color(0xFF537E5D),
                        ),
                        minHeight: 6,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          AppText(
                            _formatDuration(position),
                            fontSize: 10,
                            color: Colors.black54,
                          ),
                          AppText(
                            _formatDuration(duration),
                            fontSize: 10,
                            color: Colors.black54,
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),

        const SizedBox(width: 10),

        /// Replace Button
        ElevatedButton(
          onPressed: () => _showAudioSelectionModal(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF537E5D),
            minimumSize: const Size(60, 30),
            padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const AppText(
            "Replace",
            fontSize: 11,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // AUDIO SELECTION MODAL
  // ---------------------------------------------------------------------------

  void _showAudioSelectionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius:
            BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: audioList.map((audio) {
              final isSelected = currentAudio == audio;
              return ListTile(
                leading: Icon(
                  Icons.music_note,
                  color: isSelected
                      ? const Color(0xFF537E5D)
                      : Colors.grey,
                ),
                title: AppText(
                  audio,
                  fontWeight:
                  isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_circle,
                    color: Color(0xFF537E5D))
                    : null,
                onTap: () async {
                  setState(() => currentAudio = audio);
                  await _audioPlayer.stop();
                  await _audioPlayer
                      .setAsset('assets/audio/$audio');
                  await _audioPlayer.play();
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // UI HELPERS
  // ---------------------------------------------------------------------------

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        left: 10,
        bottom: 10,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back,
                color: Color(0xFF2E3E32)),
            onPressed: () => Navigator.pop(context),
          ),
          const AppText(
            "My Calm Space",
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E3E32),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassContainer({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(25),
            border:
            Border.all(color: Colors.white.withOpacity(0.2)),
            image: const DecorationImage(
              image: AssetImage('assets/images/home_bg2.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  String _formatDuration(Duration d) =>
      "${d.inMinutes.remainder(60).toString().padLeft(2, '0')}:${d.inSeconds.remainder(60).toString().padLeft(2, '0')}";
}
