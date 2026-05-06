import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jonssony/controller/auth_controller.dart';
import 'package:jonssony/services/calm_place_service.dart';

class ACalmPage extends StatefulWidget {
  const ACalmPage({super.key, this.mediaName, this.mediaUrl});

  final String? mediaName;
  final String? mediaUrl;

  @override
  State<ACalmPage> createState() => _ACalmPageState();
}

class _ACalmPageState extends State<ACalmPage> {
  late AudioPlayer _audioPlayer;
  String currentAudio = "calm place.wav";

  bool _isLoading = true;
  String currentDescription =
      "The air is crisp and I can hear the wind in the trees. It smells like pine and damp earth.";
  String backgroundImageUrl = "";
  String currentAudioUrl = "";
  bool _hasLocalCalmPlace = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    if ((widget.mediaUrl ?? '').trim().isNotEmpty) {
      _applyProvidedMedia();
      _initProvidedMediaAudio();
    } else {
      _loadSavedCalmPlace();
      _fetchCalmPlaceAndInit();
    }
  }

  void _applyProvidedMedia() {
    final mediaName = widget.mediaName?.trim() ?? '';
    final mediaUrl = widget.mediaUrl?.trim() ?? '';

    if (mediaName.isNotEmpty) currentAudio = mediaName;
    currentAudioUrl = mediaUrl;
  }

  Future<void> _initProvidedMediaAudio() async {
    try {
      await _setAudioFromPath(currentAudioUrl);
    } catch (e) {
      debugPrint("Provided audio load error: $e");
      await _setSavedAssetAudio();
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _loadSavedCalmPlace() {
    final box = GetStorage();
    final saved = box.read<bool>('calm_place_saved') ?? false;
    if (!saved) return;
    _hasLocalCalmPlace = true;

    final description = box.read<String>('calm_place_description') ?? '';
    final audioName = box.read<String>('calm_place_audio_name') ?? '';
    final audioUrl = box.read<String>('calm_place_audio_url') ?? '';
    final imageUrl = box.read<String>('calm_place_image_url') ?? '';

    _applyCalmPlaceData({
      'description': description,
      'audioName': audioName,
      'audioUrl': audioUrl,
      'imageUrl': imageUrl,
    });
  }

  void _applyCalmPlaceData(Map data) {
    final audioName = data['audioName']?.toString() ?? '';
    final description = data['description']?.toString() ?? '';
    final audioUrl = data['audioUrl']?.toString() ?? '';
    final imageUrl = data['imageUrl']?.toString() ?? '';

    if (audioName.isNotEmpty) currentAudio = audioName;
    if (description.isNotEmpty) currentDescription = description;
    currentAudioUrl = audioUrl;
    if (imageUrl.isNotEmpty) backgroundImageUrl = imageUrl;
  }

  Future<void> _fetchCalmPlaceAndInit() async {
    try {
      if (_hasLocalCalmPlace) {
        await _setSavedAudioSource();
        return;
      }

      final authController = Get.find<AuthController>();
      final token = authController.token;
      if (token != null) {
        final result = await CalmPlaceService.getCalmPlace(token);
        if (result['success'] == true && result['data'] != null) {
          final data = result['data'];

          if (data is List && data.isNotEmpty) {
            final firstItem = data.last; // get the latest one
            setState(() {
              _applyCalmPlaceData(firstItem);
            });

            final audioUrl = firstItem['audioUrl'];
            if (audioUrl != null && audioUrl.isNotEmpty) {
              await _setAudioFromPath(audioUrl);
            } else {
              await _setSavedAudioSource();
            }
          } else if (data is Map) {
            setState(() {
              _applyCalmPlaceData(data);
            });
            final audioUrl = data['audioUrl'];
            if (audioUrl != null && audioUrl.isNotEmpty) {
              await _setAudioFromPath(audioUrl);
            } else {
              await _setSavedAudioSource();
            }
          } else {
            await _setSavedAudioSource();
          }
        } else {
          await _setSavedAudioSource();
        }
      } else {
        await _setSavedAudioSource();
      }
    } catch (e) {
      debugPrint("Audio load error: $e");
      await _setSavedAssetAudio();
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _setSavedAudioSource() async {
    if (currentAudioUrl.isNotEmpty) {
      await _setAudioFromPath(currentAudioUrl);
      return;
    }

    await _setSavedAssetAudio();
  }

  Future<void> _setAudioFromPath(String path) async {
    final source = path.trim();
    if (source.startsWith('http://') || source.startsWith('https://')) {
      await _audioPlayer.setUrl(source);
      return;
    }

    if (source.startsWith('assets/')) {
      await _audioPlayer.setAsset(source);
      return;
    }

    if (source.isNotEmpty) {
      await _audioPlayer.setUrl(source);
      return;
    }

    await _setSavedAssetAudio();
  }

  Future<void> _setSavedAssetAudio() async {
    final assetName = currentAudio.isNotEmpty ? currentAudio : 'calm place.wav';
    try {
      await _audioPlayer.setAsset('assets/audio/$assetName');
    } catch (_) {
      currentAudio = 'calm place.wav';
      await _audioPlayer.setAsset('assets/audio/calm place.wav');
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
            child: Image.asset('assets/images/my_emdr.png', fit: BoxFit.fill),
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
                    _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF5A7D63),
                            ),
                          )
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              final imageHeight = (constraints.maxHeight * 0.42)
                                  .clamp(220.0, 360.0);

                              return SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                padding: EdgeInsets.fromLTRB(
                                  15,
                                  40,
                                  15,
                                  MediaQuery.of(context).padding.bottom + 20,
                                ),
                                child: Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(30),
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(
                                          sigmaX: 10,
                                          sigmaY: 10,
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(
                                              0.2,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              30,
                                            ),
                                            border: Border.all(
                                              color: Colors.white.withOpacity(
                                                0.3,
                                              ),
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                height: imageHeight,
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  color: const Color(
                                                    0xFFFAF3E0,
                                                  ).withOpacity(0.6),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  child:
                                                      backgroundImageUrl
                                                          .isNotEmpty
                                                      ? _buildCalmImage(
                                                          fallbackAsset:
                                                              'assets/images/home_bg2.jpg',
                                                          fit: BoxFit.cover,
                                                        )
                                                      : Image.asset(
                                                          'assets/images/home_bg2.jpg',
                                                          fit: BoxFit.cover,
                                                        ),
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              _buildAudioPlayerCard(),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
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

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        left: 10,
        right: 20,
        bottom: 10,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF2E3E32)),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            "My Calm Space",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E3E32),
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
                    onTap: () =>
                        playing ? _audioPlayer.pause() : _audioPlayer.play(),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFF5A7D63), // Muted green
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        playing
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
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
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    _buildSlider(),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Description Text from Image
          Text(
            currentDescription,
            style: const TextStyle(
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

  Widget _buildCalmImage({required String fallbackAsset, required BoxFit fit}) {
    final imagePath = backgroundImageUrl.trim();

    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        fit: fit,
        errorBuilder: (context, error, stackTrace) =>
            Image.asset(fallbackAsset, fit: fit),
      );
    }

    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        fit: fit,
        errorBuilder: (context, error, stackTrace) =>
            Image.asset(fallbackAsset, fit: fit),
      );
    }

    if (imagePath.isNotEmpty) {
      final file = File(imagePath);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: fit,
          errorBuilder: (context, error, stackTrace) =>
              Image.asset(fallbackAsset, fit: fit),
        );
      }
    }

    return Image.asset(fallbackAsset, fit: fit);
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
                    ? (position.inMilliseconds / duration.inMilliseconds).clamp(
                        0.0,
                        1.0,
                      )
                    : 0,
                onChanged: (v) {
                  _audioPlayer.seek(
                    Duration(
                      milliseconds: (v * duration.inMilliseconds).toInt(),
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(position),
                  style: const TextStyle(fontSize: 10),
                ),
                Text(
                  _formatDuration(duration),
                  style: const TextStyle(fontSize: 10),
                ),
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
