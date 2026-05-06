import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jonssony/services/session_completion_service.dart';
import 'package:jonssony/views/sessions/session_bilateral_simulation.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:jonssony/controller/media_controller.dart';
import 'package:jonssony/utils/app_colors.dart';

class SessionFive extends StatefulWidget {
  const SessionFive({super.key});

  @override
  State<SessionFive> createState() => _SessionFiveState();
}

class _SessionFiveState extends State<SessionFive> {
  final MediaController _mediaController = Get.find<MediaController>();
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  Future<void> _initializePlayer() async {
    if (_mediaController.isLoading.value) {
      await Future.delayed(const Duration(milliseconds: 500));
    }

    // Attempt to get video from API category
    // Using a generic search or a specific category if known.
    // For now, using 'session-5' as the category for Session 5.
    final videoObj = _mediaController.getFirstMedia('session-5', 'video');

    if (videoObj != null && videoObj['url'] != null) {
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(videoObj['url']),
      );
    } else {
      // Fallback
      _videoPlayerController = VideoPlayerController.asset(
        'assets/video/spiral_technique.mp4',
      );
    }

    try {
      await _videoPlayerController!.initialize();
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: false,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        materialProgressColors: ChewieProgressColors(
          playedColor: AppColors.mainAppColor,
          handleColor: AppColors.mainAppColor,
        ),
      );
      if (mounted) setState(() {});
    } catch (e) {
      print("Error initializing video: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg_library.jpg',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: _buildMainContentCard(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Get.back(),
          ),
          const Text(
            "Session 5",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContentCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Video Section
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Container(
                height: 250,
                width: double.infinity,
                color: Colors.black,
                child: _chewieController != null
                    ? Chewie(controller: _chewieController!)
                    : const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF537E5D),
                        ),
                      ),
              ),
            ),
          ),

          // Text and Button Section
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Your Journey Guide",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "When I was little (Childhood)",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF444444),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "This may or may not be relevant to what you would like to work on so skip it if not.",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black.withOpacity(0.7),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Float back in time and see if you remember feeling this way (from your situation) as a child or any other time?",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black.withOpacity(0.7),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 25),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          await SessionCompletionService.markCompleted(5);
                          Get.to(
                            () => const SessionBilateralSimulation(),
                            arguments: Get.arguments,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF537E5D),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "Save & Continue",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade300),
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Colors.white,
                        ),
                        child: const Text(
                          "Skip for now",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
