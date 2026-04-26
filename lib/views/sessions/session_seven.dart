import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:just_audio/just_audio.dart';
import 'package:jonssony/utils/app_text.dart';
import 'package:jonssony/utils/app_colors.dart';
import 'package:jonssony/widets/custom_home_bg.dart';
import 'package:jonssony/views/profile/subcription/assignment.dart'; // For assessments

enum S7Phase { preAssessment, continuation, phase2, phase3, closing }

enum S7Phase2State { intro, bls, checkIn }
enum S7Phase3State { intro, bls }

class SessionSeven extends StatefulWidget {
  const SessionSeven({super.key});

  @override
  State<SessionSeven> createState() => _SessionSevenState();
}

class _SessionSevenState extends State<SessionSeven> with TickerProviderStateMixin {
  final box = GetStorage();
  final AudioPlayer _audioPlayer = AudioPlayer();

  S7Phase _currentPhase = S7Phase.preAssessment;
  S7Phase2State _p2State = S7Phase2State.intro;
  S7Phase3State _p3State = S7Phase3State.intro;

  // Data
  List<String> _positiveBeliefs = [];
  int _currentBeliefIndex = 0;
  int _vocScore = 1;
  bool _bodySensationsPresent = false;

  // BLS Animation
  late AnimationController _blsController;
  late Animation<double> _blsAnimation;

  @override
  void initState() {
    super.initState();
    _loadRoadmapData();
    _initBLSAnimation();
  }

  void _loadRoadmapData() {
    final answers = box.read('cbt_answers') ?? {};
    // Mocking positive beliefs if not found, or parsing from answers
    String pb = answers['Your Superpowers'] ?? "I am strong and resilient";
    _positiveBeliefs = [pb, "I am safe now"];
  }

  void _initBLSAnimation() {
    _blsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _blsController.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _blsController.forward();
        }
      });
    _blsAnimation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _blsController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _blsController.dispose();
    super.dispose();
  }

  void _playVoice(String text) {
    // In a real app, this would use TTS or specific audio files
    print("AI Speaking: $text");
  }

  void _startBLS(VoidCallback onComplete) {
    _blsController.forward();
    // Simulate a set
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        _blsController.stop();
        onComplete();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Custom_Home_Bg(),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: _buildCurrentPhaseView(),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF2E3E32)),
            onPressed: () => Get.back(),
          ),
          AppText(
            _getPhaseTitle(),
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2E3E32),
          ),
        ],
      ),
    );
  }

  String _getPhaseTitle() {
    switch (_currentPhase) {
      case S7Phase.preAssessment: return "Ongoing: Pre-Session";
      case S7Phase.continuation: return "Ongoing: Continuation";
      case S7Phase.phase2: return "Phase 2: Installation";
      case S7Phase.phase3: return "Phase 3: Body Scan";
      case S7Phase.closing: return "Session Closing";
    }
  }

  Widget _buildCurrentPhaseView() {
    switch (_currentPhase) {
      case S7Phase.preAssessment: return _buildPreAssessment();
      case S7Phase.continuation: return _buildContinuation();
      case S7Phase.phase2: return _buildPhase2();
      case S7Phase.phase3: return _buildPhase3();
      case S7Phase.closing: return _buildClosing();
    }
  }

  // ─── PRE-SESSION ──────────────────────────────────────────────────

  Widget _buildPreAssessment() {
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.assignment_outlined, size: 60, color: Color(0xFF537E5D)),
          const SizedBox(height: 20),
          const AppText("Pre-Session Protocol", fontSize: 22, fontWeight: FontWeight.bold),
          const SizedBox(height: 15),
          const AppText(
            "Before we begin, please complete these updated assessments to track your progress.",
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          _buildPrimaryButton("Start Assessments", () {
             Get.to(() => const FullAssessmentFlow());
          }),
          const SizedBox(height: 15),
          TextButton(
            onPressed: () => setState(() => _currentPhase = S7Phase.continuation),
            child: const Text("I've already done these", style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  // ─── CONTINUATION ─────────────────────────────────────────────────

  Widget _buildContinuation() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const AppText("Where are we today?", fontSize: 20, fontWeight: FontWeight.bold),
          const SizedBox(height: 40),
          _buildPrimaryButton("Continue Phase 1 (Processing)", () {
            // Navigate back to Session 6 logic if needed, or implement here
            Get.snackbar("Notice", "Redirecting to Processing flow...");
            // For now, let's assume they want to move to Phase 2
            setState(() => _currentPhase = S7Phase.phase2);
          }),
          const SizedBox(height: 15),
          _buildPrimaryButton("Move to Phase 2 (Installation)", () {
            setState(() => _currentPhase = S7Phase.phase2);
          }),
        ],
      ),
    );
  }

  // ─── PHASE 2 ──────────────────────────────────────────────────────

  Widget _buildPhase2() {
    final currentBelief = _positiveBeliefs[_currentBeliefIndex];
    
    switch (_p2State) {
      case S7Phase2State.intro:
        _playVoice("Look at the original image and put it together with the words $currentBelief and tell me how true this feels now.");
        return _buildPhase2Intro(currentBelief);
      case S7Phase2State.bls:
        return _buildBLSView("Focus on '$currentBelief' and your image");
      case S7Phase2State.checkIn:
        _playVoice("What do you notice now? Is it positive or negative?");
        return _buildPhase2CheckIn();
    }
  }

  Widget _buildPhase2Intro(String belief) {
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildGlassCard(
            child: Column(
              children: [
                const AppText("Positive Belief", fontSize: 14, color: Colors.grey),
                const SizedBox(height: 10),
                AppText('"$belief"', fontSize: 20, fontWeight: FontWeight.bold, textAlign: TextAlign.center),
              ],
            ),
          ),
          const SizedBox(height: 30),
          const AppText("How true does this feel now?", fontSize: 16),
          const AppText("1 = Not true, 7 = Completely true", fontSize: 12, color: Colors.grey),
          const SizedBox(height: 20),
          _buildScorePicker(7, _vocScore, (val) => setState(() => _vocScore = val), startFrom: 1),
          const SizedBox(height: 40),
          _buildPrimaryButton("Confirm Score", () {
            if (_vocScore >= 7) {
              _nextBeliefOrPhase3();
            } else {
              setState(() => _p2State = S7Phase2State.bls);
              _startBLS(() => setState(() => _p2State = S7Phase2State.checkIn));
            }
          }),
        ],
      ),
    );
  }

  Widget _buildPhase2CheckIn() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const AppText("What do you notice now?", fontSize: 20, fontWeight: FontWeight.bold),
          const SizedBox(height: 40),
          _buildPrimaryButton("It's Positive", () {
             _playVoice("Lovely! Keep going");
             setState(() => _p2State = S7Phase2State.intro);
          }),
          const SizedBox(height: 15),
          OutlinedButton(
            onPressed: () {
              _playVoice("OK good, keep going");
              // Return to Phase 1 (processing)
              setState(() => _currentPhase = S7Phase.continuation);
            },
            style: OutlinedButton.styleFrom(minimumSize: const Size(250, 55)),
            child: const Text("It's Negative / Neutral"),
          ),
        ],
      ),
    );
  }

  void _nextBeliefOrPhase3() {
    if (_currentBeliefIndex < _positiveBeliefs.length - 1) {
      setState(() {
        _currentBeliefIndex++;
        _p2State = S7Phase2State.intro;
        _vocScore = 1;
      });
    } else {
      setState(() => _currentPhase = S7Phase.phase3);
    }
  }

  // ─── PHASE 3 ──────────────────────────────────────────────────────

  Widget _buildPhase3() {
    final currentBelief = _positiveBeliefs[_currentBeliefIndex];
    switch (_p3State) {
      case S7Phase3State.intro:
        _playVoice("Now bring up the original image along with the positive belief $currentBelief... scan your body...");
        return _buildPhase3Intro();
      case S7Phase3State.bls:
        return _buildBLSView("Focus on the sensation in your body");
    }
  }

  Widget _buildPhase3Intro() {
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.accessibility_new, size: 60, color: Color(0xFF537E5D)),
          const SizedBox(height: 20),
          const AppText("Body Scan", fontSize: 22, fontWeight: FontWeight.bold),
          const SizedBox(height: 20),
          const AppText(
            "Notice any tension, sensations, or discomfort while focusing on your positive belief.",
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          _buildPrimaryButton("I feel tension / sensation", () {
            setState(() => _p3State = S7Phase3State.bls);
            _startBLS(() => setState(() => _p3State = S7Phase3State.intro));
          }),
          const SizedBox(height: 15),
          OutlinedButton(
            onPressed: () => setState(() => _currentPhase = S7Phase.closing),
            style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 55)),
            child: const Text("My body feels clear"),
          ),
        ],
      ),
    );
  }

  // ─── HELPERS ──────────────────────────────────────────────────────

  Widget _buildBLSView(String instruction) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppText(instruction, fontSize: 16, color: Colors.black54, textAlign: TextAlign.center),
        const SizedBox(height: 80),
        AnimatedBuilder(
          animation: _blsAnimation,
          builder: (context, child) {
            return Align(
              alignment: Alignment(_blsAnimation.value, 0),
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(color: Color(0xFF537E5D), shape: BoxShape.circle),
              ),
            );
          },
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildClosing() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
            const SizedBox(height: 20),
            const AppText("Session Complete!", fontSize: 24, fontWeight: FontWeight.bold),
            const SizedBox(height: 20),
            const AppText("Congratulations on finishing today's processing.", textAlign: TextAlign.center),
            const SizedBox(height: 40),
            _buildPrimaryButton("Return to Calm Place", () {
              Get.back();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: child,
    );
  }

  Widget _buildPrimaryButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF537E5D),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildScorePicker(int max, int current, Function(int) onSelected, {int startFrom = 0}) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(max - startFrom + 1, (index) {
        int val = startFrom + index;
        bool isSelected = current == val;
        return GestureDetector(
          onTap: () => onSelected(val),
          child: Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF537E5D) : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF537E5D)),
            ),
            child: Center(
              child: Text(
                val.toString(),
                style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF537E5D), fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      }),
    );
  }
}
