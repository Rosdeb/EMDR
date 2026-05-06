import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jonssony/controller/auth_controller.dart';
import 'package:jonssony/services/media_service.dart';
import 'package:jonssony/services/session_completion_service.dart';
import 'package:jonssony/utils/app_colors.dart';
import 'package:jonssony/views/sessions/session_two.dart';
import 'package:video_player/video_player.dart';

const String _fixedSessionVideoId = '69e7c604fd68f032aa7a2c61';
const String _fixedSessionVideoCategory = 'session-1';

class SessionOne extends StatefulWidget {
  final String journeyId;
  final String journeyTitle;
  final String sessionId;

  const SessionOne({
    super.key,
    this.journeyId = '',
    this.journeyTitle = '',
    this.sessionId = '',
  });

  @override
  State<SessionOne> createState() => _SessionOneState();
}

class _SessionOneState extends State<SessionOne> {
  final AuthController _authController = Get.find<AuthController>();
  final Map<String, bool> _checkedItems = {};
  final Map<String, int> _lastSyncedProgress = {
    'watchedSeconds': -1,
    'totalSeconds': -1,
  };

  VideoPlayerController? _videoPlayerController;
  bool _isLoadingVideo = true;
  bool _videoEnded = false;
  bool _isPlaying = false;
  String _videoError = '';
  String _videoSrc = '';
  Duration _currentTime = Duration.zero;
  Duration _duration = Duration.zero;

  final List<_ReflectionQuestion> _questions = const [
    _ReflectionQuestion(
      id: 1,
      question: 'How did this session make you feel?',
      options: [
        'Calm and relaxed',
        'Slightly uncomfortable',
        'Emotionally triggered',
      ],
    ),
    _ReflectionQuestion(
      id: 2,
      question: 'Were you able to focus on the bilateral stimulation?',
      options: [
        'Yes, throughout the entire session',
        'Partially, I got distracted',
        'No, I found it difficult to focus',
      ],
    ),
    _ReflectionQuestion(
      id: 3,
      question: 'Did any memories or emotions surface during the session?',
      options: [
        'Yes, and I was able to process them',
        'Yes, but I felt overwhelmed',
        'No, nothing came up',
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadSessionVideo();
  }

  @override
  void dispose() {
    unawaited(_syncVideoProgress());
    _videoPlayerController?.removeListener(_handleVideoTick);
    _videoPlayerController?.dispose();
    super.dispose();
  }

  Future<void> _loadSessionVideo() async {
    final token = _authController.token;
    if (token == null || token.isEmpty) {
      if (!mounted) return;
      setState(() {
        _videoError = 'Please sign in again to load the session video.';
        _isLoadingVideo = false;
      });
      return;
    }

    try {
      setState(() {
        _isLoadingVideo = true;
        _videoError = '';
      });

      final result = await MediaService.getAllMedia(token: token, limit: 100);
      if (result['success'] != true) {
        throw Exception(result['message'] ?? 'Failed to fetch session video.');
      }

      final data = result['data'];
      final mediaList = data is Map ? data['media'] as List<dynamic>? : null;
      Map<dynamic, dynamic>? sessionVideo;
      for (final item in mediaList ?? []) {
        if (item is Map &&
            item['_id']?.toString() == _fixedSessionVideoId &&
            item['mediaType']?.toString() == 'video' &&
            item['status']?.toString() == 'active' &&
            _categoryName(item).toLowerCase() == _fixedSessionVideoCategory) {
          sessionVideo = item;
          break;
        }
      }

      final videoUrl = sessionVideo?['url']?.toString();
      if (videoUrl == null || videoUrl.isEmpty) {
        throw Exception(
          'The fixed session video was not found in the session-1 category.',
        );
      }

      final controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      await controller.initialize();
      controller.addListener(_handleVideoTick);

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _videoPlayerController = controller;
        _videoSrc = videoUrl;
        _duration = controller.value.duration;
        _isLoadingVideo = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _videoError = _cleanError(error);
        _isLoadingVideo = false;
      });
    }
  }

  void _handleVideoTick() {
    final controller = _videoPlayerController;
    if (controller == null || !controller.value.isInitialized || !mounted) {
      return;
    }

    final position = controller.value.position;
    final duration = controller.value.duration;
    final isPlaying = controller.value.isPlaying;
    final reachedEnd =
        duration > Duration.zero &&
        position >= duration - const Duration(milliseconds: 250);

    setState(() {
      _currentTime = position;
      _duration = duration;
      _isPlaying = isPlaying;
    });

    if (reachedEnd && !_videoEnded) {
      unawaited(_handleVideoEnd(duration));
    }
  }

  Future<void> _handlePlayPause() async {
    final controller = _videoPlayerController;
    if (controller == null || !controller.value.isInitialized) return;

    if (_videoEnded) {
      await controller.seekTo(Duration.zero);
      if (!mounted) return;
      setState(() {
        _currentTime = Duration.zero;
        _videoEnded = false;
      });
    }

    if (_isPlaying) {
      await controller.pause();
      await _syncVideoProgress();
    } else {
      await controller.play();
    }
  }

  Future<void> _handleStop() async {
    final controller = _videoPlayerController;
    if (controller == null || !controller.value.isInitialized) return;

    await controller.pause();
    await _syncVideoProgress();
    if (mounted) {
      setState(() => _isPlaying = false);
    }
  }

  Future<void> _handleVideoEnd(Duration duration) async {
    if (!mounted || _videoEnded) return;
    setState(() {
      _videoEnded = true;
      _isPlaying = false;
      _currentTime = duration;
    });
    await _syncVideoProgress(duration, duration);
  }

  Future<void> _syncVideoProgress([
    Duration? watchedOverride,
    Duration? totalOverride,
  ]) async {
    final token = _authController.token;
    if (token == null || token.isEmpty || _videoSrc.isEmpty) return;

    final controller = _videoPlayerController;
    final watchedSeconds = math.max(
      0,
      (watchedOverride ?? controller?.value.position ?? _currentTime).inSeconds,
    );
    final totalSeconds = math.max(
      0,
      (totalOverride ?? controller?.value.duration ?? _duration).inSeconds,
    );

    if (watchedSeconds == _lastSyncedProgress['watchedSeconds'] &&
        totalSeconds == _lastSyncedProgress['totalSeconds']) {
      return;
    }

    try {
      final result = await MediaService.updateMediaProgress(
        token: token,
        mediaId: _fixedSessionVideoId,
        watchedSeconds: watchedSeconds,
        totalSeconds: totalSeconds,
      );

      if (result['success'] == true) {
        _lastSyncedProgress['watchedSeconds'] = watchedSeconds;
        _lastSyncedProgress['totalSeconds'] = totalSeconds;
      }
    } catch (error) {
      debugPrint('Error saving session video progress: $error');
    }
  }

  void _handleCheck(int questionId, int optionIndex) {
    final key = '$questionId-$optionIndex';
    setState(() {
      _checkedItems[key] = !(_checkedItems[key] ?? false);
    });
  }

  Future<void> _goToNextStep() async {
    final journeyId = widget.journeyId.isNotEmpty
        ? widget.journeyId
        : _routeArgumentValue('journeyId');
    final journeyTitle = widget.journeyTitle.isNotEmpty
        ? widget.journeyTitle
        : _routeArgumentValue('title');
    final sessionId = widget.sessionId.isNotEmpty
        ? widget.sessionId
        : _routeArgumentValue('sessionId');

    await SessionCompletionService.markCompleted(1, journeyId: journeyId);

    Get.to(
      () => const CBTFormulationPage(),
      arguments: {
        'journeyId': journeyId,
        'title': journeyTitle,
        'sessionId': sessionId,
      },
    );
  }

  String _routeArgumentValue(String key) {
    final args = Get.arguments;
    if (args is Map && args[key] != null) {
      return args[key].toString();
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    const double appBarImageHeight = 170;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: appBarImageHeight,
            child: Image.asset('assets/images/my_emdr.png', fit: BoxFit.cover),
          ),

          Column(
            children: [
              _buildCustomAppBar(),
              const SizedBox(height: 20),
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
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
                        padding: const EdgeInsets.fromLTRB(16, 30, 16, 24),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final isWide = constraints.maxWidth >= 720;
                            return Column(
                              children: [
                                _buildVideoStage(),
                                if (_videoEnded) ...[
                                  const SizedBox(height: 18),
                                  Align(
                                    alignment: Alignment.center,
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxWidth: isWide ? 520 : 640,
                                      ),
                                      child: _buildReflectionCard(),
                                    ),
                                  ),
                                ],
                              ],
                            );
                          },
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

  Widget _buildCustomAppBar() {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 10,
        right: 16,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF2E3E32)),
            onPressed: () => Get.back(),
          ),
          const Text(
            'Session 1',
            style: TextStyle(
              color: Color(0xFF2E3E32),
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoStage() {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  color: Colors.black,
                  child: _buildVideoContent(),
                ),
              ),
            ),
            if (!_isLoadingVideo &&
                _videoError.isEmpty &&
                !_isPlaying &&
                !_videoEnded)
              Positioned.fill(
                child: Center(
                  child: _RoundControlButton(
                    icon: Icons.play_arrow_rounded,
                    size: 80,
                    iconSize: 46,
                    onTap: _handlePlayPause,
                  ),
                ),
              ),
          ],
        ),
        if (!_isLoadingVideo && _videoError.isEmpty) ...[
          const SizedBox(height: 12),
          _buildControlsPanel(),
        ],
      ],
    );
  }

  Widget _buildVideoContent() {
    if (_isLoadingVideo) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.mainAppColor),
            SizedBox(height: 14),
            Text(
              'Loading session video...',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    if (_videoError.isNotEmpty) {
      return Container(
        color: const Color(0xFFFFF1F2),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(24),
        child: Text(
          _videoError,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFFB42318),
            fontSize: 15,
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
        ),
      );
    }

    final controller = _videoPlayerController;
    if (controller == null || !controller.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.mainAppColor),
      );
    }

    return Center(
      child: AspectRatio(
        aspectRatio: controller.value.aspectRatio == 0
            ? 16 / 9
            : controller.value.aspectRatio,
        child: VideoPlayer(controller),
      ),
    );
  }

  Widget _buildControlsPanel() {
    final remainingTime = _duration - _currentTime;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.72),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _PillButton(
                icon: _isPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                label: _isPlaying ? 'Pause' : 'Play',
                onPressed: _handlePlayPause,
              ),
              _PillButton(
                icon: Icons.stop_rounded,
                label: 'Stop',
                onPressed: _handleStop,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  '${_formatTime(_currentTime)} / ${_formatTime(_duration)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Remaining ${_formatTime(remainingTime.isNegative ? Duration.zero : remainingTime)}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.82),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReflectionCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.16),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Session Reflection',
            style: TextStyle(
              color: Color(0xFF1F2933),
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          Column(children: _questions.map(_buildQuestionBlock).toList()),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _goToNextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A7C59),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Next Step',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionBlock(_ReflectionQuestion question) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${question.id}. ${question.question}',
            style: const TextStyle(
              color: Color(0xFF1F2933),
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          ...question.options.asMap().entries.map((entry) {
            final key = '${question.id}-${entry.key}';
            return InkWell(
              onTap: () => _handleCheck(question.id, entry.key),
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: Checkbox(
                        value: _checkedItems[key] ?? false,
                        activeColor: const Color(0xFF4A7C59),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        onChanged: (_) => _handleCheck(question.id, entry.key),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: const TextStyle(
                          color: Color(0xFF4B5563),
                          fontSize: 13,
                          height: 1.35,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  static String _categoryName(Map<dynamic, dynamic> item) {
    final category = item['categoryId'];
    if (category is Map) {
      return category['categoryName']?.toString().trim() ?? '';
    }
    return '';
  }

  static String _formatTime(Duration duration) {
    if (duration.isNegative) return '00:00';

    final totalSeconds = duration.inSeconds;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  static String _cleanError(Object error) {
    final message = error.toString();
    return message.startsWith('Exception: ')
        ? message.substring('Exception: '.length)
        : message;
  }
}

class _ReflectionQuestion {
  final int id;
  final String question;
  final List<String> options;

  const _ReflectionQuestion({
    required this.id,
    required this.question,
    required this.options,
  });
}

class _RoundControlButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final double iconSize;
  final VoidCallback onTap;

  const _RoundControlButton({
    required this.icon,
    required this.size,
    required this.iconSize,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Ink(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: const Color(0xFF0F766E).withOpacity(0.86),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.22),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: iconSize),
        ),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _PillButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.white.withOpacity(0.14),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
      ),
    );
  }
}
