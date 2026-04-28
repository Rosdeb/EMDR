import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jonssony/controller/auth_controller.dart';
import 'package:jonssony/services/calm_place_service.dart';

class ACalmPage extends StatefulWidget {
  const   ACalmPage({super.key});

  @override
  State<ACalmPage> createState() => _ACalmPageState();
}

class _ACalmPageState extends State<ACalmPage> {
  late AudioPlayer _audioPlayer;
  String currentAudio = "Calm_place.mp3";

  bool _isLoading = true;
  String currentDescription = "The air is crisp and I can hear the wind in the trees. It smells like pine and damp earth.";
  String backgroundImageUrl = "";

  // CBT Formulation Q&A data from session_two
  bool _hasCbtData = false;
  final List<Map<String, String>> _cbtQA = [];

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _loadCbtData();
    _fetchCalmPlaceAndInit();
  }

  void _loadCbtData() {
    final box = GetStorage();
    final saved = box.read<bool>('cbt_saved') ?? false;
    if (!saved) return;

    final qaItems = <Map<String, String>>[];

    void addIfNotEmpty(String question, String key) {
      final val = box.read<String>(key) ?? '';
      if (val.isNotEmpty) qaItems.add({'q': question, 'a': val});
    }

    addIfNotEmpty('A Recent Happening', 'cbt_recent_happening');
    addIfNotEmpty('Triggers', 'cbt_triggers');
    addIfNotEmpty('My Thoughts', 'cbt_thoughts');
    addIfNotEmpty('My Feelings', 'cbt_feelings');
    addIfNotEmpty('My Behaviors', 'cbt_behaviors');
    addIfNotEmpty('Deep-Down Beliefs', 'cbt_deep_beliefs');
    addIfNotEmpty('When I Was Little', 'cbt_childhood');
    addIfNotEmpty('The Rules I Follow', 'cbt_rules');
    addIfNotEmpty('The Consequences', 'cbt_consequences');
    addIfNotEmpty('My Superpowers', 'cbt_superpowers');

    setState(() {
      _hasCbtData = qaItems.isNotEmpty;
      _cbtQA.addAll(qaItems);
    });
  }

  Future<void> _fetchCalmPlaceAndInit() async {
    try {
      final authController = Get.find<AuthController>();
      final token = authController.token;
      if (token != null) {
        final result = await CalmPlaceService.getCalmPlace(token);
        if (result['success'] == true && result['data'] != null) {
          final data = result['data'];
          
          if (data is List && data.isNotEmpty) {
             final firstItem = data.last; // get the latest one
             setState(() {
              if (firstItem['audioName'] != null && firstItem['audioName'].isNotEmpty) {
                 currentAudio = firstItem['audioName'];
              }
              if (firstItem['description'] != null && firstItem['description'].isNotEmpty) {
                 currentDescription = firstItem['description'];
              }
              if (firstItem['imageUrl'] != null && firstItem['imageUrl'].isNotEmpty) {
                 backgroundImageUrl = firstItem['imageUrl'];
              }
            });
             
            final audioUrl = firstItem['audioUrl'];
            if (audioUrl != null && audioUrl.isNotEmpty) {
               await _audioPlayer.setUrl(audioUrl);
            } else {
               await _audioPlayer.setAsset('assets/audio/calm place.wav');
            }
          } else if (data is Map) {
            setState(() {
              if (data['audioName'] != null && data['audioName'].isNotEmpty) {
                 currentAudio = data['audioName'];
              }
              if (data['description'] != null && data['description'].isNotEmpty) {
                 currentDescription = data['description'];
              }
              if (data['imageUrl'] != null && data['imageUrl'].isNotEmpty) {
                 backgroundImageUrl = data['imageUrl'];
              }
            });
            final audioUrl = data['audioUrl'];
            if (audioUrl != null && audioUrl.isNotEmpty) {
               await _audioPlayer.setUrl(audioUrl);
            } else {
               await _audioPlayer.setAsset('assets/audio/calm place.wav');
            }
          } else {
             await _audioPlayer.setAsset('assets/audio/calm place.wav');
          }
        } else {
           await _audioPlayer.setAsset('assets/audio/calm place.wav');
        }
      } else {
        await _audioPlayer.setAsset('assets/audio/calm place.wav');
      }
    } catch (e) {
      debugPrint("Audio load error: $e");
      await _audioPlayer.setAsset('assets/audio/calm place.wav');
    } finally {
      setState(() {
        _isLoading = false;
      });
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
            child: backgroundImageUrl.isNotEmpty
                ? Image.network(
                    backgroundImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      'assets/images/home_bg1.jpg',
                      fit: BoxFit.cover,
                    ),
                  )
                : Image.asset(
                    'assets/images/home_bg1.jpg',
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
                  if (_isLoading)
                    const Expanded(child: Center(child: CircularProgressIndicator(color: Color(0xFF5A7D63))))
                  else
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
                                // Inner Card - Selected Image
                                Container(
                                  height: 400, // Matching the tall image in UI
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFAF3E0).withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: backgroundImageUrl.isNotEmpty
                                        ? Image.network(
                                            backgroundImageUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => Image.asset(
                                              'assets/images/home_bg2.jpg',
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : Image.asset(
                                            'assets/images/home_bg2.jpg', // Fallback inner drawing
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                ),

                                const SizedBox(height: 10),

                                // Audio Controller Card
                                _buildAudioPlayerCard(),

                                // CBT Q&A section
                                if (_hasCbtData) ...[
                                  const SizedBox(height: 10),
                                  _buildCbtQACard(),
                                ],
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

  Widget _buildCbtQACard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF5A7D63).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.psychology_outlined, color: Color(0xFF5A7D63), size: 20),
              ),
              const SizedBox(width: 10),
              const Text(
                'My Journey Formulation',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2E3E32),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFDCEADE), thickness: 1),
          const SizedBox(height: 8),
          ..._cbtQA.map((item) => _buildQAItem(item['q']!, item['a']!)),
        ],
      ),
    );
  }

  Widget _buildQAItem(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.help_outline_rounded, size: 14, color: Color(0xFF5A7D63)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  question,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF5A7D63),
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F9F5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFDCEADE)),
            ),
            child: Text(
              answer,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF2D3436),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) =>
      "${d.inMinutes.remainder(60)}:${d.inSeconds.remainder(60).toString().padLeft(2, '0')}";
}