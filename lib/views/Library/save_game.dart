import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jonssony/utils/app_text.dart';
import 'bls_pdf_visuals.dart';
import 'simulation_screen.dart';
import 'simulation_settings.dart';

class SaveGame extends StatefulWidget {
  const SaveGame({super.key});

  @override
  State<SaveGame> createState() => _SaveGameState();
}

class _SaveGameState extends State<SaveGame> {
  static const _storageKey = 'bls_html_config';
  final GetStorage _storage = GetStorage();
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
            top: 0,
            left: 0,
            right: 0,
            height: 180,
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
                    ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 30,
                        bottom: 30,
                      ),
                      itemCount: _tracks.length,
                      itemBuilder: (context, index) {
                        return _buildTrackCard(index);
                      },
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

  Widget _buildTrackCard(int index) {
    final track = _tracks[index];
    final isPlaying = _playingIndex == index;

    final config = _savedBlsConfig;
    final environmentImage = _normaliseSceneSource(
      _configValue(config, 'background', 'mountains'),
    );
    final visualObject = _normaliseObjectSource(
      _configValue(config, 'object', 'sun'),
    );
    final soundKey = _configValue(config, 'sound', 'gentle-tone');
    final soundAsset = _configValue(config, 'soundAsset', '');
    final visualMediaType = _configValue(config, 'visualMediaType', 'image');
    final visualPoster = _configValue(config, 'visualPoster', '');
    final speed = _speedSeconds(_configValue(config, 'speed', 'medium'));
    final durationMinutes =
        int.tryParse(_configValue(config, 'durationMinutes', '60')) ?? 60;
    final dir = _directionFromKey(
      _configValue(config, 'direction', 'horizontal'),
    );

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
                environmentImage: environmentImage,
                visualObject: visualObject,
                speed: speed,
                audioAsset: soundAsset,
                soundKey: soundKey,
                visualMediaType: visualMediaType,
                visualPoster: visualPoster.isEmpty ? null : visualPoster,
                direction: dir,
                showCompletionQuestions: true,
                totalSets: 34,
                maxDurationMinutes: durationMinutes,
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
                color: Colors.white.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
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
                        if (isPlaying) ...[const SizedBox(height: 8)],
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

  Map<String, dynamic> get _savedBlsConfig {
    final raw = _storage.read(_storageKey);
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return const {};
  }

  String _configValue(
    Map<String, dynamic> config,
    String key,
    String fallback,
  ) {
    final value = config[key]?.toString().trim();
    return value == null || value.isEmpty ? fallback : value;
  }

  double _speedSeconds(String key) {
    switch (key) {
      case 'slow':
        return 2.6;
      case 'fast':
        return 1.5;
      case 'medium':
      default:
        return 2.0;
    }
  }

  String _normaliseSceneSource(String value) {
    if (value.startsWith(blsScenePrefix) ||
        value.startsWith('http') ||
        value.startsWith('assets/')) {
      return value;
    }
    return '$blsScenePrefix$value';
  }

  String _normaliseObjectSource(String value) {
    if (value.startsWith(blsObjectPrefix) ||
        value.startsWith('http') ||
        value.startsWith('assets/')) {
      return value;
    }
    return '$blsObjectPrefix$value';
  }

  AnimationDirection _directionFromKey(String key) {
    switch (key) {
      case 'vertical':
        return AnimationDirection.vertical;
      case 'diagonal-down':
        return AnimationDirection.diagonal;
      case 'diagonal-up':
        return AnimationDirection.diagonalReverse;
      case 'horizontal':
      default:
        return AnimationDirection.horizontal;
    }
  }

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
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const AppText(
            'Bilateral Stimulation',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ],
      ),
    );
  }
}
