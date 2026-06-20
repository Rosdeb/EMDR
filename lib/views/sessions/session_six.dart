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
    if (!mounted || _completed) return;
    final c = _controller;
    if (c.value.duration > Duration.zero &&
        c.value.position >= c.value.duration) {
      setState(() => _completed = true);
    }
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
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
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
                                        child: VideoPlayer(_controller),
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
