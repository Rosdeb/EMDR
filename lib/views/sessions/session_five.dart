import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jonssony/services/session_completion_service.dart';
import 'package:jonssony/views/sessions/session_six.dart';
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
  bool _isLoadingVideo = true;
  String _videoError = '';

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  Future<void> _initializePlayer() async {
    try {
      _chewieController?.dispose();
      _videoPlayerController?.dispose();

      if (mounted) {
        setState(() {
          _chewieController = null;
          _videoPlayerController = null;
          _isLoadingVideo = true;
          _videoError = '';
        });
      }

      await _ensureMediaLoaded();
      var videoObj = _mediaController.getFirstMedia('session-5', 'video');

      if (videoObj == null && !_mediaController.isLoading.value) {
        await _mediaController.fetchAllMedia();
        videoObj = _mediaController.getFirstMedia('session-5', 'video');
      }

      final videoUrl = videoObj?['url']?.toString().trim() ?? '';
      if (videoUrl.isEmpty) {
        throw Exception(
          _mediaController.errorMessage.value.isNotEmpty
              ? _mediaController.errorMessage.value
              : 'Session 5 video was not found in API.',
        );
      }

      final videoController = VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
      );
      await videoController.initialize();

      if (!mounted) {
        videoController.dispose();
        return;
      }

      final chewieController = ChewieController(
        videoPlayerController: videoController,
        autoPlay: false,
        aspectRatio: videoController.value.aspectRatio,
        materialProgressColors: ChewieProgressColors(
          playedColor: AppColors.mainAppColor,
          handleColor: AppColors.mainAppColor,
        ),
      );

      setState(() {
        _videoPlayerController = videoController;
        _chewieController = chewieController;
        _isLoadingVideo = false;
      });
    } catch (e) {
      debugPrint("Error initializing session 5 video: $e");
      if (!mounted) return;
      setState(() {
        _videoError = _cleanError(e);
        _isLoadingVideo = false;
      });
    }
  }

  Future<void> _ensureMediaLoaded() async {
    if (_mediaController.isLoading.value) {
      while (_mediaController.isLoading.value) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return;
    }

    if (_mediaController.allMedia.isEmpty ||
        _mediaController.getFirstMedia('session-5', 'video') == null) {
      await _mediaController.fetchAllMedia();
    }
  }

  String _cleanError(Object error) {
    final message = error.toString().replaceFirst('Exception: ', '').trim();
    return message.isEmpty
        ? 'Failed to load Session 5 video from API.'
        : message;
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
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
                child: _buildVideoPlayer(),
              ),
            ),
          ),

          // Text and Button Section
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          await SessionCompletionService.markCompleted(5);
                          Get.to(
                            () => const SessionSix(),
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

  Widget _buildVideoPlayer() {
    if (_chewieController != null) {
      return Chewie(controller: _chewieController!);
    }

    if (_videoError.isNotEmpty) {
      return _buildVideoError();
    }

    return const Center(
      child: CircularProgressIndicator(color: Color(0xFF537E5D)),
    );
  }

  Widget _buildVideoError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.white70, size: 28),
            const SizedBox(height: 8),
            Text(
              _videoError,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _isLoadingVideo ? null : _initializePlayer,
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF537E5D),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
