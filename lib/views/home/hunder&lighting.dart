import 'dart:ui';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ThunderLightningPage extends StatelessWidget {
  const ThunderLightningPage({super.key});

  static const List<_ThunderVideo> _videos = [
    _ThunderVideo(
      title: 'Thunder and Lightning',
      url:
          'https://res.cloudinary.com/dbglkfj2z/video/upload/v1776800399/my-emdr/media/media_69c70af6f992b944bccd41a9_1776800376028.mov',
    ),
    _ThunderVideo(
      title: 'Thunder and Lightning Copy',
      url:
          'https://res.cloudinary.com/dbglkfj2z/video/upload/v1777834560/my-emdr/media/media_69c709d3cb049607feb74d9e_1777834486531.mp4',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    const double appBarImageHeight = 150;

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
                  children: [
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
                    Positioned.fill(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(
                          20,
                          28,
                          20,
                          MediaQuery.of(context).padding.bottom + 30,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Thunder and Lightning',
                              style: TextStyle(
                                color: Color(0xFF292524),
                                fontSize: 30,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Georgia',
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'A grounding technique to help when emotions feel overwhelming.',
                              style: TextStyle(
                                color: const Color(
                                  0xFF383634,
                                ).withValues(alpha: 0.82),
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(32),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 12,
                                  sigmaY: 12,
                                ),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.22),
                                    borderRadius: BorderRadius.circular(32),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                  ),
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      final isWide =
                                          constraints.maxWidth >= 720;
                                      if (!isWide) {
                                        return Column(
                                          children: [
                                            for (final video in _videos) ...[
                                              _ThunderVideoCard(video: video),
                                              if (video != _videos.last)
                                                const SizedBox(height: 18),
                                            ],
                                          ],
                                        );
                                      }

                                      return Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          for (final video in _videos) ...[
                                            Expanded(
                                              child: _ThunderVideoCard(
                                                video: video,
                                              ),
                                            ),
                                            if (video != _videos.last)
                                              const SizedBox(width: 18),
                                          ],
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
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

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 10,
        right: 16,
        bottom: 8,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF2E3E32)),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              'Thunder and Lightning',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Color(0xFF2E3E32),
                fontSize: 21,
                fontWeight: FontWeight.w700,
                fontFamily: 'Georgia',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThunderVideoCard extends StatefulWidget {
  const _ThunderVideoCard({required this.video});

  final _ThunderVideo video;

  @override
  State<_ThunderVideoCard> createState() => _ThunderVideoCardState();
}

class _ThunderVideoCardState extends State<_ThunderVideoCard> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _initializeVideo() async {
    try {
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.video.url),
      );
      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _videoController = controller;
        _chewieController = ChewieController(
          videoPlayerController: controller,
          autoPlay: false,
          looping: false,
          allowFullScreen: true,
          allowMuting: true,
          aspectRatio: controller.value.aspectRatio == 0
              ? 16 / 9
              : controller.value.aspectRatio,
          materialProgressColors: ChewieProgressColors(
            playedColor: const Color(0xFF5A7C5A),
            handleColor: const Color(0xFF5A7C5A),
            bufferedColor: const Color(0xFFBFD4C3),
            backgroundColor: Colors.white24,
          ),
        );
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Video load korte problem hocche. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.46),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Colors.white.withValues(alpha: 0.52)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 24,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  color: Colors.black.withValues(alpha: 0.08),
                  child: _buildVideoContent(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F3EA),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.videocam_outlined,
                            color: Color(0xFF5A7C5A),
                            size: 17,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            widget.video.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF292524),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Visual grounding exercise for emotional regulation.',
                      style: TextStyle(
                        color: Color(0xFF78716C),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoContent() {
    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Text(
            _errorMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFB42318),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    final chewieController = _chewieController;
    if (chewieController == null) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF5A7C5A)),
      );
    }

    return Chewie(controller: chewieController);
  }
}

class _ThunderVideo {
  const _ThunderVideo({required this.title, required this.url});

  final String title;
  final String url;
}
