import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jonssony/data/bls_built_in_sounds.dart';
import 'package:jonssony/data/bls_speed_presets.dart';
import 'package:jonssony/services/session_completion_service.dart';
import 'package:jonssony/services/voice_service.dart';
import 'package:jonssony/utils/app_text.dart';
import 'package:jonssony/views/Library/bls_pdf_visuals.dart';
import 'package:jonssony/views/Library/clam_space_ex.dart';
import 'package:jonssony/views/Library/simulation_screen.dart';
import 'package:jonssony/views/Library/simulation_settings.dart';
import 'package:jonssony/views/profile/subcription/assignment.dart';
import 'package:jonssony/widets/custom_home_bg.dart';

enum S7Phase { preAssessment, continuation, phase2, phase3, closing }

/// Phase 2: positive belief installation (VoC + BLS loop).
enum S7Phase2State { intro, installation, checkIn, recheckVoc }

/// Phase 3: body scan + targeted BLS on sensations.
enum S7Phase3State { intro, installation, checkIn }

class SessionSeven extends StatefulWidget {
  const SessionSeven({
    super.key,
    this.initialPhase = S7Phase.preAssessment,
    this.sessionNumber,
  });

  final S7Phase initialPhase;
  final int? sessionNumber;

  @override
  State<SessionSeven> createState() => _SessionSevenState();
}

class _SessionSevenState extends State<SessionSeven> {
  final box = GetStorage();
  final VoiceService _voice = VoiceService();
  String? _lastSpokenCue;

  S7Phase _currentPhase = S7Phase.preAssessment;
  S7Phase2State _p2State = S7Phase2State.intro;
  S7Phase3State _p3State = S7Phase3State.intro;

  List<String> _positiveBeliefs = [];
  int _currentBeliefIndex = 0;
  int _vocScore = 1;

  @override
  void initState() {
    super.initState();
    _currentPhase = widget.initialPhase;
    final journeyId = _journeyId;
    if (journeyId.isNotEmpty) {
      SessionCompletionService.setActiveJourney(journeyId);
    }
    _loadRoadmapData();
  }

  String get _journeyId {
    final args = Get.arguments;
    if (args is Map && args['journeyId'] != null) {
      return args['journeyId'].toString();
    }
    return SessionCompletionService.activeJourneyId();
  }

  int get _sessionNumber {
    final fromWidget = widget.sessionNumber;
    if (fromWidget != null &&
        fromWidget >= 1 &&
        fromWidget <= SessionCompletionService.totalSessions) {
      return fromWidget;
    }

    final args = Get.arguments;
    if (args is Map && args['sessionNumber'] != null) {
      final parsed = int.tryParse(args['sessionNumber'].toString());
      if (parsed != null &&
          parsed >= 1 &&
          parsed <= SessionCompletionService.totalSessions) {
        return parsed;
      }
    }

    return 7;
  }

  void _loadRoadmapData() {
    final answers = box.read('cbt_answers') ?? {};
    final rawBeliefs = answers is Map
        ? answers['Your Superpowers']?.toString() ?? ''
        : '';
    _positiveBeliefs = rawBeliefs
        .split(RegExp(r'[,;\n]'))
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();
    if (_positiveBeliefs.isEmpty) {
      _positiveBeliefs = ['I am strong and resilient'];
    }
  }

  String get _currentBelief => _positiveBeliefs[_currentBeliefIndex];

  @override
  void dispose() {
    _voice.dispose();
    super.dispose();
  }

  void _playVoice(String text) {
    if (_lastSpokenCue == text) return;
    _lastSpokenCue = text;
    unawaited(_voice.speak(text));
  }

  void _resetVoiceCue() => _lastSpokenCue = null;

  Future<void> _launchBls(VoidCallback onComplete) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SimulationScreen(
          settings: _savedSimulationSettings(showCompletionQuestions: false),
        ),
      ),
    );
    if (!mounted) return;
    _resetVoiceCue();
    onComplete();
  }

  Future<void> _startPhase1Processing() async {
    final phaseTwoReady = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => SimulationScreen(
          settings: _savedSimulationSettings(showCompletionQuestions: true),
        ),
      ),
    );
    if (!mounted) return;
    _resetVoiceCue();
    if (phaseTwoReady == true) {
      setState(() {
        _currentPhase = S7Phase.phase2;
        _p2State = S7Phase2State.intro;
        _vocScore = 1;
      });
    }
  }

  SimulationSettings _savedSimulationSettings({
    required bool showCompletionQuestions,
  }) {
    final raw = box.read('bls_html_config');
    final config = raw is Map
        ? Map<String, dynamic>.from(raw)
        : <String, dynamic>{};
    final background = _configValue(config, 'background', 'meadow');
    final object = _configValue(config, 'object', 'butterfly');
    final sound = _configValue(
      config,
      'soundKey',
      _configValue(config, 'sound', BlsBuiltInSounds.defaultKey),
    );
    final soundAsset = _configValue(config, 'soundAsset', '');
    final resolvedSoundKey = _isNetworkSoundSource(sound)
        ? BlsBuiltInSounds.defaultKey
        : BlsBuiltInSounds.normalizeKey(sound);
    final resolvedAudioAsset = soundAsset.isNotEmpty
        ? soundAsset
        : (_isNetworkSoundSource(sound) ? sound : '');
    final visualMediaType = _configValue(config, 'visualMediaType', 'sprite');
    final visualPoster = _configValue(config, 'visualPoster', '');
    final durationMinutes =
        int.tryParse(_configValue(config, 'durationMinutes', '60')) ?? 60;

    return SimulationSettings(
      environmentImage: _normaliseSceneSource(background),
      visualObject: _normaliseObjectSource(object),
      speed: BlsSpeedPresets.secondsForKey(_configValue(config, 'speed', 'medium')),
      audioAsset: resolvedAudioAsset,
      soundKey: resolvedSoundKey,
      visualMediaType: visualMediaType,
      visualPoster: visualPoster.isEmpty ? null : visualPoster,
      direction: _directionFromKey(
        _configValue(config, 'direction', 'horizontal'),
      ),
      showCompletionQuestions: showCompletionQuestions,
      totalSets: showCompletionQuestions ? 34 : 0,
      maxDurationMinutes: showCompletionQuestions ? durationMinutes : 0,
      roadmapSummary: _roadmapSummary(),
    );
  }

  String _roadmapSummary() {
    final answers = box.read('cbt_answers') ?? {};
    if (answers is! Map) return '';
    final map = Map<String, dynamic>.from(answers);
    final pieces = <String>[];
    void add(String label, String key) {
      final value = map[key]?.toString().trim();
      if (value != null && value.isNotEmpty) pieces.add('$label: $value');
    }

    add('Original image', 'A Recent Happening');
    add('Trigger', 'Triggers');
    add('Feelings', 'My Feelings');
    add('Positive belief', 'Your Superpowers');
    return pieces.join('. ');
  }

  String _configValue(
    Map<String, dynamic> config,
    String key,
    String fallback,
  ) {
    final value = config[key]?.toString().trim();
    return value == null || value.isEmpty ? fallback : value;
  }

  String _normaliseSceneSource(String value) =>
      resolveBlsEnvironmentSource(value);

  bool _isNetworkSoundSource(String value) {
    final uri = Uri.tryParse(value.trim());
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  String _normaliseObjectSource(String value) {
    if (value.startsWith(blsObjectPrefix) ||
        value.startsWith('http') ||
        value.startsWith('assets/') ||
        value.contains('/nobg/')) {
      return value;
    }
    return value;
  }

  AnimationDirection _directionFromKey(String key) {
    switch (key) {
      case 'vertical':
      case 'top-bottom':
        return AnimationDirection.vertical;
      case 'diagonal-down':
        return AnimationDirection.diagonal;
      case 'diagonal-up':
        return AnimationDirection.diagonalReverse;
      case 'horizontal':
      case 'left-right':
      default:
        return AnimationDirection.horizontal;
    }
  }

  String get _phaseSwitcherKey =>
      '${_currentPhase.name}|${_p2State.name}|${_p3State.name}|$_currentBeliefIndex';

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
                    duration: const Duration(milliseconds: 400),
                    child: SingleChildScrollView(
                      key: ValueKey(_phaseSwitcherKey),
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 24),
                      child: _buildCurrentPhaseView(),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF2E3E32)),
            onPressed: () => Get.back(),
          ),
          AppText(
            _phaseTitle,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2E3E32),
          ),
        ],
      ),
    );
  }

  String get _phaseTitle {
    switch (_currentPhase) {
      case S7Phase.preAssessment:
        return 'Ongoing: Pre-Session';
      case S7Phase.continuation:
        return 'Ongoing: Continuation';
      case S7Phase.phase2:
        return 'Phase 2: Positive Belief';
      case S7Phase.phase3:
        return 'Phase 3: Body Scan';
      case S7Phase.closing:
        return 'Session Closing';
    }
  }

  Widget _buildCurrentPhaseView() {
    switch (_currentPhase) {
      case S7Phase.preAssessment:
        return _buildPreAssessment(key: const ValueKey('pre'));
      case S7Phase.continuation:
        return _buildContinuation(key: const ValueKey('cont'));
      case S7Phase.phase2:
        return KeyedSubtree(
          key: ValueKey('p2-${_p2State.name}-$_currentBeliefIndex'),
          child: _buildPhase2(),
        );
      case S7Phase.phase3:
        return KeyedSubtree(
          key: ValueKey('p3-${_p3State.name}'),
          child: _buildPhase3(),
        );
      case S7Phase.closing:
        return _buildClosing(key: const ValueKey('close'));
    }
  }

  // ─── PRE-SESSION (ongoing sessions 2+) ───────────────────────────

  Widget _buildPreAssessment({Key? key}) {
    return Padding(
      key: key,
      padding: const EdgeInsets.all(25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.assignment_outlined,
            size: 60,
            color: Color(0xFF537E5D),
          ),
          const SizedBox(height: 20),
          const AppText(
            'Pre-Session Protocol',
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 15),
          const AppText(
            'Before we begin, please complete updated assessments (PHQ, GAD, and others) to track your progress. Results are saved in My Resources.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          _buildPrimaryButton('Start Assessments', () {
            Get.to(() => const FullAssessmentFlow());
          }),
          const SizedBox(height: 15),
          TextButton(
            onPressed: () =>
                setState(() => _currentPhase = S7Phase.continuation),
            child: const Text(
              "I've already done these",
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  // ─── CONTINUATION ────────────────────────────────────────────────

  Widget _buildContinuation({Key? key}) {
    return Padding(
      key: key,
      padding: const EdgeInsets.all(25),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppText(
            'EMDR Continuation',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const AppText(
            'Continue Phase 1 processing until your negative emotion is 1/10 or below, then move to Phase 2.',
            fontSize: 14,
            color: Colors.black54,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildPrimaryButton('Continue Phase 1 (Processing)', () {
            _playVoice(
              'Ok, let us continue with what you noticed about your original image.',
            );
            unawaited(_startPhase1Processing());
          }),
          const SizedBox(height: 12),
          _buildPrimaryButton('Move to Phase 2 (Installation)', () {
            setState(() {
              _currentPhase = S7Phase.phase2;
              _p2State = S7Phase2State.intro;
              _vocScore = 1;
            });
          }),
        ],
      ),
    );
  }

  // ─── PHASE 2: POSITIVE BELIEF INSTALLATION ───────────────────────

  Widget _buildPhase2() {
    switch (_p2State) {
      case S7Phase2State.intro:
        _playVoice(
          'Look at the original image and put it together with the words $_currentBelief, and tell me how true this feels now. 1 is not true and 7 is completely true.',
        );
        return _buildVocCard(
          title: 'Positive Belief Installation',
          belief: _currentBelief,
          buttonLabel: 'Continue',
          onConfirm: () {
            if (_vocScore >= 7) {
              _advanceBeliefOrPhase3();
            } else {
              setState(() => _p2State = S7Phase2State.installation);
            }
          },
        );
      case S7Phase2State.installation:
        _playVoice(
          'Put the words $_currentBelief together with your original image, or what is left of it. Mash it together in your mind and start the bilateral stimulation.',
        );
        return _buildBlsPrompt(
          icon: Icons.auto_awesome_rounded,
          title: 'Installation Set',
          body:
              'Put "$_currentBelief" together with your original image or what is left of it.',
          buttonLabel: 'Start bilateral stimulation',
          onStart: () => unawaited(
            _launchBls(() => setState(() => _p2State = S7Phase2State.checkIn)),
          ),
        );
      case S7Phase2State.checkIn:
        _playVoice('What do you notice now? Is it positive or negative?');
        return _buildCheckInCard(
          title: 'Post-set check-in',
          subtitle: 'What do you notice now?',
          positiveLabel: "It's positive",
          negativeLabel: "It's negative / neutral",
          onPositive: () {
            setState(() {
              _p2State = S7Phase2State.recheckVoc;
              _vocScore = 1;
            });
          },
          onNegative: () {
            _playVoice('OK good, keep going');
            setState(() => _currentPhase = S7Phase.continuation);
          },
        );
      case S7Phase2State.recheckVoc:
        _playVoice(
          'If you again put the words $_currentBelief together with your original image, or what is left of it, how true does that feel now? 1 is not true and 7 is completely true.',
        );
        return _buildVocCard(
          title: 'VoC re-check',
          belief: _currentBelief,
          buttonLabel: 'Continue',
          onConfirm: () {
            if (_vocScore >= 6) {
              _playVoice('Lovely! Keep going');
              _advanceBeliefOrPhase3();
              return;
            }
            _playVoice('Lovely! Keep going');
            setState(() => _p2State = S7Phase2State.installation);
          },
        );
    }
  }

  void _advanceBeliefOrPhase3() {
    if (_currentBeliefIndex < _positiveBeliefs.length - 1) {
      setState(() {
        _currentBeliefIndex++;
        _p2State = S7Phase2State.intro;
        _vocScore = 1;
      });
      _resetVoiceCue();
      return;
    }
    setState(() {
      _currentPhase = S7Phase.phase3;
      _p3State = S7Phase3State.intro;
    });
    _resetVoiceCue();
  }

  // ─── PHASE 3: BODY SCAN ──────────────────────────────────────────

  Widget _buildPhase3() {
    switch (_p3State) {
      case S7Phase3State.intro:
        _playVoice(
          'Now bring up the original image. Close your eyes and scan your body from the top of your head to the tips of your toes. Notice any tension, sensations, or discomfort.',
        );
        return _buildPhase3Intro();
      case S7Phase3State.installation:
        _playVoice(
          'Focus completely on that sensation in your body and start your bilateral stimulation.',
        );
        return _buildBlsPrompt(
          icon: Icons.accessibility_new_rounded,
          title: 'Target the sensation',
          body: 'Focus completely on that sensation in your body.',
          buttonLabel: 'Start bilateral stimulation',
          onStart: () => unawaited(
            _launchBls(() => setState(() => _p3State = S7Phase3State.checkIn)),
          ),
        );
      case S7Phase3State.checkIn:
        _playVoice('Check your body again. Is that sensation still present?');
        return _buildPhase3CheckIn();
    }
  }

  Widget _buildPhase3Intro() {
    return Padding(
      padding: const EdgeInsets.all(25),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.accessibility_new,
            size: 48,
            color: Color(0xFF537E5D),
          ),
          const SizedBox(height: 16),
          const AppText(
            'Body Scan',
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 12),
          const AppText(
            'Close your eyes and scan from the top of your head to the tips of your toes. Notice any tension, sensations, or discomfort.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildPrimaryButton('I feel a sensation / tension', () {
            setState(() => _p3State = S7Phase3State.installation);
          }),
          const SizedBox(height: 12),
          _buildGlassSecondaryButton(
            label: 'My body feels clear',
            onPressed: _finishSession,
          ),
        ],
      ),
    );
  }

  Widget _buildPhase3CheckIn() {
    return Padding(
      padding: const EdgeInsets.all(25),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppText(
            'Is that sensation still present?',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const AppText(
            'If it is still there, keep processing. If it has cleared, scan again for any other sensations.',
            fontSize: 14,
            color: Colors.black54,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildPrimaryButton('Yes — keep processing', () {
            setState(() => _p3State = S7Phase3State.installation);
          }),
          const SizedBox(height: 12),
          _buildGlassSecondaryButton(
            label: 'No — scan for other sensations',
            onPressed: () {
              setState(() => _p3State = S7Phase3State.intro);
            },
          ),
          const SizedBox(height: 12),
          _buildGlassSecondaryButton(
            label: 'My body is completely clear',
            onPressed: _finishSession,
          ),
        ],
      ),
    );
  }

  void _finishSession() {
    _playVoice(
      'Congratulations. You have completed this session. Return to your calm place.',
    );
    unawaited(
      SessionCompletionService.markCompleted(
        _sessionNumber,
        journeyId: _journeyId.isNotEmpty ? _journeyId : null,
      ),
    );
    setState(() => _currentPhase = S7Phase.closing);
  }

  // ─── CLOSING ─────────────────────────────────────────────────────

  Widget _buildClosing({Key? key}) {
    return SingleChildScrollView(
      key: key,
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 80,
              color: Colors.green,
            ),
            const SizedBox(height: 20),
            const AppText(
              'Session Complete',
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 24),
            _buildClosingCard(
              icon: Icons.spa_outlined,
              title: 'Calm place exercise',
              body:
                  'Bring up your pincode and spend one minute finding that calm feeling in your body.',
            ),
            const SizedBox(height: 14),
            _buildClosingCard(
              icon: Icons.schedule_outlined,
              title: 'Before your next session',
              body:
                  'Please wait 4 days to 1 week before the next session while processing continues.',
            ),
            const SizedBox(height: 30),
            _buildPrimaryButton('Open Calm Place', () {
              Get.to(() => const MyCalmSpaceExercise());
            }),
          ],
        ),
      ),
    );
  }

  // ─── SHARED UI ───────────────────────────────────────────────────

  Widget _buildVocCard({
    required String title,
    required String belief,
    required String buttonLabel,
    required VoidCallback onConfirm,
  }) {
    return Padding(
      padding: const EdgeInsets.all(25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText(title, fontSize: 18, fontWeight: FontWeight.bold),
          const SizedBox(height: 20),
          _buildGlassCard(
            child: Column(
              children: [
                const AppText(
                  'Positive belief',
                  fontSize: 14,
                  color: Colors.grey,
                ),
                const SizedBox(height: 10),
                AppText(
                  '"$belief"',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const AppText('How true does this feel now?', fontSize: 16),
          const AppText(
            '1 = not true, 7 = completely true',
            fontSize: 12,
            color: Colors.black,
          ),
          const SizedBox(height: 20),
          _buildScorePicker(
            7,
            _vocScore,
            (val) => setState(() => _vocScore = val),
            startFrom: 1,
          ),
          const SizedBox(height: 36),
          _buildPrimaryButton(buttonLabel, onConfirm),
        ],
      ),
    );
  }

  Widget _buildBlsPrompt({
    required IconData icon,
    required String title,
    required String body,
    required String buttonLabel,
    required VoidCallback onStart,
  }) {
    return Padding(
      padding: const EdgeInsets.all(25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: const Color(0xFF537E5D)),
          const SizedBox(height: 20),
          AppText(title, fontSize: 20, fontWeight: FontWeight.bold),
          const SizedBox(height: 16),
          AppText(
            body,
            fontSize: 15,
            color: const Color(0xFF151515),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          _buildPrimaryButton(buttonLabel, onStart),
        ],
      ),
    );
  }

  Widget _buildCheckInCard({
    required String title,
    required String subtitle,
    required String positiveLabel,
    required String negativeLabel,
    required VoidCallback onPositive,
    required VoidCallback onNegative,
  }) {
    return Padding(
      padding: const EdgeInsets.all(25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText(title, fontSize: 18, fontWeight: FontWeight.bold),
          const SizedBox(height: 12),
          AppText(subtitle, fontSize: 16, textAlign: TextAlign.center),
          const SizedBox(height: 28),
          _buildPrimaryButton(positiveLabel, onPositive),
          const SizedBox(height: 12),
          _buildGlassSecondaryButton(
            label: negativeLabel,
            onPressed: onNegative,
          ),
        ],
      ),
    );
  }

  Widget _buildClosingCard({
    required IconData icon,
    required String title,
    required String body,
  }) {
    return _buildGlassCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF537E5D), size: 26),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  title,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2E3E32),
                ),
                const SizedBox(height: 8),
                AppText(body, fontSize: 14, color: Colors.black87),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
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

  Widget _buildGlassSecondaryButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    const green = Color(0xFF537E5D);

    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: green.withValues(alpha: 0.45),
              width: 1.2,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(15),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: Center(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: green,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScorePicker(
    int max,
    int current,
    ValueChanged<int> onSelected, {
    int startFrom = 0,
  }) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: List.generate(max - startFrom + 1, (index) {
        final val = startFrom + index;
        final isSelected = current == val;
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
}
