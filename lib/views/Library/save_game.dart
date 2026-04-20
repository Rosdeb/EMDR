import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jonssony/utils/app_text.dart';
import 'simulation_screen.dart';
import 'simulation_settings.dart';
import 'package:jonssony/controller/bilateral_controller.dart';

class SaveGame extends StatefulWidget {
  const SaveGame({super.key});

  @override
  State<SaveGame> createState() => _SaveGameState();
}

class _SaveGameState extends State<SaveGame> {
  final BilateralController _bilateralController = Get.find<BilateralController>();
  int? _playingIndex;

  final List<Map<String, String>> _tracks = [
    {'title': 'Mountain Sanctuary', 'duration': '5:00'},
    {'title': 'Mountain Sanctuary', 'duration': '5:00'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Header image
          Positioned(
            top: 0, left: 0, right: 0, height: 180,
            child: Image.asset('assets/images/my_emdr.png', fit: BoxFit.fill),
          ),

          Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: Stack(
                  children: [
                    // Background
                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(35),
                            topRight: Radius.circular(35),
                          ),
                          image: DecorationImage(
                            image: AssetImage('assets/images/bg_library.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),

                    // Track list
                    Obx(() {
                      if (_bilateralController.isLoading.value) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      
                      return ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(
                          left: 20, right: 20, top: 30, bottom: 30,
                        ),
                        itemCount: _tracks.length,
                        itemBuilder: (context, index) {
                          return _buildTrackCard(index);
                        },
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrackCard(int index) {
    final track = _tracks[index];
    final isPlaying = _playingIndex == index;
    
    // Convert backend formats to SimulationSettings
    final settings = _bilateralController.userSettings;
    final speedStr = settings['speed'] ?? 'medium';
    double speed = 4.0;
    if (speedStr == 'slow') speed = 8.0;
    else if (speedStr == 'fast') speed = 2.0;

    final dirStr = settings['direction'] ?? 'left-right';
    AnimationDirection dir = AnimationDirection.horizontal;
    if (dirStr == 'top-bottom') dir = AnimationDirection.vertical;
    else if (dirStr == 'diagonal-down') dir = AnimationDirection.diagonal;
    else if (dirStr == 'diagonal-up') dir = AnimationDirection.diagonalReverse;

    return GestureDetector(
      onTap: () {
        setState(() {
          _playingIndex = index;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SimulationScreen(
              settings: SimulationSettings(
                environmentImage: settings['environmentId'] ?? 'assets/images/mountain.jpg',
                visualObject: settings['iconUrl'] ?? 'assets/images/butterfly.png',
                speed: speed,
                audioAsset: settings['soundId'] ?? 'assets/audio/calm_place.wav',
                direction: dir,
                isNetworkImage: settings.isNotEmpty,
              ),
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.55),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  // Play / Pause button
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFF537E5D),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Title & duration
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          track['title']!,
                          fontSize: 15,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                        if (isPlaying) ...[
                          const SizedBox(height: 8),

                        ],
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }



  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        left: 10,
        bottom: 10,
      ),
      child: Row(children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        const AppText('Bilateral Stimulation',
            fontSize: 20, fontWeight: FontWeight.bold),
      ]),
    );
  }
}