import 'dart:async';
import 'dart:ui';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';

const String _audioCompleteKey = 'thoughts-counting-audio-complete:guest';
const String _thankingVideosKey = 'thoughts-thanking-mind-watched-videos:guest';
const String _mindfulnessVideosKey =
    'thoughts-mindfulness-watched-videos:guest';

const List<_ThoughtsVideo> _thankingMindVideos = [
  _ThoughtsVideo(
    id: 'monster',
    title: 'Monster',
    url:
        'https://res.cloudinary.com/dbglkfj2z/video/upload/v1776791734/my-emdr/media/media_69c70af6f992b944bccd41a9_1776791676326.mov',
  ),
  _ThoughtsVideo(
    id: 'pop-up-ads',
    title: 'Pop Up Ads',
    url:
        'https://res.cloudinary.com/dbglkfj2z/video/upload/v1776791935/my-emdr/media/media_69c70af6f992b944bccd41a9_1776791915398.mp4',
  ),
  _ThoughtsVideo(
    id: 'riptide',
    title: 'Riptide',
    url:
        'https://res.cloudinary.com/dbglkfj2z/video/upload/v1776792355/my-emdr/media/media_69c70af6f992b944bccd41a9_1776792303312.mov',
  ),
  _ThoughtsVideo(
    id: 'gps-mind',
    title: 'The GPS Mind - Try This!',
    url:
        'https://res.cloudinary.com/dbglkfj2z/video/upload/v1776792471/my-emdr/media/media_69c70af6f992b944bccd41a9_1776792426860.mov',
  ),
  _ThoughtsVideo(
    id: 'museum-security-guard',
    title: 'The Museum Security Guard',
    url:
        'https://res.cloudinary.com/dbglkfj2z/video/upload/v1776792563/my-emdr/media/media_69c70af6f992b944bccd41a9_1776792509804.mov',
  ),
];

const List<_ThoughtsVideo> _mindfulnessVideos = [
  _ThoughtsVideo(
    id: 'brain',
    title: 'Brain',
    url:
        'https://res.cloudinary.com/dbglkfj2z/video/upload/v1776801087/my-emdr/media/media_69c70af6f992b944bccd41a9_1776801065133.mp4',
  ),
  _ThoughtsVideo(
    id: 'brain-down',
    title: 'Brain Down',
    url:
        'https://res.cloudinary.com/dbglkfj2z/video/upload/v1776801133/my-emdr/media/media_69c70af6f992b944bccd41a9_1776801117511.mp4',
  ),
];

class CalmExercise extends StatefulWidget {
  const CalmExercise({super.key});

  @override
  State<CalmExercise> createState() => _CalmExerciseState();
}

class _CalmExerciseState extends State<CalmExercise> {
  final GetStorage _box = GetStorage();
  final AudioPlayer _audioPlayer = AudioPlayer();
  StreamSubscription<PlayerState>? _playerStateSubscription;

  bool _isCountingAudioComplete = false;
  bool _isAudioPlaying = false;
  bool _isCountingAudioLoaded = false;
  List<String> _watchedThankingVideos = [];
  List<String> _watchedMindfulnessVideos = [];

  @override
  void initState() {
    super.initState();
    _loadProgress();
    _playerStateSubscription = _audioPlayer.playerStateStream.listen((state) {
      if (!mounted) return;
      setState(() => _isAudioPlaying = state.playing);
      if (state.processingState == ProcessingState.completed) {
        _markCountingAudioComplete();
      }
    });
  }

  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _loadProgress() {
    _isCountingAudioComplete = _box.read<bool>(_audioCompleteKey) ?? false;
    _watchedThankingVideos = (_box.read<List>(_thankingVideosKey) ?? [])
        .cast<String>();
    _watchedMindfulnessVideos = (_box.read<List>(_mindfulnessVideosKey) ?? [])
        .cast<String>();
  }

  Future<void> _markCountingAudioComplete() async {
    await _box.write(_audioCompleteKey, true);
    if (!mounted) return;
    setState(() {
      _isCountingAudioComplete = true;
      _isAudioPlaying = false;
    });
  }

  Future<void> _toggleCountingAudio() async {
    if (_isAudioPlaying) {
      await _audioPlayer.pause();
      return;
    }

    if (!_isCountingAudioLoaded) {
      await _audioPlayer.setAsset('assets/audio/calm place.wav');
      _isCountingAudioLoaded = true;
    }

    await _audioPlayer.play();
  }

  Future<void> _openVideoLibrary({
    required String title,
    required List<_ThoughtsVideo> videos,
    required List<String> watchedIds,
    required Future<void> Function(List<String>) onProgressChanged,
  }) async {
    final result = await showDialog<List<String>>(
      context: context,
      barrierColor: const Color(0xFF0F1912).withOpacity(0.55),
      builder: (_) => _ThoughtsVideoModal(
        title: title,
        videos: videos,
        initialWatchedIds: watchedIds,
      ),
    );

    if (result == null) return;
    await onProgressChanged(result);
  }

  Future<void> _saveThankingProgress(List<String> watchedIds) async {
    await _box.write(_thankingVideosKey, watchedIds);
    if (!mounted) return;
    setState(() => _watchedThankingVideos = watchedIds);
  }

  Future<void> _saveMindfulnessProgress(List<String> watchedIds) async {
    await _box.write(_mindfulnessVideosKey, watchedIds);
    if (!mounted) return;
    setState(() => _watchedMindfulnessVideos = watchedIds);
  }

  @override
  Widget build(BuildContext context) {
    final isThankingUnlocked = _isCountingAudioComplete;
    final isThankingComplete =
        _watchedThankingVideos.length == _thankingMindVideos.length;
    final isMindfulnessUnlocked = isThankingComplete;
    final isMindfulnessComplete =
        _watchedMindfulnessVideos.length == _mindfulnessVideos.length;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 180,
            child: Image.asset('assets/images/my_emdr.png', fit: BoxFit.fill),
          ),
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.only(top: 100),
              decoration: const BoxDecoration(
                color: Colors.white,
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
            child: Container(
              margin: const EdgeInsets.only(top: 150),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(35),
                  topRight: Radius.circular(35),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAppBar(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF8F0).withOpacity(0.55),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.25),
                            ),
                          ),
                          child: Column(
                            children: [
                              _buildIntroCard(),
                              const SizedBox(height: 16),
                              _buildThoughtsItem(
                                number: '2',
                                tag: _isCountingAudioComplete
                                    ? 'Completed'
                                    : 'Audio',
                                title: 'Counting Thoughts',
                                description:
                                    'A guided practice in observing and counting your thoughts.',
                                state: _isCountingAudioComplete
                                    ? _ThoughtsState.completed
                                    : _ThoughtsState.active,
                                trailingIcon: _isAudioPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                footer: _isAudioPlaying
                                    ? 'Now playing...'
                                    : _isCountingAudioComplete
                                    ? 'Completed. The next step is now unlocked.'
                                    : null,
                                onTap: _toggleCountingAudio,
                              ),
                              _buildThoughtsItem(
                                number: '3',
                                tag: isThankingComplete
                                    ? 'Completed'
                                    : isThankingUnlocked
                                    ? 'Video Series'
                                    : 'Coming Soon',
                                title: 'Thanking the Mind',
                                description:
                                    'Practice acknowledging thoughts without getting caught up in them.',
                                state: isThankingComplete
                                    ? _ThoughtsState.completed
                                    : isThankingUnlocked
                                    ? _ThoughtsState.active
                                    : _ThoughtsState.locked,
                                trailingIcon: isThankingComplete
                                    ? Icons.lock_open_rounded
                                    : isThankingUnlocked
                                    ? Icons.videocam_rounded
                                    : Icons.lock_rounded,
                                footer: isThankingUnlocked
                                    ? isThankingComplete
                                          ? 'Completed. The next step is now unlocked.'
                                          : '${_watchedThankingVideos.length}/${_thankingMindVideos.length} videos watched'
                                    : null,
                                onTap: isThankingUnlocked
                                    ? () => _openVideoLibrary(
                                        title: 'Thanking the Mind',
                                        videos: _thankingMindVideos,
                                        watchedIds: _watchedThankingVideos,
                                        onProgressChanged:
                                            _saveThankingProgress,
                                      )
                                    : _showLockedDialog,
                              ),
                              _buildThoughtsItem(
                                number: '4',
                                tag: isMindfulnessComplete
                                    ? 'Completed'
                                    : isMindfulnessUnlocked
                                    ? 'Video Series'
                                    : 'Coming Soon',
                                title: 'Mindfulness',
                                description:
                                    'A mindfulness meditation to cultivate present-moment awareness.',
                                state: isMindfulnessComplete
                                    ? _ThoughtsState.completed
                                    : isMindfulnessUnlocked
                                    ? _ThoughtsState.active
                                    : _ThoughtsState.locked,
                                trailingIcon: isMindfulnessComplete
                                    ? Icons.lock_open_rounded
                                    : isMindfulnessUnlocked
                                    ? Icons.videocam_rounded
                                    : Icons.lock_rounded,
                                footer: isMindfulnessUnlocked
                                    ? isMindfulnessComplete
                                          ? 'Completed.'
                                          : '${_watchedMindfulnessVideos.length}/${_mindfulnessVideos.length} videos watched'
                                    : null,
                                onTap: isMindfulnessUnlocked
                                    ? () => _openVideoLibrary(
                                        title: 'Mindfulness',
                                        videos: _mindfulnessVideos,
                                        watchedIds: _watchedMindfulnessVideos,
                                        onProgressChanged:
                                            _saveMindfulnessProgress,
                                      )
                                    : _showLockedDialog,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF4A4A4A)),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            'Thoughts',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Color(0xFF4A4A4A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7FF).withOpacity(0.92),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.65)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.psychology_alt_outlined,
              color: Color(0xFF4A90E2),
              size: 30,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Observing Your Mind',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Our thoughts can feel very real and powerful, but learning to observe them with some distance can be transformative. These exercises are designed to help you develop a new relationship with your thoughts.',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF3B82F6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThoughtsItem({
    required String number,
    required String tag,
    required String title,
    required String description,
    required _ThoughtsState state,
    required IconData trailingIcon,
    String? footer,
    VoidCallback? onTap,
  }) {
    final locked = state == _ThoughtsState.locked;

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.82),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: locked
                  ? Colors.white.withOpacity(0.55)
                  : const Color(0xFFD8E9DD),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 23,
                backgroundColor: const Color(0xFFF3F4F6),
                child: Text(
                  number,
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTag(tag),
                    const SizedBox(height: 10),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: locked
                            ? const Color(0xFF9CA3AF)
                            : const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.4,
                        color: locked
                            ? const Color(0xFF9CA3AF)
                            : const Color(0xFF4B5563),
                      ),
                    ),
                    if (footer != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        footer,
                        style: const TextStyle(
                          color: Color(0xFF4A7C59),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                trailingIcon,
                size: 30,
                color: locked
                    ? const Color(0xFF9CA3AF)
                    : const Color(0xFF4A7C59),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String tag) {
    final isActive = tag == 'Audio' || tag == 'Video Series';
    final isCompleted = tag == 'Completed';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFFD1FAE5)
            : isCompleted
            ? const Color(0xFFE0F2FE)
            : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (tag == 'Audio') const Icon(Icons.music_note, size: 14),
          if (tag == 'Video Series') const Icon(Icons.videocam, size: 14),
          if (tag == 'Completed') const Icon(Icons.lock_open, size: 14),
          if (tag == 'Audio' || tag == 'Video Series' || tag == 'Completed')
            const SizedBox(width: 5),
          Text(
            tag,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: isActive
                  ? const Color(0xFF065F46)
                  : isCompleted
                  ? const Color(0xFF0C4A6E)
                  : const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }

  void _showLockedDialog() {
    showDialog(
      context: context,
      builder: (_) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: Colors.white.withOpacity(0.95),
          contentPadding: const EdgeInsets.fromLTRB(28, 28, 28, 20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF7CF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  size: 36,
                  color: Color(0xFFAD8C63),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Content Locked',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E3E32),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Complete the previous exercise first to unlock this content.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A7C5F),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  child: const Text(
                    'Got it',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThoughtsVideoModal extends StatefulWidget {
  const _ThoughtsVideoModal({
    required this.title,
    required this.videos,
    required this.initialWatchedIds,
  });

  final String title;
  final List<_ThoughtsVideo> videos;
  final List<String> initialWatchedIds;

  @override
  State<_ThoughtsVideoModal> createState() => _ThoughtsVideoModalState();
}

class _ThoughtsVideoModalState extends State<_ThoughtsVideoModal> {
  late List<String> _watchedIds;
  late _ThoughtsVideo _selectedVideo;
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _watchedIds = List<String>.from(widget.initialWatchedIds);
    _selectedVideo = _firstOpenVideo();
    _loadSelectedVideo();
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  _ThoughtsVideo _firstOpenVideo() {
    for (final video in widget.videos) {
      if (_videoState(video.id) == _ThoughtsState.active) return video;
    }
    return widget.videos.first;
  }

  _ThoughtsState _videoState(String videoId) {
    final index = widget.videos.indexWhere((video) => video.id == videoId);
    if (index == -1) return _ThoughtsState.locked;
    if (_watchedIds.contains(videoId)) return _ThoughtsState.completed;
    if (index == 0) return _ThoughtsState.active;
    return _watchedIds.contains(widget.videos[index - 1].id)
        ? _ThoughtsState.active
        : _ThoughtsState.locked;
  }

  Future<void> _loadSelectedVideo() async {
    setState(() => _isLoading = true);
    _chewieController?.dispose();
    _videoController?.dispose();

    final controller = VideoPlayerController.networkUrl(
      Uri.parse(_selectedVideo.url),
    );
    await controller.initialize();
    controller.addListener(_handleVideoProgress);

    if (!mounted) {
      controller.dispose();
      return;
    }

    setState(() {
      _videoController = controller;
      _chewieController = ChewieController(
        videoPlayerController: controller,
        autoPlay: false,
        aspectRatio: controller.value.aspectRatio,
        materialProgressColors: ChewieProgressColors(
          playedColor: const Color(0xFF4A7C59),
          handleColor: const Color(0xFF4A7C59),
        ),
      );
      _isLoading = false;
    });
  }

  void _handleVideoProgress() {
    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) return;

    final position = controller.value.position;
    final duration = controller.value.duration;
    if (duration == Duration.zero) return;

    if (position >= duration - const Duration(milliseconds: 500)) {
      _markSelectedVideoWatched();
    }
  }

  void _markSelectedVideoWatched() {
    if (_watchedIds.contains(_selectedVideo.id)) return;

    final nextWatchedIds = [..._watchedIds, _selectedVideo.id];
    setState(() => _watchedIds = nextWatchedIds);

    final currentIndex = widget.videos.indexWhere(
      (video) => video.id == _selectedVideo.id,
    );
    if (currentIndex >= 0 && currentIndex < widget.videos.length - 1) {
      _selectedVideo = widget.videos[currentIndex + 1];
      _loadSelectedVideo();
    }
  }

  void _selectVideo(_ThoughtsVideo video) {
    if (_videoState(video.id) == _ThoughtsState.locked) return;
    if (_selectedVideo.id == video.id) return;

    setState(() => _selectedVideo = video);
    _loadSelectedVideo();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final dialogWidth = screenSize.width > 900 ? 860.0 : screenSize.width - 32;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      backgroundColor: Colors.transparent,
      child: Container(
        width: dialogWidth,
        constraints: BoxConstraints(maxHeight: screenSize.height * 0.88),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F5EE).withOpacity(0.97),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withOpacity(0.25)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F1912).withOpacity(0.2),
              blurRadius: 60,
              offset: const Offset(0, 24),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title.toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF4A7C59),
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.6,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Video Practice Library',
                          style: TextStyle(
                            color: Color(0xFF1F2937),
                            fontSize: 25,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Watch each video in order. Finishing one unlocks the next.',
                          style: TextStyle(
                            color: Color(0xFF5F6B63),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context, _watchedIds),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF4A7C59),
                    ),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDF5EF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Progress ${_watchedIds.length}/${widget.videos.length} videos completed',
                  style: const TextStyle(
                    color: Color(0xFF355743),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ...widget.videos.map(_buildVideoButton),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoButton(_ThoughtsVideo video) {
    final index = widget.videos.indexOf(video);
    final state = _videoState(video.id);
    final locked = state == _ThoughtsState.locked;
    final watched = state == _ThoughtsState.completed;
    final selected = _selectedVideo.id == video.id;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: locked ? null : () => _selectVideo(video),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: locked
                ? Colors.white.withOpacity(0.45)
                : selected
                ? Colors.white
                : Colors.white.withOpacity(0.72),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected
                  ? const Color(0xFF4A7C59)
                  : Colors.white.withOpacity(0.7),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Video ${index + 1}',
                      style: const TextStyle(
                        color: Color(0xFF7B8B80),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  _videoStatusBadge(
                    locked
                        ? 'Locked'
                        : watched
                        ? 'Watched'
                        : 'Open',
                    locked: locked,
                    watched: watched,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                video.title,
                style: const TextStyle(
                  color: Color(0xFF1F2937),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (selected) ...[
                const SizedBox(height: 14),
                _buildInlineVideoPlayer(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInlineVideoPlayer() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F5EE).withOpacity(0.9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.65)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: _isLoading || _chewieController == null
                  ? const ColoredBox(
                      color: Color(0xFFDCE7DF),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF4A7C59),
                        ),
                      ),
                    )
                  : Chewie(controller: _chewieController!),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Watch the full video to mark it complete. The next video unlocks after this one finishes.',
            style: TextStyle(
              color: Color(0xFF5F6B63),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _videoStatusBadge(
    String label, {
    required bool locked,
    required bool watched,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: watched ? const Color(0xFFD1FAE5) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: locked
              ? const Color(0xFF9CA3AF)
              : watched
              ? const Color(0xFF065F46)
              : const Color(0xFF7C7C7C),
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ThoughtsVideo {
  const _ThoughtsVideo({
    required this.id,
    required this.title,
    required this.url,
  });

  final String id;
  final String title;
  final String url;
}

enum _ThoughtsState { active, locked, completed }
