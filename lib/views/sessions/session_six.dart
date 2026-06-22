import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:jonssony/views/sessions/session_bilateral_simulation.dart';

class SessionSix extends StatefulWidget {
  const SessionSix({super.key});

  @override
  State<SessionSix> createState() => _SessionSixState();
}

class _SessionSixState extends State<SessionSix> {
  late final VideoPlayerController _controller;
  bool _initialized = false;
  bool _completed = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(
      'assets/video/Video3YourEMDRSession.mp4',
    )..initialize().then((_) {
        if (!mounted) return;
        setState(() => _initialized = true);
        _controller.play();
        _controller.addListener(_onVideoUpdate);
      }).catchError((_) {
        if (!mounted) return;
        setState(() => _hasError = true);
      });
  }

  void _onVideoUpdate() {
    if (!mounted) return;
    final c = _controller;
    if (!_completed && c.value.duration > Duration.zero &&
        c.value.position >= c.value.duration) {
      setState(() => _completed = true);
    } else {
      setState(() {});
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  void _continue() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const SessionBilateralSimulation(
          showSaveSettings: false,
          showBeginSession: true,
          backTitle: 'Session 6',
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_onVideoUpdate);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/home_bg1.jpg', fit: BoxFit.cover),
          Container(color: Colors.black.withValues(alpha: 0.45)),
          SafeArea(
            child: Column(
              children: [
                // Back button
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ),

                // Title

                const SizedBox(height: 6),
                const Text(
                  'Your EMDR Session',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w300,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 10),
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Text(
                  textAlign: TextAlign.center,
                  ' Please watch this guidance before choosing your bilateral stimulation settings.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w300,
                    fontStyle: FontStyle.italic,
                  ),
                ),
               ),

                const SizedBox(height: 20),

                // Video
                 Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: ColoredBox(
                        color: Colors.transparent,
                        child: _hasError
                            ? const Center(
                                child: Text('Video unavailable',
                                    style: TextStyle(color: Colors.white70)),
                              )
                            : _initialized
                                ? GestureDetector(
                                    onTap: () => setState(() {
                                      _controller.value.isPlaying
                                          ? _controller.pause()
                                          : _controller.play();
                                    }),
                                    child: Center(
                                      child: AspectRatio(
                                        aspectRatio:
                                            _controller.value.aspectRatio,
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            VideoPlayer(_controller),
                                            IgnorePointer(
                                              child: AnimatedOpacity(
                                                opacity: _controller.value.isPlaying
                                                    ? 0.0
                                                    : 1.0,
                                                duration: const Duration(
                                                    milliseconds: 250),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.black
                                                        .withValues(alpha: 0.55),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  padding:
                                                      const EdgeInsets.all(16),
                                                  child: const Icon(
                                                    Icons.play_arrow_rounded,
                                                    color: Colors.white,
                                                    size: 48,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              bottom: 0,
                                              left: 0,
                                              right: 0,
                                              child: IgnorePointer(
                                                ignoring: _controller.value.isPlaying,
                                                child: AnimatedOpacity(
                                                  opacity: _controller.value.isPlaying
                                                      ? 0.0
                                                      : 1.0,
                                                  duration: const Duration(
                                                      milliseconds: 250),
                                                  child: GestureDetector(
                                                    onTap: () {}, // Absorb taps to prevent pause toggle
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        gradient: LinearGradient(
                                                          begin: Alignment.bottomCenter,
                                                          end: Alignment.topCenter,
                                                          colors: [
                                                            Colors.black.withValues(alpha: 0.65),
                                                            Colors.transparent,
                                                          ],
                                                        ),
                                                      ),
                                                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            _formatDuration(_controller.value.position),
                                                            style: const TextStyle(
                                                              color: Colors.white,
                                                              fontSize: 12,
                                                              fontWeight: FontWeight.w500,
                                                            ),
                                                          ),
                                                          const SizedBox(width: 12),
                                                          Expanded(
                                                            child: VideoProgressIndicator(
                                                              _controller,
                                                              allowScrubbing: true,
                                                              colors: const VideoProgressColors(
                                                                playedColor: Color(0xFF7A9A6A),
                                                                bufferedColor: Colors.white24,
                                                                backgroundColor: Colors.white12,
                                                              ),
                                                              padding: const EdgeInsets.symmetric(vertical: 8),
                                                            ),
                                                          ),
                                                          const SizedBox(width: 12),
                                                          Text(
                                                            _formatDuration(_controller.value.duration),
                                                            style: const TextStyle(
                                                              color: Colors.white,
                                                              fontSize: 12,
                                                              fontWeight: FontWeight.w500,
                                                            ),
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
                                    ),
                                  )
                                : const Center(
                                    child: CircularProgressIndicator(
                                        color: Colors.white),
                                  ),
                      ),
                    ),
                  ),


                const Spacer(),

                // Bottom action
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _completed
                      ? SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _continue,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF7A9A6A),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text('Continue',
                                style: TextStyle(fontSize: 16)),
                          ),
                        )
                      : const Text(
                          'Finish the video to unlock the next step',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
