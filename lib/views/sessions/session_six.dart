import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jonssony/services/session_completion_service.dart';
import 'package:jonssony/views/sessions/session_seven.dart';
import 'package:jonssony/utils/app_text.dart';
import 'package:jonssony/utils/app_colors.dart';
import 'package:jonssony/widets/custom_home_bg.dart';

enum EMDRPhase { phase1, phase2, phase3, closing }

enum Phase1State { intro, ready, bls, checkin, suds }

class SessionSix extends StatefulWidget {
  const SessionSix({super.key});

  @override
  State<SessionSix> createState() => _SessionSixState();
}

class _SessionSixState extends State<SessionSix> with TickerProviderStateMixin {
  final box = GetStorage();

  EMDRPhase _currentPhase = EMDRPhase.phase1;
  Phase1State _p1State = Phase1State.intro;

  // Phase 1 Data
  int _sudsScore = 10;

  // Phase 2 Data
  int _vocScore = 1;

  // Timer Data
  Duration _sessionDuration = const Duration(hours: 1);
  Timer? _sessionTimer;
  Duration _remainingTime = const Duration(hours: 1);

  // BLS Animation
  late AnimationController _blsController;
  late Animation<double> _blsAnimation;

  @override
  void initState() {
    super.initState();
    _blsController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 750),
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            _blsController.reverse();
          } else if (status == AnimationStatus.dismissed) {
            _blsController.forward();
          }
        });
    _blsAnimation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _blsController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _blsController.dispose();
    _sessionTimer?.cancel();
    super.dispose();
  }

  void _startSessionTimer(double totalMinutes) {
    _sessionDuration = Duration(seconds: (totalMinutes * 60).toInt());
    _remainingTime = _sessionDuration;
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime.inSeconds > 0) {
        setState(() {
          _remainingTime = _remainingTime - const Duration(seconds: 1);
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _startBLS() {
    setState(() {
      _p1State = Phase1State.bls;
    });
    _blsController.forward();

    Future.delayed(const Duration(seconds: 30), () {
      if (mounted && _p1State == Phase1State.bls) {
        _stopBLS();
      }
    });
  }

  void _stopBLS() {
    if (!mounted) return;
    _blsController.stop();
    setState(() {
      _p1State = Phase1State.checkin;
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
                if (_sessionTimer != null) _buildTimerHeader(),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: _buildCurrentStateView(),
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
      case EMDRPhase.phase1:
        return "Phase 1: Desensitisation";
      case EMDRPhase.phase2:
        return "Phase 2: Installation";
      case EMDRPhase.phase3:
        return "Phase 3: Body Scan";
      case EMDRPhase.closing:
        return "Session Closing";
    }
  }

  Widget _buildTimerHeader() {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(_remainingTime.inHours);
    final minutes = twoDigits(_remainingTime.inMinutes.remainder(60));
    final seconds = twoDigits(_remainingTime.inSeconds.remainder(60));
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      decoration: BoxDecoration(
        color: AppColors.mainAppColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        "Time Remaining: $hours:$minutes:$seconds",
        style: TextStyle(
          color: AppColors.mainAppColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCurrentStateView() {
    switch (_currentPhase) {
      case EMDRPhase.phase1:
        return _buildPhase1View();
      case EMDRPhase.phase2:
        return _buildPhase2View();
      case EMDRPhase.phase3:
        return _buildPhase3View();
      case EMDRPhase.closing:
        return _buildClosingView();
    }
  }

  // ─── PHASE 1 VIEWS ─────────────────────────────────────────────────

  Widget _buildPhase1View() {
    switch (_p1State) {
      case Phase1State.intro:
        return _buildIntroView();
      case Phase1State.ready:
        return _buildReadyView();
      case Phase1State.bls:
        return _buildBLSView();
      case Phase1State.checkin:
        return _buildCheckInView();
      case Phase1State.suds:
        return _buildSUDSView();
    }
  }

  Widget _buildIntroView() {
    final answers = box.read('cbt_answers') ?? {};
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppText(
                  "Roadmap Summary",
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(height: 15),
                _buildSummaryItem(
                  "Target Memory",
                  answers['A Recent Happening'] ?? "Not specified",
                ),
                _buildSummaryItem(
                  "Negative Belief",
                  answers['Deep-Down Beliefs'] ?? "Not specified",
                ),
                _buildSummaryItem(
                  "Emotions",
                  answers['My Feelings'] ?? "Not specified",
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          const AppText(
            "Listen carefully to the guidance. When you feel centered and ready to begin, press the button below.",
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          _buildPrimaryButton(
            "Choose Session Length",
            () => _showDurationPicker(),
          ),
        ],
      ),
    );
  }

  void _showDurationPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppText(
              "Choose Session Duration",
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 20),
            _buildListTile("1 min (Test)", () {
              _startSessionTimer(1);
              Navigator.pop(context);
              setState(() => _p1State = Phase1State.ready);
            }),
            _buildListTile("1.5 min (Test)", () {
              _startSessionTimer(1.5);
              Navigator.pop(context);
              setState(() => _p1State = Phase1State.ready);
            }),
            _buildListTile("5 min", () {
              _startSessionTimer(5);
              Navigator.pop(context);
              setState(() => _p1State = Phase1State.ready);
            }),
            _buildListTile("10 min", () {
              _startSessionTimer(10);
              Navigator.pop(context);
              setState(() => _p1State = Phase1State.ready);
            }),
            _buildListTile("20 min", () {
              _startSessionTimer(20);
              Navigator.pop(context);
              setState(() => _p1State = Phase1State.ready);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildReadyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const AppText(
            "When you are ready...",
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 40),
          _buildPrimaryButton("Start Bilateral Stimulation", _startBLS),
        ],
      ),
    );
  }

  Widget _buildBLSView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const AppText(
          "Follow the moving object with your eyes",
          fontSize: 16,
          color: Colors.black54,
        ),
        const SizedBox(height: 60),
        AnimatedBuilder(
          animation: _blsAnimation,
          builder: (context, child) {
            return Align(
              alignment: Alignment(_blsAnimation.value, 0),
              child: Image.asset(
                'assets/images/Butterfly Lottie Animation.gif',
                width: 72,
                height: 72,
                fit: BoxFit.contain,
              ),
            );
          },
        ),
        const SizedBox(height: 100),
        OutlinedButton(
          onPressed: _stopBLS,
          child: const Text("Stop set and check in"),
        ),
      ],
    );
  }

  Widget _buildCheckInView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AppText(
              "Is it changing and still connected?",
              fontSize: 20,
              fontWeight: FontWeight.bold,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            _buildPrimaryButton("Yes, it's changing", () {
              // "Ok good, go with that"
              _startBLS();
            }),
            const SizedBox(height: 15),
            OutlinedButton(
              onPressed: () {
                // "Ok, lets go back to the original image..."
                setState(() => _p1State = Phase1State.suds);
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
              ),
              child: const Text("No, it's not changing"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSUDSView() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const AppText(
            "Notice what you see and feel in the original image.",
            fontSize: 16,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          const AppText(
            "Rate your negative emotion (SUDS)",
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          const AppText(
            "0 = No disturbance, 10 = Maximum disturbance",
            fontSize: 12,
            color: Colors.grey,
          ),
          const SizedBox(height: 20),
          _buildScorePicker(
            10,
            _sudsScore,
            (val) => setState(() => _sudsScore = val),
          ),
          const SizedBox(height: 30),
          _buildPrimaryButton("Confirm Score", () {
            if (_sudsScore <= 1) {
              setState(() {
                _currentPhase = EMDRPhase.phase2;
              });
            } else {
              // "Ok lets continue with what you noticed..."
              setState(() => _p1State = Phase1State.ready);
            }
          }),
        ],
      ),
    );
  }

  // ─── PHASE 2 VIEWS ─────────────────────────────────────────────────

  Widget _buildPhase2View() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const AppText(
            "Phase 2: Positive Belief Installation",
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 20),
          const AppText(
            "Focus on your positive belief. How true does it feel now?",
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          const AppText(
            "1 = Completely false, 7 = Completely true",
            fontSize: 12,
            color: Colors.grey,
          ),
          const SizedBox(height: 20),
          _buildScorePicker(
            7,
            _vocScore,
            (val) => setState(() => _vocScore = val),
            startFrom: 1,
          ),
          const SizedBox(height: 30),
          _buildPrimaryButton("Confirm Score", () {
            if (_vocScore >= 6) {
              setState(() => _currentPhase = EMDRPhase.phase3);
            } else {
              // Continue installation (represented by another BLS set)
              _startBLS(); // In a real app, this might lead back to a modified BLS screen
            }
          }),
        ],
      ),
    );
  }

  // ─── PHASE 3 VIEWS ─────────────────────────────────────────────────

  Widget _buildPhase3View() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.accessibility_new,
            size: 80,
            color: Color(0xFF537E5D),
          ),
          const SizedBox(height: 20),
          const AppText(
            "Phase 3: Body Scan",
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 20),
          const AppText(
            "Close your eyes and scan your body from head to toe. Notice if there is any tension or unusual sensation.",
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          _buildPrimaryButton("Scan Complete", () {
            setState(() => _currentPhase = EMDRPhase.closing);
          }),
        ],
      ),
    );
  }

  // ─── CLOSING VIEWS ─────────────────────────────────────────────────

  Widget _buildClosingView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Column(
        children: [
          const Icon(Icons.favorite, size: 60, color: Colors.redAccent),
          const SizedBox(height: 20),
          const AppText(
            "Calm Place Exercise",
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 15),
          const AppText(
            "Bring up your Calm Place pincode. Spend a minute finding that nice feeling in your body.",
            textAlign: TextAlign.center,
            fontSize: 16,
          ),
          const SizedBox(height: 40),
          _buildGlassCard(
            child: const AppText(
              "Processing continues even after the session. Please wait 4 days to a week before your next session to allow your mind to fully integrate today's work.",
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 40),
          _buildPrimaryButton("Go to Session 7 (Ongoing)", () async {
            await SessionCompletionService.markCompleted(6);
            Get.to(() => const SessionSeven(), arguments: Get.arguments);
          }),
          const SizedBox(height: 15),
          OutlinedButton(
            onPressed: () => Get.back(),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 55),
            ),
            child: const Text("Finish & Return Home"),
          ),
        ],
      ),
    );
  }

  // ─── WIDGET HELPERS ────────────────────────────────────────────────

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

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
          Text(value, style: const TextStyle(fontSize: 14)),
        ],
      ),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildScorePicker(
    int max,
    int current,
    Function(int) onSelected, {
    int startFrom = 0,
  }) {
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
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF537E5D),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildListTile(String title, VoidCallback onTap) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
