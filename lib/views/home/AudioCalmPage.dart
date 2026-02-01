import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:just_audio/just_audio.dart';
import 'package:jonssony/utils/AppIcons/app_icons.dart';
import 'package:jonssony/utils/app_colors.dart';

class AudioCalmPage extends StatefulWidget {
  const AudioCalmPage({super.key});

  @override
  State<AudioCalmPage> createState() => _AudioCalmPageState();
}

class _AudioCalmPageState extends State<AudioCalmPage> {
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initAudio();
  }


  Future<void> _initAudio() async {
    try {

      await _audioPlayer.setAsset('assets/audio/calm_place.mp3');
    } catch (e) {
      debugPrint("Error loading audio: $e");
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
    const double overlapAmount = 5;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: appBarImageHeight,
            child: Image.asset(
              'assets/images/my_emdr.png',
              fit: BoxFit.fill,
            ),
          ),
          Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      top: -overlapAmount,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(35),
                            topRight: Radius.circular(35),
                          ),
                          image: DecorationImage(
                            image: AssetImage('assets/images/home_bg1.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 90),
                            _buildGlassContainer(
                              height: 420,
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [

                                    const Text(
                                      "Describe this place",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2E3E32),
                                        fontFamily: 'Serif',
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                    _buildAudioPlayerCard(),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 150),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          _buildFloatingBottomNav(AppColors.mainAppColor),
        ],
      ),
    );
  }

  Widget _buildAudioPlayerCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.4),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [

                  StreamBuilder<PlayerState>(
                    stream: _audioPlayer.playerStateStream,
                    builder: (context, snapshot) {
                      final playerState = snapshot.data;
                      final playing = playerState?.playing ?? false;
                      return GestureDetector(
                        onTap: () {
                          if (playing) {
                            _audioPlayer.pause();
                          } else {
                            _audioPlayer.play();
                          }
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFF537E5D),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Calm_place.mp3",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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
                                      ? position.inMilliseconds / duration.inMilliseconds
                                      : 0,
                                  backgroundColor: Colors.black12,
                                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF537E5D)),
                                  minHeight: 6,
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(_formatDuration(position), style: const TextStyle(fontSize: 10, color: Colors.black54)),
                                    Text(_formatDuration(duration), style: const TextStyle(fontSize: 10, color: Colors.black54)),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                "The air is crisp and I can hear the wind in the trees. It smells like pine and damp earth.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }


  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20, left: 10, bottom: 10),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF2E3E32)), onPressed: () => Navigator.pop(context)),
          const Text("My Calm Space", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2E3E32), fontFamily: 'Serif')),
        ],
      ),
    );
  }

  Widget _buildGlassContainer({double? height, required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
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

  Widget _buildFloatingBottomNav(Color primaryColor) {
    return Positioned(
      bottom: 25, left: 15, right: 15,
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  height: 75,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _navItem(AppIcons.home, "Home", true, const Color(0xFF537E5D)),
                      _navItem(AppIcons.progress_nav, "", false, primaryColor),
                      _navItem(AppIcons.library, "", false, primaryColor),
                      _navItem(AppIcons.profile, "", false, primaryColor),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            height: 70, width: 70,
            decoration: const BoxDecoration(color: Color(0xFF537E5D), shape: BoxShape.circle),
            child: const Icon(Icons.add, color: Colors.white, size: 35),
          ),
        ],
      ),
    );
  }

  Widget _navItem(String iconPath, String label, bool isActive, Color activeColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: isActive ? BoxDecoration(color: activeColor.withOpacity(0.15), borderRadius: BorderRadius.circular(30)) : null,
      child: Row(
        children: [
          SvgPicture.asset(iconPath, height: 24, colorFilter: ColorFilter.mode(isActive ? activeColor : Colors.black45, BlendMode.srcIn)),
          if (isActive) const SizedBox(width: 6),
          if (isActive) Text(label, style: TextStyle(color: activeColor, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}