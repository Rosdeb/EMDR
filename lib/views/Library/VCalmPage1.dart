import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jonssony/utils/app_colors.dart';
import 'package:jonssony/utils/app_text.dart';
import 'package:get/get.dart';
import 'package:jonssony/controller/media_controller.dart';

class VCalmPage1 extends StatefulWidget {
  const VCalmPage1({super.key, this.title, this.videoUrl});

  final String? title;
  final String? videoUrl;

  @override
  State<VCalmPage1> createState() => _VCalmPage1State();
}

class _VCalmPage1State extends State<VCalmPage1> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  final box = GetStorage();
  final Set<int> _selectedIndices = {};
  final MediaController _mediaController = Get.find<MediaController>();

  @override
  void initState() {
    super.initState();
    _initializePlayer();
    _loadSavedData();
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  Future<void> _initializePlayer() async {
    final providedUrl = widget.videoUrl?.trim() ?? '';
    if (providedUrl.startsWith('http://') ||
        providedUrl.startsWith('https://')) {
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(providedUrl),
      );
    } else if (providedUrl.startsWith('assets/')) {
      _videoPlayerController = VideoPlayerController.asset(providedUrl);
    } else {
      // Wait briefly if media is still loading
      if (_mediaController.isLoading.value) {
        await Future.delayed(const Duration(milliseconds: 500));
      }

      final videoObj = _mediaController.getFirstMedia(
        'spiral technique',
        'video',
      );

      if (videoObj != null && videoObj['url'] != null) {
        _videoPlayerController = VideoPlayerController.networkUrl(
          Uri.parse(videoObj['url']),
        );
      } else {
        // Fallback to local asset
        _videoPlayerController = VideoPlayerController.asset(
          'assets/video/spiral_technique.mp4',
        );
      }
    }

    await _videoPlayerController.initialize();
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: false,
      aspectRatio: _videoPlayerController.value.aspectRatio,
      materialProgressColors: ChewieProgressColors(
        playedColor: AppColors.mainAppColor,
        handleColor: AppColors.mainAppColor,
      ),
    );
    if (mounted) setState(() {});
  }

  void _loadSavedData() {
    List<dynamic>? saved = box.read('selected_thoughts');
    if (saved != null) {
      setState(() => _selectedIndices.addAll(saved.cast<int>()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
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

                    // Content
                    SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 30,
                        bottom: 30,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Video Card ──────────────────────────
                          _buildVideoCard(),

                          const SizedBox(height: 20),

                          // ── Quote Card ──────────────────────────
                          _buildQuoteCard(
                            quote:
                                '"Beautifully simple. Incredibly easy to use but can be customized to your hiring workflow and needs."',
                            author:
                                'Mike Preuss, Co-founder and CEO, Visible.vc',
                          ),
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

  Widget _buildVideoCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
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
      ),
    );
  }

  // ── Quote Card (missing from original) ──────────────────────
  Widget _buildQuoteCard({required String quote, required String author}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.55),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quote text
              AppText(
                quote,
                fontSize: 15,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
              const SizedBox(height: 12),
              // Author
              AppText(
                author,
                fontSize: 13,
                color: Colors.black45,
                fontWeight: FontWeight.w400,
              ),
            ],
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
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          AppText(
            widget.title ?? 'Spiral Technique',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ],
      ),
    );
  }
}
