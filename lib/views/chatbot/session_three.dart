import 'package:flutter/material.dart';
import 'package:jonssony/utils/app_colors.dart';

import 'package:jonssony/utils/app_text.dart';
import 'package:jonssony/widets/custom_home_bg.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:just_audio/just_audio.dart';

class SessionThreePage extends StatefulWidget {
  const SessionThreePage({super.key});

  @override
  State<SessionThreePage> createState() => _SessionThreePageState();
}

class _SessionThreePageState extends State<SessionThreePage> {
  String currentAudio = "audio.mp4";
  final List<String> audioList = [
    "audio.mp4",
  ];
  File? _pickedImage;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
  }

  void _initAudioPlayer() async {
     // Ensure the file exists in assets. For now, we simulate loading or try to load if possible.
     // Since assets are not files on disk directly easily without loading to cache, just_audio can load from asset.
     // We will try to load the current audio.
     try {
       await _audioPlayer.setAsset('assets/audio/$currentAudio');
     } catch (e) {
       print("Error loading audio: $e");
     }

     _audioPlayer.playerStateStream.listen((state) {
       if (mounted) {
         setState(() {
           isPlaying = state.playing;
         });
       }
       if (state.processingState == ProcessingState.completed) {
         if (mounted) {
            _audioPlayer.seek(Duration.zero);
            _audioPlayer.pause();
         }
       }
     });

     _audioPlayer.durationStream.listen((newDuration) {
       if (mounted) {
         setState(() {
           duration = newDuration ?? Duration.zero;
         });
       }
     });

     _audioPlayer.positionStream.listen((newPosition) {
       if (mounted) {
         setState(() {
           position = newPosition;
         });
       }
     });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      if (mounted) {
        setState(() {
          _pickedImage = File(image.path);
        });
      }
    }
  }

  void _showAudioSelectionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppText("Select Audio", fontSize: 18, fontWeight: FontWeight.bold),
              const SizedBox(height: 20),
              ...audioList.map((audio) => ListTile(
                leading: Icon(
                  Icons.music_note,
                  color: currentAudio == audio ? const Color(0xFF537E5D) : Colors.grey,
                ),
                title: AppText(
                  audio,
                  fontSize: 16,
                  color: currentAudio == audio ? const Color(0xFF537E5D) : Colors.black87,
                  fontWeight: currentAudio == audio ? FontWeight.bold : FontWeight.normal,
                ),
                trailing: currentAudio == audio
                    ? const Icon(Icons.check_circle, color: Color(0xFF537E5D))
                    : null,
                onTap: () {
                  setState(() {
                    currentAudio = audio;
                    // Reset player with new audio
                    try {
                       _audioPlayer.setAsset('assets/audio/$currentAudio');
                       _audioPlayer.play();
                    } catch (e) {
                       print("Error playing new audio: $e");
                    }
                  });
                  Navigator.pop(context);
                },
              )),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.5)),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF2E3E32), size: 20),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            splashRadius: 20,
          ),
        ),
        title: const AppText("Session 3", color: Color(0xFF2E3E32), fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: Stack(
        children: [
          Custom_Home_Bg(),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildGlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppText("Visual", fontSize: 16, fontWeight: FontWeight.bold),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildThumb('assets/images/comunity.jpg', true),
                            _buildThumb('assets/images/make_more.jpg', false),
                            _buildThumb('assets/images/night.jpg', false),
                          ],
                        ),
                        const SizedBox(height: 15),

                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: double.infinity,
                            height: 140, // Slightly taller to show image better
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.withOpacity(0.5), style: BorderStyle.solid),
                              borderRadius: BorderRadius.circular(15),
                              image: _pickedImage != null ? DecorationImage(
                                image: FileImage(_pickedImage!),
                                fit: BoxFit.cover,
                              ) : null,
                            ),
                            child: _pickedImage == null ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.cloud_upload_outlined, color: Colors.grey, size: 40),
                                SizedBox(height: 5),
                                AppText("Click to upload", fontWeight: FontWeight.bold, fontSize: 14),
                                AppText("PNG or GIF (max. 5MB)", fontSize: 10, color: Colors.grey),
                              ],
                            ) : Stack(
                              children: [
                                Positioned(
                                  right: 10, top: 10,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                    child: const Icon(Icons.edit, size: 16, color: Colors.black),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),


                  _buildGlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppText("Set the mood", fontWeight: FontWeight.bold, fontSize: 16),
                        const SizedBox(height: 10),
                        _buildAudioPlayer(context, currentAudio, true),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),


                  _buildGlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppText("Describe this place", fontWeight: FontWeight.bold, fontSize: 16),
                        const SizedBox(height: 10),
                        Container(
                          height: 100,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const TextField(
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: "Why does this place make you feel safe? E.g., 'The air is crisp...'",
                              border: InputBorder.none,
                              hintStyle: TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {

                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.mainAppColor),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const AppText("Back", color: AppColors.mainAppColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.mainAppColor,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const AppText("Save & Continue", color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),
                  // Removed the bottom list as per requirement
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: child,
    );
  }

  Widget _buildThumb(String path, bool isSelected) {
    return Container(
      width: 90,
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: isSelected ? Border.all(color: Colors.blue, width: 2) : null,
        image: DecorationImage(image: AssetImage(path), fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildAudioPlayer(BuildContext context, String title, bool hasReplace) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            if (isPlaying) {
              _audioPlayer.pause();
            } else {
              _audioPlayer.play();
            }
          },
          child: Icon(
            isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
            color: const Color(0xFF537E5D),
            size: 45,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(title, fontSize: 13, fontWeight: FontWeight.bold),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                  trackHeight: 4,
                  activeTrackColor: const Color(0xFF537E5D),
                  inactiveTrackColor: Colors.grey[300],
                  thumbColor: const Color(0xFF537E5D),
                  overlayColor: const Color(0xFF537E5D).withOpacity(0.2),
                ),
                child: Slider(
                  min: 0,
                  max: duration.inSeconds.toDouble(),
                  value: position.inSeconds.toDouble().clamp(0, duration.inSeconds.toDouble()),
                  onChanged: (value) async {
                    final position = Duration(seconds: value.toInt());
                    await _audioPlayer.seek(position);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppText(_formatDuration(position), fontSize: 10, color: Colors.black54),
                    AppText(_formatDuration(duration), fontSize: 10, color: Colors.black54),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (hasReplace) ...[
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () => _showAudioSelectionModal(context),
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF537E5D),
                minimumSize: const Size(60, 30),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
            ),
            child: const AppText("Replace", fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ]
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  // _buildAudioListItem is no longer needed in the main body, but kept if we want to reuse it elsewhere, 
  // though for the modal I used ListTile for simplicity. I will remove it to clean up as it's not used.
}
/*
Replace  button e click korle _buildAudioListItem gulu pop up akare show korbe and music gula change hobe
 */