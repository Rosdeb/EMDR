import 'dart:async';
import 'dart:ui';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:video_player/video_player.dart';

const String _countingThoughtsCompleteKey =
    'thoughts-counting-audio-complete:guest';
const String _thankingVideosKey = 'thoughts-thanking-mind-watched-videos:guest';
const String _mindfulnessVideosKey =
    'thoughts-mindfulness-watched-videos:guest';
const String _dailyThoughtHistoryKey = 'daily-thought-history';

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

  bool _isCountingThoughtsComplete = false;
  _DailyThoughtEntry? _todayThoughtEntry;
  List<String> _watchedThankingVideos = [];
  List<String> _watchedMindfulnessVideos = [];

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  void _loadProgress() {
    _isCountingThoughtsComplete =
        _box.read<bool>(_countingThoughtsCompleteKey) ?? false;
    _todayThoughtEntry = _readTodayThoughtEntry();
    _watchedThankingVideos = (_box.read<List>(_thankingVideosKey) ?? [])
        .cast<String>();
    _watchedMindfulnessVideos = (_box.read<List>(_mindfulnessVideosKey) ?? [])
        .cast<String>();
  }

  _DailyThoughtEntry? _readTodayThoughtEntry() {
    final todayKey = _dateKey(DateTime.now());
    for (final entry in _readThoughtHistory()) {
      if (entry.date == todayKey) return entry;
    }
    return null;
  }

  List<_DailyThoughtEntry> _readThoughtHistory() {
    final rawHistory = _box.read<List>(_dailyThoughtHistoryKey) ?? [];
    return rawHistory
        .whereType<Map>()
        .map((item) => _DailyThoughtEntry.fromStorage(item))
        .whereType<_DailyThoughtEntry>()
        .toList();
  }

  Future<void> _openThoughtCheckIn() async {
    final result = await showModalBottomSheet<_DailyThoughtEntry>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0xFF0F1912).withValues(alpha: 0.55),
      builder: (_) => _DailyThoughtCheckInSheet(
        initialHistory: _readThoughtHistory(),
        onHistoryChanged: (history) async {
          await _box.write(
            _dailyThoughtHistoryKey,
            history.map((entry) => entry.toStorage()).toList(),
          );
          if (!_isCountingThoughtsComplete) {
            await _box.write(_countingThoughtsCompleteKey, true);
          }
          if (!mounted) return;
          setState(() {
            _todayThoughtEntry = _readTodayThoughtEntry();
            _isCountingThoughtsComplete = true;
          });
        },
      ),
    );

    if (result == null || !mounted) return;
    setState(() {
      _todayThoughtEntry = result;
      _isCountingThoughtsComplete = true;
    });
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

  Future<void> _openMindfulnessIntro() async {
    final completed = await showDialog<bool>(
      context: context,
      barrierColor: const Color(0xFF0F1912).withValues(alpha: 0.55),
      builder: (_) => _MindfulnessIntroModal(videos: _mindfulnessVideos),
    );

    if (completed != true) return;
    await _saveMindfulnessProgress(
      _mindfulnessVideos.map((video) => video.id).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isThankingUnlocked = _isCountingThoughtsComplete;
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
                                tag: _isCountingThoughtsComplete
                                    ? 'Completed'
                                    : 'Counter',
                                title: 'Counting Thoughts',
                                description:
                                    'Track critical and negative self-talk as moments of awareness.',
                                state: _isCountingThoughtsComplete
                                    ? _ThoughtsState.completed
                                    : _ThoughtsState.active,
                                trailingIcon: _isCountingThoughtsComplete
                                    ? Icons.check_circle_rounded
                                    : Icons.calendar_today_rounded,
                                footer: _isCountingThoughtsComplete
                                    ? 'Completed. ${_todayThoughtEntry?.count ?? 0} thoughts recorded today.'
                                    : 'Record your daily count and reflection.',
                                onTap: _openThoughtCheckIn,
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
                                          : 'Read the intro and watch the mindfulness videos.'
                                    : null,
                                onTap: isMindfulnessUnlocked
                                    ? _openMindfulnessIntro
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
    final isActive = tag == 'Counter' || tag == 'Video Series';
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
          if (tag == 'Counter') const Icon(Icons.calendar_today, size: 14),
          if (tag == 'Video Series') const Icon(Icons.videocam, size: 14),
          if (tag == 'Completed') const Icon(Icons.lock_open, size: 14),
          if (tag == 'Counter' || tag == 'Video Series' || tag == 'Completed')
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

class _DailyThoughtCheckInSheet extends StatefulWidget {
  const _DailyThoughtCheckInSheet({
    required this.initialHistory,
    required this.onHistoryChanged,
  });

  final List<_DailyThoughtEntry> initialHistory;
  final Future<void> Function(List<_DailyThoughtEntry> history)
  onHistoryChanged;

  @override
  State<_DailyThoughtCheckInSheet> createState() =>
      _DailyThoughtCheckInSheetState();
}

class _DailyThoughtCheckInSheetState extends State<_DailyThoughtCheckInSheet> {
  final TextEditingController _countController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  late List<_DailyThoughtEntry> _history;
  _DailyThoughtEntry? _savedEntry;
  bool _saved = false;

  String get _today => _dateKey(DateTime.now());

  @override
  void initState() {
    super.initState();
    _history = List<_DailyThoughtEntry>.from(widget.initialHistory);
    _DailyThoughtEntry? todayEntry;
    for (final entry in _history) {
      if (entry.date == _today) {
        todayEntry = entry;
        break;
      }
    }
    if (todayEntry != null) {
      _countController.text = todayEntry.count.toString();
      _noteController.text = todayEntry.note;
      _savedEntry = todayEntry;
      _saved = true;
    }
  }

  @override
  void dispose() {
    _countController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveEntry() async {
    final count = int.tryParse(_countController.text.trim());
    if (count == null || count < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid count (0 or more)')),
      );
      return;
    }

    final entry = _DailyThoughtEntry(
      date: _today,
      count: count,
      note: _noteController.text.trim(),
      timestamp: DateTime.now(),
    );
    final updatedHistory = [
      entry,
      ..._history.where((item) => item.date != _today),
    ].take(90).toList();

    setState(() {
      _history = updatedHistory;
      _savedEntry = entry;
      _saved = true;
    });

    await widget.onHistoryChanged(updatedHistory);

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() => _saved = false);
    });
  }

  int _averageFor(int days) {
    final entries = _history.take(days).toList();
    if (entries.isEmpty) return 0;
    final total = entries.fold<int>(0, (sum, entry) => sum + entry.count);
    return (total / entries.length).round();
  }

  _ThoughtTrend? _trend() {
    if (_history.length < 7) return null;
    final recent = _history.take(7).toList();
    final previous = _history.skip(7).take(7).toList();
    if (previous.isEmpty) return null;

    final recentAvg =
        recent.fold<int>(0, (sum, entry) => sum + entry.count) / recent.length;
    final previousAvg =
        previous.fold<int>(0, (sum, entry) => sum + entry.count) /
        previous.length;
    if (previousAvg == 0) return null;

    final change = ((recentAvg - previousAvg) / previousAvg) * 100;
    return _ThoughtTrend(change: change, improving: change < 0);
  }

  @override
  Widget build(BuildContext context) {
    final trend = _trend();

    return DraggableScrollableSheet(
      initialChildSize: 0.94,
      minChildSize: 0.64,
      maxChildSize: 0.96,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFFF7FC),
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context),
                const SizedBox(height: 18),
                _buildTodayEntry(),
                if (_history.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildStats(trend),
                  const SizedBox(height: 16),
                  _buildHistory(),
                ],
                const SizedBox(height: 18),
                const Text(
                  'Check in at the end of each day to track patterns over time.\nLower numbers generally indicate better thought management.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 46,
          height: 5,
          decoration: BoxDecoration(
            color: const Color(0xFFD1D5DB),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(height: 18),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Check-In',
                    style: TextStyle(
                      color: Color(0xFF1F2937),
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Record your negative thought count.',
                    style: TextStyle(
                      color: Color(0xFF5F6B7A),
                      fontSize: 14,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => Navigator.pop(context, _savedEntry),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFFA855F7),
              ),
              icon: const Icon(Icons.close_rounded),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTodayEntry() {
    return _GlowCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                color: Color(0xFFA855F7),
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _friendlyLongDate(DateTime.now()),
                  style: const TextStyle(
                    color: Color(0xFF1F2937),
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const Text(
            'How many negative thoughts did you notice today?',
            style: TextStyle(
              color: Color(0xFF374151),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _countController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF1F2937),
              fontSize: 42,
              fontWeight: FontWeight.w300,
            ),
            decoration: _inputDecoration('0'),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 18),
          const Text(
            'Reflection (optional)',
            style: TextStyle(
              color: Color(0xFF374151),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _noteController,
            minLines: 4,
            maxLines: 5,
            textInputAction: TextInputAction.newline,
            decoration: _inputDecoration(
              'What patterns did you notice? What triggered the thoughts? What helped you manage them?',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Consider: common triggers, times of day, situations, physical state, helpful coping strategies',
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 12,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _countController.text.trim().isEmpty
                      ? const [Color(0xFFD1D5DB), Color(0xFF9CA3AF)]
                      : const [Color(0xFFA855F7), Color(0xFFEC4899)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ElevatedButton.icon(
                onPressed: _countController.text.trim().isEmpty
                    ? null
                    : _saveEntry,
                icon: const Icon(Icons.save_rounded, size: 20),
                label: const Text('Save Check-In'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  disabledBackgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  disabledForegroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
          if (_saved) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFA7F3D0)),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF059669),
                    size: 24,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Check-in saved!',
                          style: TextStyle(
                            color: Color(0xFF065F46),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Your entry has been recorded',
                          style: TextStyle(
                            color: Color(0xFF047857),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.all(16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFC084FC), width: 2),
      ),
    );
  }

  Widget _buildStats(_ThoughtTrend? trend) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 640;
        final cards = [
          _buildStatCard(
            icon: Icons.bar_chart_rounded,
            iconColor: const Color(0xFF3B82F6),
            value: _averageFor(7).toString(),
            label: '7-day average',
          ),
          _buildStatCard(
            icon: Icons.bar_chart_rounded,
            iconColor: const Color(0xFFA855F7),
            value: _averageFor(30).toString(),
            label: '30-day average',
          ),
          if (trend != null)
            _buildStatCard(
              icon: trend.improving
                  ? Icons.trending_down_rounded
                  : Icons.trending_up_rounded,
              iconColor: trend.improving
                  ? const Color(0xFF22C55E)
                  : const Color(0xFFF97316),
              value: '${trend.change.abs().round()}%',
              label: trend.improving
                  ? 'Improvement vs last week'
                  : 'Increase vs last week',
              valueColor: trend.improving
                  ? const Color(0xFF16A34A)
                  : const Color(0xFFEA580C),
            ),
        ];

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: cards
              .map(
                (card) => SizedBox(
                  width: compact
                      ? double.infinity
                      : (constraints.maxWidth - 24) / 3,
                  child: card,
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
    Color valueColor = const Color(0xFF1F2937),
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.75)),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 30),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 30,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildHistory() {
    final weekAverage = _averageFor(7);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withValues(alpha: 0.75)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                color: Color(0xFFA855F7),
                size: 26,
              ),
              SizedBox(width: 10),
              Text(
                'History',
                style: TextStyle(
                  color: Color(0xFF1F2937),
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ..._history.map((entry) {
            final isToday = entry.date == _today;
            final belowAverage = weekAverage > 0 && entry.count < weekAverage;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF3E8FF), width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.count.toString(),
                        style: const TextStyle(
                          color: Color(0xFF1F2937),
                          fontSize: 30,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _friendlyShortDate(entry.parsedDate),
                              style: const TextStyle(
                                color: Color(0xFF374151),
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            if (isToday)
                              const Text(
                                'Today',
                                style: TextStyle(
                                  color: Color(0xFFA855F7),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (belowAverage)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            'Below average',
                            style: TextStyle(
                              color: Color(0xFF16A34A),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (entry.note.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(left: 10),
                      decoration: const BoxDecoration(
                        border: Border(
                          left: BorderSide(color: Color(0xFFE9D5FF), width: 2),
                        ),
                      ),
                      child: Text(
                        entry.note,
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 13,
                          height: 1.4,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _MindfulnessIntroModal extends StatelessWidget {
  const _MindfulnessIntroModal({required this.videos});

  final List<_ThoughtsVideo> videos;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final dialogWidth = screenSize.width > 920 ? 880.0 : screenSize.width - 28;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 22),
      backgroundColor: Colors.transparent,
      child: Container(
        width: dialogWidth,
        constraints: BoxConstraints(maxHeight: screenSize.height * 0.9),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFF7EA), Color(0xFFFFEFF6), Color(0xFFEAF7FB)],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 50,
              offset: const Offset(0, 22),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        child: Text(
                          'Before We Begin: Understanding Mindfulness',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF5A7BA6),
                            fontSize: 28,
                            fontWeight: FontWeight.w300,
                            height: 1.18,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF5A7BA6),
                        ),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const _MindfulnessImagePanel(
                    assetPath: 'assets/images/brain-thoughts-1.jpg',
                    title: 'Thoughts flowing through the mind',
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    "Mindfulness is a straightforward mental training practice backed by neuroscience research. There's nothing mystical about it - it's simply about learning to pay attention in a specific way.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF5A6A7A),
                      fontSize: 16,
                      height: 1.55,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (videos.isNotEmpty)
                    _MindfulnessInlineVideo(video: videos[0]),
                  const SizedBox(height: 24),
                  const _MindfulnessSectionTitle('The Basic Approach'),
                  const SizedBox(height: 10),
                  const _MindfulnessSteps(),
                  const SizedBox(height: 24),
                  const _MindfulnessSectionTitle('Why This Matters'),
                  const SizedBox(height: 10),
                  const _MindfulnessParagraph(
                    "The practice isn't about achieving a blank mind or perfect concentration. Instead, each moment you catch yourself thinking and return to the breath strengthens your capacity for present-moment awareness. Research shows this literally reshapes neural pathways.",
                  ),
                  const SizedBox(height: 18),
                  const _MindfulnessImagePanel(
                    assetPath: 'assets/images/brain-thoughts-2.jpg',
                    title: 'Mind full of thoughts',
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFDEEF4), Color(0xFFFEF5E7)],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: const Border(
                        left: BorderSide(color: Color(0xFFD4A5A5), width: 4),
                      ),
                    ),
                    child: const _MindfulnessParagraph(
                      'Rather than being swept away by thoughts - unable to see past the mental noise - mindfulness teaches you to take a step back and observe them as passing events. With practice, you begin to notice your own patterns: the familiar loops of worry, the recurring narratives, the habitual mental tracks you find yourself stuck in. This observer perspective is transformative.',
                      emphasized: true,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (videos.length > 1)
                    _MindfulnessInlineVideo(video: videos[1]),
                  const SizedBox(height: 22),
                  const _MindfulnessParagraph(
                    'For EMDR work, this skill is invaluable. Developing the ability to anchor yourself in the present while observing your internal experience creates a stable base from which to safely explore and process challenging material. Regular practice - even just a few minutes daily - builds this foundational capacity.',
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context, true),
                    icon: const Icon(Icons.check_circle_rounded),
                    label: const Text('Complete Mindfulness'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5A7BA6),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MindfulnessInlineVideo extends StatefulWidget {
  const _MindfulnessInlineVideo({required this.video});

  final _ThoughtsVideo video;

  @override
  State<_MindfulnessInlineVideo> createState() =>
      _MindfulnessInlineVideoState();
}

class _MindfulnessInlineVideoState extends State<_MindfulnessInlineVideo> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVideo();
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _loadVideo() async {
    final controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.video.url),
    );
    await controller.initialize();

    if (!mounted) {
      controller.dispose();
      return;
    }

    setState(() {
      _videoController = controller;
      _chewieController = ChewieController(
        videoPlayerController: controller,
        autoPlay: false,
        looping: true,
        aspectRatio: controller.value.aspectRatio,
        materialProgressColors: ChewieProgressColors(
          playedColor: const Color(0xFF5A7BA6),
          handleColor: const Color(0xFF5A7BA6),
        ),
      );
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.video.title,
          style: const TextStyle(
            color: Color(0xFF5A7BA6),
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: _isLoading || _chewieController == null
                ? const ColoredBox(
                    color: Color(0xFFE8F4F8),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF5A7BA6),
                      ),
                    ),
                  )
                : Chewie(controller: _chewieController!),
          ),
        ),
      ],
    );
  }
}

class _MindfulnessSectionTitle extends StatelessWidget {
  const _MindfulnessSectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF6B8AB0),
        fontSize: 21,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _MindfulnessParagraph extends StatelessWidget {
  const _MindfulnessParagraph(this.text, {this.emphasized = false});

  final String text;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: emphasized ? const Color(0xFF5A7BA6) : const Color(0xFF4A5568),
        fontSize: 15,
        height: 1.65,
        fontWeight: emphasized ? FontWeight.w700 : FontWeight.w400,
      ),
    );
  }
}

class _MindfulnessSteps extends StatelessWidget {
  const _MindfulnessSteps();

  @override
  Widget build(BuildContext context) {
    const steps = [
      'Find a comfortable seated position and close your eyes',
      'Bring your awareness to your breathing - perhaps at your nostrils, chest, or abdomen, wherever the sensation feels clearest',
      'Your attention will inevitably drift to thoughts, plans, or memories. When you realize this has happened, guide your focus back to breathing',
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE8F4F8), Color(0xFFFEF5E7)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: const Border(
          left: BorderSide(color: Color(0xFF8AA8C4), width: 4),
        ),
      ),
      child: Column(
        children: [
          for (var index = 0; index < steps.length; index++)
            Padding(
              padding: EdgeInsets.only(
                bottom: index == steps.length - 1 ? 0 : 12,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 13,
                    backgroundColor: const Color(0xFF8AA8C4),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      steps[index],
                      style: const TextStyle(
                        color: Color(0xFF4A5568),
                        fontSize: 15,
                        height: 1.45,
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
}

class _MindfulnessImagePanel extends StatelessWidget {
  const _MindfulnessImagePanel({required this.assetPath, required this.title});

  final String assetPath;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 230,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(assetPath, fit: BoxFit.cover),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.42),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 14,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  shadows: [
                    Shadow(
                      color: Colors.black45,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
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

class _DailyThoughtEntry {
  const _DailyThoughtEntry({
    required this.date,
    required this.count,
    required this.note,
    required this.timestamp,
  });

  final String date;
  final int count;
  final String note;
  final DateTime timestamp;

  DateTime get parsedDate => DateTime.tryParse(date) ?? timestamp;

  static _DailyThoughtEntry? fromStorage(Map item) {
    final date = item['date']?.toString();
    final count = item['count'];
    if (date == null) return null;

    return _DailyThoughtEntry(
      date: date,
      count: count is int ? count : int.tryParse(count?.toString() ?? '') ?? 0,
      note: item['note']?.toString() ?? '',
      timestamp:
          DateTime.tryParse(item['timestamp']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toStorage() {
    return {
      'date': date,
      'count': count,
      'note': note,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class _ThoughtTrend {
  const _ThoughtTrend({required this.change, required this.improving});

  final double change;
  final bool improving;
}

class _GlowCard extends StatelessWidget {
  const _GlowCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withValues(alpha: 0.75)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEC4899).withValues(alpha: 0.11),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: const Color(0xFFA855F7).withValues(alpha: 0.09),
            blurRadius: 36,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: child,
    );
  }
}

String _dateKey(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

String _friendlyLongDate(DateTime date) {
  const weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}, ${date.year}';
}

String _friendlyShortDate(DateTime date) {
  const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}, ${date.year}';
}

enum _ThoughtsState { active, locked, completed }
