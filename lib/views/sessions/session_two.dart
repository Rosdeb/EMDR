import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jonssony/services/cbt_service.dart';
import 'package:jonssony/services/session_completion_service.dart';
import 'package:jonssony/views/sessions/session_three.dart';

// ─── DATA MODELS ────────────────────────────────────────────────────────────

class JourneyData {
  String recentHappening = '';
  String triggers = '';
  String thoughts = '';
  List<String> feelings = [];
  String behaviors = '';
  List<String> deepBeliefs = [];
  String childhood = '';
  String rules = '';
  List<String> consequences = [];
  String consequencesOther = '';
  String superpowers = '';

  bool get isMinimallyComplete =>
      recentHappening.isNotEmpty &&
      thoughts.isNotEmpty &&
      feelings.isNotEmpty &&
      behaviors.isNotEmpty;
}

// ─── CONSTANTS ───────────────────────────────────────────────────────────────

const List<String> negativeBeliefs = [
  "I don't deserve love",
  "I am a bad person",
  "I am terrible",
  "I am worthless/inadequate",
  "I am shameful",
  "I am not lovable",
  "I am not good enough",
  "I deserve only bad things",
  "I am permanently damaged",
  "I am ugly/my body is hateful",
  "I do not deserve...",
  "I am stupid/not smart enough",
  "I am insignificant/unimportant",
  "I am a disappointment",
  "I deserve to die",
  "I deserve to be miserable",
  "I am different/don't belong",
  "I should have done something",
  "I did something wrong",
  "I should have known better",
  "I should have done more",
  "It's my fault",
  "I cannot trust myself",
  "I cannot trust my judgment",
  "I cannot succeed",
  "I am not in control",
  "I am powerless/helpless",
  "I am weak",
  "I cannot stand up for myself",
  "I cannot let it out",
  "I am in danger",
  "I am not safe",
  "I cannot trust anyone",
  "I cannot protect myself",
  "It's not OK to feel/show my emotions",
  "I am alone",
  "I have to be perfect/please everyone",
  "I am responsible for others",
];

const List<String> consequenceOptions = [
  "Difficulty forming relationships",
  "Difficulty calming the body and mind",
  "Struggles with feeling safe",
  "Fear of the unknown",
  "Difficulty caring for oneself",
  "Holding on to bitterness or past hurts",
  "Loss of meaning or hope",
  "Avoidance of difficult thoughts or feelings",
];

const List<Map<String, dynamic>> emotions = [
  {'label': 'Sad', 'color1': Color(0xFF74B9FF), 'color2': Color(0xFF6C5CE7)},
  {
    'label': 'Shocked',
    'color1': Color(0xFFFF6B6B),
    'color2': Color(0xFFEE5A24),
  },
  {'label': 'Angry', 'color1': Color(0xFFFF6B6B), 'color2': Color(0xFFC0392B)},
  {
    'label': 'Irritated',
    'color1': Color(0xFFE17055),
    'color2': Color(0xFFD63031),
  },
  {
    'label': 'Anxious',
    'color1': Color(0xFFA29BFE),
    'color2': Color(0xFF6C5CE7),
  },
  {'label': 'Panic', 'color1': Color(0xFFFD79A8), 'color2': Color(0xFFE84393)},
  {
    'label': 'Frightened',
    'color1': Color(0xFF636E72),
    'color2': Color(0xFF2D3436),
  },
  {
    'label': 'Stressed',
    'color1': Color(0xFFFDCB6E),
    'color2': Color(0xFFF39C12),
  },
  {'label': 'Scared', 'color1': Color(0xFFDFE6E9), 'color2': Color(0xFFB2BEC3)},
  {
    'label': 'Confused',
    'color1': Color(0xFFFD79A8),
    'color2': Color(0xFFA29BFE),
  },
  {'label': 'Guilty', 'color1': Color(0xFF636E72), 'color2': Color(0xFF2D3436)},
  {
    'label': 'Ashamed',
    'color1': Color(0xFFFAB1A0),
    'color2': Color(0xFFE17055),
  },
  {'label': 'Hurt', 'color1': Color(0xFFFF7675), 'color2': Color(0xFFD63031)},
  {'label': 'Grief', 'color1': Color(0xFF95A5A6), 'color2': Color(0xFF7F8C8D)},
];

// ─── HELPER CONFIG ───────────────────────────────────────────────────────────

class BubbleConfig {
  final String id;
  final String label;
  final String subtitle;
  final String sectionTitle;
  final Color borderColor;
  final Color bgColor1;
  final Color bgColor2;
  final bool isResponseBubble;

  const BubbleConfig({
    required this.id,
    required this.label,
    required this.subtitle,
    required this.sectionTitle,
    required this.borderColor,
    required this.bgColor1,
    required this.bgColor2,
    this.isResponseBubble = false,
  });
}

const List<BubbleConfig> mainBubbles = [
  BubbleConfig(
    id: 'childhood',
    label: 'When I Was Little',
    subtitle: 'Early memories & experiences',
    sectionTitle: 'The Beginning',
    borderColor: Color(0xFF2E7D32),
    bgColor1: Colors.white,
    bgColor2: Color(0xFFE8F5E9),
  ),
  BubbleConfig(
    id: 'deep-beliefs',
    label: 'Deep-Down Beliefs',
    subtitle: 'What I believe about myself',
    sectionTitle: 'What I Learned',
    borderColor: Color(0xFF388E3C),
    bgColor1: Colors.white,
    bgColor2: Color(0xFFF1F8E9),
  ),
  BubbleConfig(
    id: 'rules',
    label: 'The Rules',
    subtitle: 'How I must be to feel safe',
    sectionTitle: 'My Survival Guide',
    borderColor: Color(0xFF43A047),
    bgColor1: Colors.white,
    bgColor2: Color(0xFFE8F5E9),
  ),
  BubbleConfig(
    id: 'triggers',
    label: 'Triggers',
    subtitle: 'What activates my patterns',
    sectionTitle: 'Life Happens',
    borderColor: Color(0xFF4CAF50),
    bgColor1: Colors.white,
    bgColor2: Color(0xFFF1F8E9),
  ),
  BubbleConfig(
    id: 'recent-happening',
    label: 'A Recent Happening',
    subtitle: 'The situation that brought me here',
    sectionTitle: 'Right Now',
    borderColor: Color(0xFF66BB6A),
    bgColor1: Colors.white,
    bgColor2: Color(0xFFE8F5E9),
  ),
];

const List<BubbleConfig> responseBubbles = [
  BubbleConfig(
    id: 'thoughts',
    label: 'Thoughts',
    subtitle: 'In my head',
    sectionTitle: '',
    borderColor: Color(0xFF81C784),
    bgColor1: Colors.white,
    bgColor2: Color(0xFFF1F8E9),
    isResponseBubble: true,
  ),
  BubbleConfig(
    id: 'feelings',
    label: 'Feelings',
    subtitle: 'In my body',
    sectionTitle: '',
    borderColor: Color(0xFF4CAF50),
    bgColor1: Colors.white,
    bgColor2: Color(0xFFE8F5E9),
    isResponseBubble: true,
  ),
  BubbleConfig(
    id: 'behaviors',
    label: 'Behaviors',
    subtitle: 'What I did',
    sectionTitle: '',
    borderColor: Color(0xFF689F38),
    bgColor1: Colors.white,
    bgColor2: Color(0xFFF1F8E9),
    isResponseBubble: true,
  ),
];

const List<BubbleConfig> bottomBubbles = [
  BubbleConfig(
    id: 'consequences',
    label: 'The Consequences',
    subtitle: 'How the cycle continues',
    sectionTitle: 'The Loop',
    borderColor: Color(0xFF7CB342),
    bgColor1: Colors.white,
    bgColor2: Color(0xFFE8F5E9),
  ),
  BubbleConfig(
    id: 'superpowers',
    label: 'Your Superpowers',
    subtitle: 'Strengths to build on',
    sectionTitle: 'My Superpowers',
    borderColor: Color(0xFF2E7D32),
    bgColor1: Colors.white,
    bgColor2: Color(0xFFC8E6C9),
  ),
];

// ─── MAIN PAGE ───────────────────────────────────────────────────────────────

class CBTFormulationPage extends StatefulWidget {
  const CBTFormulationPage({super.key});

  @override
  State<CBTFormulationPage> createState() => _CBTFormulationPageState();
}

class _CBTFormulationPageState extends State<CBTFormulationPage>
    with TickerProviderStateMixin {
  final JourneyData _data = JourneyData();
  late AnimationController _wiggleController;

  // Dynamic options loaded from API (fall back to hardcoded constants)
  List<String> _apiNegativeBeliefs = negativeBeliefs;
  List<Map<String, dynamic>> _apiEmotions = emotions;
  List<String> _apiConsequenceOptions = consequenceOptions;

  // The formulation ID — set after the first API POST (draft creation)
  String? _formulationId;

  @override
  void initState() {
    super.initState();
    _wiggleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _loadOptions();
  }

  /// Fetches options from the API and creates a draft formulation to get an ID.
  Future<void> _loadOptions() async {
    final box = GetStorage();
    final token = box.read<String>('auth_token');
    if (token == null) return;

    try {
      final result = await CbtService.getOptions(token);
      if (result['success'] == true && result['data'] != null) {
        final data = result['data'] as Map<String, dynamic>;

        // Parse negativeBeliefs
        final rawBeliefs = data['negativeBeliefs'];
        if (rawBeliefs is List) {
          setState(() {
            _apiNegativeBeliefs = rawBeliefs.map((e) => e.toString()).toList();
          });
        }

        // Parse emotions — map to the same structure as the hardcoded list
        final rawEmotions = data['emotions'];
        if (rawEmotions is List) {
          final emotionColors = <String, List<Color>>{
            'Sad': [const Color(0xFF74B9FF), const Color(0xFF6C5CE7)],
            'Shocked': [const Color(0xFFFF6B6B), const Color(0xFFEE5A24)],
            'Angry': [const Color(0xFFFF6B6B), const Color(0xFFC0392B)],
            'Irritated': [const Color(0xFFE17055), const Color(0xFFD63031)],
            'Anxious': [const Color(0xFFA29BFE), const Color(0xFF6C5CE7)],
            'Panic': [const Color(0xFFFD79A8), const Color(0xFFE84393)],
            'Frightened': [const Color(0xFF636E72), const Color(0xFF2D3436)],
            'Stressed': [const Color(0xFFFDCB6E), const Color(0xFFF39C12)],
            'Scared': [const Color(0xFFDFE6E9), const Color(0xFFB2BEC3)],
            'Confused': [const Color(0xFFFD79A8), const Color(0xFFA29BFE)],
            'Guilty': [const Color(0xFF636E72), const Color(0xFF2D3436)],
            'Ashamed': [const Color(0xFFFAB1A0), const Color(0xFFE17055)],
            'Hurt': [const Color(0xFFFF7675), const Color(0xFFD63031)],
            'Grief': [const Color(0xFF95A5A6), const Color(0xFF7F8C8D)],
          };
          setState(() {
            _apiEmotions = rawEmotions.map((e) {
              final label = e.toString();
              final cols =
                  emotionColors[label] ??
                  [const Color(0xFF74B9FF), const Color(0xFF6C5CE7)];
              return <String, dynamic>{
                'label': label,
                'color1': cols[0],
                'color2': cols[1],
              };
            }).toList();
          });
        }

        // Parse consequence options
        final rawConsequences = data['consequenceOptions'];
        if (rawConsequences is List) {
          setState(() {
            _apiConsequenceOptions = rawConsequences
                .map((e) => e.toString())
                .toList();
          });
        }
      }
    } catch (e) {
      debugPrint('Failed to load CBT options: $e');
    }

    // --- NEW: Restore the most recent formulation into _data so they can resume ---
    try {
      final resList = await CbtService.getAllFormulations(token);
      if (resList['success'] == true && resList['data'] != null) {
        final dataList = resList['data'];
        if (dataList is List && dataList.isNotEmpty) {
          final latest = dataList.first;
          setState(() {
            _formulationId = latest['_id']?.toString();
            _data.recentHappening = latest['recentHappening']?.toString() ?? '';
            _data.triggers = latest['triggers']?.toString() ?? '';
            _data.thoughts = latest['thoughts']?.toString() ?? '';
            _data.behaviors = latest['behaviors']?.toString() ?? '';
            _data.childhood = latest['childhood']?.toString() ?? '';
            _data.rules = latest['rules']?.toString() ?? '';
            _data.superpowers = latest['superpowers']?.toString() ?? '';

            if (latest['feelings'] is List) {
              _data.feelings = (latest['feelings'] as List)
                  .map((e) => e.toString())
                  .toList();
            }
            if (latest['deepBeliefs'] is List) {
              _data.deepBeliefs = (latest['deepBeliefs'] as List)
                  .map((e) => e.toString())
                  .toList();
            }
            if (latest['consequences'] is List) {
              _data.consequences = (latest['consequences'] as List)
                  .map((e) => e.toString())
                  .toList();
            }
            _data.consequencesOther =
                latest['consequencesOther']?.toString() ?? '';
          });
        }
      } else {
        // Fallback: If network is offline, load from local storage
        final savedAnswers = box.read('cbt_answers');
        if (savedAnswers is Map) {
          setState(() {
            _data.childhood =
                savedAnswers['When I Was Little']?.toString() ?? '';
            _data.rules = savedAnswers['The Rules']?.toString() ?? '';
            _data.triggers = savedAnswers['Triggers']?.toString() ?? '';
            _data.recentHappening =
                savedAnswers['A Recent Happening']?.toString() ?? '';
            _data.thoughts = savedAnswers['My Thoughts']?.toString() ?? '';
            _data.behaviors = savedAnswers['What I Did']?.toString() ?? '';
            _data.superpowers =
                savedAnswers['Your Superpowers']?.toString() ?? '';

            if (savedAnswers['Deep-Down Beliefs'] != null &&
                savedAnswers['Deep-Down Beliefs'].toString().isNotEmpty) {
              _data.deepBeliefs = savedAnswers['Deep-Down Beliefs']
                  .toString()
                  .split(', ')
                  .toList();
            }
            if (savedAnswers['My Feelings'] != null &&
                savedAnswers['My Feelings'].toString().isNotEmpty) {
              _data.feelings = savedAnswers['My Feelings']
                  .toString()
                  .split(', ')
                  .toList();
            }
            if (savedAnswers['The Consequences'] != null &&
                savedAnswers['The Consequences'].toString().isNotEmpty) {
              _data.consequences = savedAnswers['The Consequences']
                  .toString()
                  .split(', ')
                  .toList();
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Failed to load existing draft: $e');
    }
  }

  @override
  void dispose() {
    _wiggleController.dispose();
    super.dispose();
  }

  String _getBubbleDisplay(String id) {
    switch (id) {
      case 'childhood':
        return _data.childhood;
      case 'deep-beliefs':
        return _data.deepBeliefs.join('; ');
      case 'rules':
        return _data.rules;
      case 'triggers':
        return _data.triggers;
      case 'recent-happening':
        return _data.recentHappening;
      case 'thoughts':
        return _data.thoughts;
      case 'feelings':
        return _data.feelings.join(', ');
      case 'behaviors':
        return _data.behaviors;
      case 'consequences':
        final all = [..._data.consequences];
        if (_data.consequencesOther.isNotEmpty)
          all.add(_data.consequencesOther);
        return all.join('; ');
      case 'superpowers':
        return _data.superpowers;
      default:
        return '';
    }
  }

  bool _isFilled(String id) => _getBubbleDisplay(id).isNotEmpty;

  void _openHelper(BubbleConfig config) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => HelperSheet(
        config: config,
        data: _data,
        currentDisplay: _getBubbleDisplay(config.id),
        formulationId: _formulationId,
        dynamicBeliefs: _apiNegativeBeliefs,
        dynamicEmotions: _apiEmotions,
        dynamicConsequences: _apiConsequenceOptions,
        onSaved: () {
          setState(() {});
          _triggerAutoSave();
        },
      ),
    );
  }

  void _saveFormulation() async {
    // Save to local storage using cbt_answers format that cbt.dart reads
    final box = GetStorage();
    final allConsequences = [..._data.consequences];
    if (_data.consequencesOther.isNotEmpty)
      allConsequences.add(_data.consequencesOther);

    final answers = <String, String>{
      'When I Was Little': _data.childhood,
      'Deep-Down Beliefs': _data.deepBeliefs.join(', '),
      'The Rules': _data.rules,
      'Triggers': _data.triggers,
      'A Recent Happening': _data.recentHappening,
      'My Thoughts': _data.thoughts,
      'My Feelings': _data.feelings.join(', '),
      'What I Did': _data.behaviors,
      'The Consequences': allConsequences.join(', '),
      'Your Superpowers': _data.superpowers,
    };

    // Remove empty values
    answers.removeWhere((key, value) => value.trim().isEmpty);

    box.write('cbt_answers', answers);

    // Save to backend — PUT if we already have a draft ID, otherwise POST
    try {
      final token = box.read<String>('auth_token');
      if (token != null) {
        final fullData = <String, dynamic>{
          'childhood': _data.childhood,
          'deepBeliefs': _data.deepBeliefs,
          'rules': _data.rules,
          'triggers': _data.triggers,
          'recentHappening': _data.recentHappening,
          'thoughts': _data.thoughts,
          'feelings': _data.feelings,
          'behaviors': _data.behaviors,
          'consequences': _data.consequences,
          'consequencesOther': _data.consequencesOther,
          'superpowers': _data.superpowers,
        };

        if (_formulationId != null) {
          // Update the draft that was pre-created on page open
          await CbtService.fullUpdate(token, _formulationId!, fullData);
        } else {
          // Fallback: create a new formulation
          await CbtService.saveCbt(
            token: token,
            recentHappening: _data.recentHappening.isNotEmpty
                ? _data.recentHappening
                : null,
            triggers: _data.triggers.isNotEmpty ? _data.triggers : null,
            thoughts: _data.thoughts.isNotEmpty ? _data.thoughts : null,
            feelings: _data.feelings.isNotEmpty ? _data.feelings : null,
            behaviors: _data.behaviors.isNotEmpty ? _data.behaviors : null,
            deepBeliefs: _data.deepBeliefs.isNotEmpty
                ? _data.deepBeliefs
                : null,
            childhood: _data.childhood.isNotEmpty ? _data.childhood : null,
            rules: _data.rules.isNotEmpty ? _data.rules : null,
            consequences: _data.consequences.isNotEmpty
                ? _data.consequences
                : null,
            consequencesOther: _data.consequencesOther.isNotEmpty
                ? _data.consequencesOther
                : null,
            superpowers: _data.superpowers.isNotEmpty
                ? _data.superpowers
                : null,
          );
        }
      }
    } catch (e) {
      debugPrint('Failed to save CBT to backend: $e');
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Your Journey Map has been saved! 🎉',
          style: TextStyle(fontFamily: 'Caveat', fontSize: 16),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 2),
      ),
    );

    await SessionCompletionService.markCompleted(2);

    // Navigate to Session 3 after brief delay
    Future.delayed(const Duration(seconds: 1), () {
      Get.to(() => const SessionThreePage(), arguments: Get.arguments);
    });
  }

  void _triggerAutoSave() async {
    // Auto-save to local storage and backend without UI feedback
    final box = GetStorage();
    final allConsequences = [..._data.consequences];
    if (_data.consequencesOther.isNotEmpty)
      allConsequences.add(_data.consequencesOther);

    final answers = <String, String>{
      'When I Was Little': _data.childhood,
      'Deep-Down Beliefs': _data.deepBeliefs.join(', '),
      'The Rules': _data.rules,
      'Triggers': _data.triggers,
      'A Recent Happening': _data.recentHappening,
      'My Thoughts': _data.thoughts,
      'My Feelings': _data.feelings.join(', '),
      'What I Did': _data.behaviors,
      'The Consequences': allConsequences.join(', '),
      'Your Superpowers': _data.superpowers,
    };

    // Remove empty values
    answers.removeWhere((key, value) => value.trim().isEmpty);

    box.write('cbt_answers', answers);

    // Save to backend
    try {
      final token = box.read<String>('auth_token');
      if (token != null) {
        final fullData = <String, dynamic>{
          'childhood': _data.childhood,
          'deepBeliefs': _data.deepBeliefs,
          'rules': _data.rules,
          'triggers': _data.triggers,
          'recentHappening': _data.recentHappening,
          'thoughts': _data.thoughts,
          'feelings': _data.feelings,
          'behaviors': _data.behaviors,
          'consequences': _data.consequences,
          'consequencesOther': _data.consequencesOther,
          'superpowers': _data.superpowers,
        };

        if (_formulationId != null) {
          await CbtService.fullUpdate(token, _formulationId!, fullData);
        } else {
          // Create a new draft
          final result = await CbtService.saveCbt(
            token: token,
            recentHappening: _data.recentHappening.isNotEmpty
                ? _data.recentHappening
                : null,
            triggers: _data.triggers.isNotEmpty ? _data.triggers : null,
            thoughts: _data.thoughts.isNotEmpty ? _data.thoughts : null,
            feelings: _data.feelings.isNotEmpty ? _data.feelings : null,
            behaviors: _data.behaviors.isNotEmpty ? _data.behaviors : null,
            deepBeliefs: _data.deepBeliefs.isNotEmpty
                ? _data.deepBeliefs
                : null,
            childhood: _data.childhood.isNotEmpty ? _data.childhood : null,
            rules: _data.rules.isNotEmpty ? _data.rules : null,
            consequences: _data.consequences.isNotEmpty
                ? _data.consequences
                : null,
            consequencesOther: _data.consequencesOther.isNotEmpty
                ? _data.consequencesOther
                : null,
            superpowers: _data.superpowers.isNotEmpty
                ? _data.superpowers
                : null,
          );
          if (result['success'] == true && result['data'] != null) {
            _formulationId = result['data']['_id']?.toString();
          }
        }
      }
    } catch (e) {
      debugPrint('Failed to auto-save CBT: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Stack(
        children: [
          _buildLinedBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 62, 20, 30),
              child: Column(
                children: [
                  _buildTitle(),
                  const SizedBox(height: 30),
                  // Main flow bubbles
                  ...mainBubbles.map(
                    (cfg) => Column(
                      children: [
                        _buildSectionLabel(cfg.sectionTitle),
                        const SizedBox(height: 12),
                        _buildMainBubble(cfg),
                        const SizedBox(height: 8),
                        _buildWavyArrow(),
                      ],
                    ),
                  ),
                  // Response section
                  _buildSectionLabel('How I React'),
                  const SizedBox(height: 12),
                  _buildResponseRow(),
                  const SizedBox(height: 12),
                  _buildCycleIndicator(),
                  _buildWavyArrow(),
                  // Bottom bubbles
                  ...bottomBubbles.map(
                    (cfg) => Column(
                      children: [
                        _buildSectionLabel(cfg.sectionTitle),
                        const SizedBox(height: 12),
                        _buildMainBubble(cfg),
                        if (cfg != bottomBubbles.last) ...[
                          const SizedBox(height: 8),
                          _buildWavyArrow(),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildSaveButton(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
          // Doodle decorations
          const DoodleDecorations(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 8, top: 8),
              child: Material(
                color: Colors.white.withOpacity(0.82),
                shape: const CircleBorder(),
                elevation: 2,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Color(0xFF2E7D32),
                  ),
                  tooltip: 'Back',
                  onPressed: () => Get.back(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinedBackground() {
    return CustomPaint(painter: LinedPaperPainter(), size: Size.infinite);
  }

  Widget _buildTitle() {
    return Text(
      'My CBT Formulation',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF2E7D32),
        fontFamily: 'Kalam',
        shadows: [
          Shadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(2, 2),
            blurRadius: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    if (label.isEmpty) return const SizedBox.shrink();
    return Transform.rotate(
      angle: -0.02,
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2E7D32),
          letterSpacing: 1.5,
          fontFamily: 'Kalam',
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildMainBubble(BubbleConfig cfg) {
    final filled = _isFilled(cfg.id);
    final display = _getBubbleDisplay(cfg.id);
    final isEven = mainBubbles.indexOf(cfg) % 2 == 1;

    return GestureDetector(
      onTap: () => _openHelper(cfg),
      child: Transform.rotate(
        angle: isEven ? 0.035 : -0.035,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 420),
          decoration: BoxDecoration(
            gradient: filled
                ? const LinearGradient(
                    colors: [Color(0xFFD4EDDA), Color(0xFFC3E6CB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: [cfg.bgColor1, cfg.bgColor2],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            border: Border.all(color: cfg.borderColor, width: 3),
            borderRadius: isEven
                ? const BorderRadius.only(
                    topLeft: Radius.circular(60),
                    topRight: Radius.circular(40),
                    bottomLeft: Radius.circular(60),
                    bottomRight: Radius.circular(40),
                  )
                : const BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(60),
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(50),
                  ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(4, 4),
                blurRadius: 0,
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              Text(
                cfg.label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2D3436),
                  fontFamily: 'Kalam',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                filled
                    ? (display.length > 50
                          ? '${display.substring(0, 47)}...'
                          : display)
                    : cfg.subtitle,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  color: filled
                      ? const Color(0xFF2D3436)
                      : const Color(0xFF636E72),
                  fontStyle: filled ? FontStyle.italic : FontStyle.normal,
                  fontWeight: filled ? FontWeight.w600 : FontWeight.normal,
                  fontFamily: 'Caveat',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResponseRow() {
    return Row(
      children: responseBubbles.asMap().entries.map((entry) {
        final i = entry.key;
        final cfg = entry.value;
        final filled = _isFilled(cfg.id);
        final display = _getBubbleDisplay(cfg.id);
        final angle = [-0.05, 0.05, -0.03][i];

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => _openHelper(cfg),
              child: Transform.rotate(
                angle: angle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    gradient: filled
                        ? const LinearGradient(
                            colors: [Color(0xFFD4EDDA), Color(0xFFC3E6CB)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : LinearGradient(
                            colors: [cfg.bgColor1, cfg.bgColor2],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    border: Border.all(color: cfg.borderColor, width: 3),
                    borderRadius: [
                      const BorderRadius.only(
                        topLeft: Radius.circular(55),
                        topRight: Radius.circular(45),
                        bottomLeft: Radius.circular(45),
                        bottomRight: Radius.circular(55),
                      ),
                      const BorderRadius.only(
                        topLeft: Radius.circular(45),
                        topRight: Radius.circular(55),
                        bottomLeft: Radius.circular(55),
                        bottomRight: Radius.circular(45),
                      ),
                      const BorderRadius.only(
                        topLeft: Radius.circular(50),
                        topRight: Radius.circular(50),
                        bottomLeft: Radius.circular(45),
                        bottomRight: Radius.circular(55),
                      ),
                    ][i],
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        offset: const Offset(3, 3),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 16,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        cfg.label,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2D3436),
                          fontFamily: 'Kalam',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        filled
                            ? (display.length > 25
                                  ? '${display.substring(0, 22)}...'
                                  : display)
                            : cfg.subtitle,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: filled
                              ? const Color(0xFF2D3436)
                              : const Color(0xFF636E72),
                          fontStyle: filled
                              ? FontStyle.italic
                              : FontStyle.normal,
                          fontWeight: filled
                              ? FontWeight.w600
                              : FontWeight.normal,
                          fontFamily: 'Caveat',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCycleIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        '↻  goes round and round  ↺',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          color: const Color(0xFFA29BFE).withOpacity(0.7),
          fontFamily: 'Caveat',
        ),
      ),
    );
  }

  Widget _buildWavyArrow() {
    return SizedBox(
      height: 40,
      child: CustomPaint(
        painter: WavyArrowPainter(color: const Color(0xFF4CAF50)),
        size: const Size(60, 40),
      ),
    );
  }

  Widget _buildSaveButton() {
    final canSave = _data.isMinimallyComplete;
    return Column(
      children: [
        Divider(
          color: const Color(0xFF81C784),
          thickness: 2,
          indent: 20,
          endIndent: 20,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: canSave ? _saveFormulation : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: canSave
                ? const Color(0xFF4CAF50)
                : Colors.grey.shade400,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: canSave ? 4 : 0,
          ),
          child: const Text(
            'Save My Journey Map to Dashboard',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: 'Kalam',
            ),
          ),
        ),
        if (!canSave) ...[
          const SizedBox(height: 8),
          Text(
            'Fill in Recent Happening, Thoughts, Feelings & Behaviors to save',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade500,
              fontFamily: 'Caveat',
            ),
          ),
        ],
      ],
    );
  }
}

// ─── HELPER BOTTOM SHEET ─────────────────────────────────────────────────────

class HelperSheet extends StatefulWidget {
  final BubbleConfig config;
  final JourneyData data;
  final String currentDisplay;
  final VoidCallback onSaved;
  final String? formulationId;
  final List<String> dynamicBeliefs;
  final List<Map<String, dynamic>> dynamicEmotions;
  final List<String> dynamicConsequences;

  const HelperSheet({
    super.key,
    required this.config,
    required this.data,
    required this.currentDisplay,
    required this.onSaved,
    this.formulationId,
    this.dynamicBeliefs = negativeBeliefs,
    this.dynamicEmotions = emotions,
    this.dynamicConsequences = consequenceOptions,
  });

  @override
  State<HelperSheet> createState() => _HelperSheetState();
}

class _HelperSheetState extends State<HelperSheet> {
  late TextEditingController _textController;
  late List<String> _selectedEmotions;
  late List<String> _selectedBeliefs;
  late List<String> _selectedConsequences;
  late TextEditingController _otherController;

  @override
  void initState() {
    super.initState();
    _selectedEmotions = List.from(widget.data.feelings);
    _selectedBeliefs = List.from(widget.data.deepBeliefs);
    _selectedConsequences = List.from(widget.data.consequences);
    _otherController = TextEditingController(
      text: widget.data.consequencesOther,
    );

    final id = widget.config.id;
    String initial = '';
    switch (id) {
      case 'childhood':
        initial = widget.data.childhood;
        break;
      case 'rules':
        initial = widget.data.rules;
        break;
      case 'triggers':
        initial = widget.data.triggers;
        break;
      case 'recent-happening':
        initial = widget.data.recentHappening;
        break;
      case 'thoughts':
        initial = widget.data.thoughts;
        break;
      case 'behaviors':
        initial = widget.data.behaviors;
        break;
      case 'superpowers':
        initial = widget.data.superpowers;
        break;
    }
    _textController = TextEditingController(text: initial);
  }

  @override
  void dispose() {
    _textController.dispose();
    _otherController.dispose();
    super.dispose();
  }

  Map<String, dynamic> get _helperInfo {
    switch (widget.config.id) {
      case 'recent-happening':
        return {
          'title': 'A Recent Happening',
          'intro':
              'Write the situation where you last felt the feeling as to why you are here today. We want an actual situation that happened.',
          'example':
              'Examples:\n• "I had an argument with my partner"\n• "I had feedback from my boss"\n• "I tried to go to work"',
          'type': 'text',
        };
      case 'triggers':
        return {
          'title': 'Triggers',
          'intro':
              'What has happened over the years that maybe has triggered how you are feeling?',
          'questions': [
            'Was there a specific event, person, or place involved?',
            'Have similar situations triggered you before?',
          ],
          'example':
              'Example: "Being criticised", "Grandma passed", "Being attacked"',
          'type': 'text',
        };
      case 'thoughts':
        return {
          'title': 'My Thoughts - in the brain',
          'intro': '',
          'questions': [
            'What was the first thought that popped into your head?',
            'What were you telling yourself about the situation?',
            'What did you think it meant about you or others?',
          ],
          'example':
              'Examples: "They don\'t respect me" or "I always mess things up"',
          'type': 'text',
        };
      case 'feelings':
        return {
          'title': 'My Feelings - in the body',
          'intro':
              'How did this situation make you feel? Select all emotions you experienced:',
          'type': 'emotions',
        };
      case 'behaviors':
        return {
          'title': 'What I Did (Behaviours)',
          'intro': '',
          'questions': [
            'What did you do immediately after or in the moment?',
            'Did you avoid anything or anyone?',
            'How did you cope with these feelings?',
          ],
          'example': 'Example: "I walked away" or "I went quiet and withdrew"',
          'type': 'text',
        };
      case 'deep-beliefs':
        return {
          'title': 'My deep-down negative beliefs',
          'intro':
              'These are deep beliefs about yourself. Choose all that apply:',
          'type': 'beliefs',
        };
      case 'childhood':
        return {
          'title': 'When I was little (Childhood)',
          'intro':
              'Float back in time and see if you remember feeling this way as a child.',
          'questions': [
            'Were there specific events or patterns in your family?',
            'What messages did you receive about yourself growing up?',
          ],
          'example':
              'Example: "My parents were very critical" or "I had to be perfect to get attention"',
          'type': 'text',
        };
      case 'rules':
        return {
          'title': 'The Rules',
          'intro': '',
          'questions': [
            'What "shoulds" or "musts" do you tell yourself?',
            'What do you believe you need to do to be accepted or safe?',
          ],
          'example':
              'Example: "I must never show weakness" or "I should always put others first"',
          'type': 'text',
        };
      case 'consequences':
        return {
          'title': 'The Consequences',
          'intro':
              'What are the consequences of the stuck loop you are in? Select all that apply:',
          'type': 'consequences',
        };
      case 'superpowers':
        return {
          'title': 'Your Superpowers',
          'intro':
              'What are your superpowers? What makes you strong, resilient, and able to carry on?',
          'example':
              'Examples: kindness, warmth, intelligence, being a good friend, determination',
          'type': 'text',
        };
      default:
        return {'title': '', 'type': 'text'};
    }
  }

  void _save() {
    final id = widget.config.id;
    final info = _helperInfo;

    switch (info['type']) {
      case 'emotions':
        widget.data.feelings = List.from(_selectedEmotions);
        break;
      case 'beliefs':
        widget.data.deepBeliefs = List.from(_selectedBeliefs);
        break;
      case 'consequences':
        widget.data.consequences = List.from(_selectedConsequences);
        widget.data.consequencesOther = _otherController.text.trim();
        break;
      default:
        final text = _textController.text.trim();
        switch (id) {
          case 'childhood':
            widget.data.childhood = text;
            break;
          case 'rules':
            widget.data.rules = text;
            break;
          case 'triggers':
            widget.data.triggers = text;
            break;
          case 'recent-happening':
            widget.data.recentHappening = text;
            break;
          case 'thoughts':
            widget.data.thoughts = text;
            break;
          case 'behaviors':
            widget.data.behaviors = text;
            break;
          case 'superpowers':
            widget.data.superpowers = text;
            break;
        }
    }

    widget.onSaved();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final info = _helperInfo;
    final screenH = MediaQuery.of(context).size.height;

    return Container(
      height: screenH * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    info['title'] as String,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2E7D32),
                      fontFamily: 'Kalam',
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.close,
                    color: Color(0xFF81C784),
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
          Divider(color: Colors.grey.shade200, height: 1),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildContent(info),
            ),
          ),
          // Buttons
          Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              10,
              20,
              MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF43A047),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Save & Continue',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Kalam',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF81C784), width: 2),
                    foregroundColor: const Color(0xFF2E7D32),
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Skip',
                    style: TextStyle(fontSize: 16, fontFamily: 'Kalam'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(Map<String, dynamic> info) {
    final type = info['type'] as String;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if ((info['intro'] as String? ?? '').isNotEmpty) ...[
          Text(
            info['intro'] as String,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF2D3436),
              height: 1.5,
              fontFamily: 'Caveat',
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (info.containsKey('questions')) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: (info['questions'] as List<String>)
                  .map(
                    (q) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '• ',
                            style: TextStyle(
                              fontSize: 15,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              q,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Color(0xFF636E72),
                                fontFamily: 'Caveat',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (info.containsKey('example')) ...[
          Text(
            info['example'] as String,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF636E72),
              fontStyle: FontStyle.italic,
              fontFamily: 'Caveat',
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (type == 'text') _buildTextInput(),
        if (type == 'emotions') _buildEmotionGrid(),
        if (type == 'beliefs') _buildBeliefsList(),
        if (type == 'consequences') _buildConsequencesList(),
      ],
    );
  }

  Widget _buildTextInput() {
    return TextField(
      controller: _textController,
      maxLines: 5,
      style: const TextStyle(fontSize: 16, fontFamily: 'Caveat'),
      decoration: InputDecoration(
        hintText: 'Write your answer here...',
        hintStyle: const TextStyle(color: Colors.grey, fontFamily: 'Caveat'),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF81C784), width: 2),
        ),
        contentPadding: const EdgeInsets.all(14),
      ),
    );
  }

  Widget _buildEmotionGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.85,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: widget.dynamicEmotions.length,
      itemBuilder: (_, i) {
        final emotion = widget.dynamicEmotions[i];
        final label = emotion['label'] as String;
        final isSelected = _selectedEmotions.contains(label);

        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedEmotions.remove(label);
              } else {
                _selectedEmotions.add(label);
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFE0F7F5) : Colors.white,
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF4ECDC4)
                    : Colors.transparent,
                width: 3,
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        emotion['color1'] as Color,
                        emotion['color2'] as Color,
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: const Color(0xFF2D3436),
                    fontWeight: isSelected
                        ? FontWeight.w700
                        : FontWeight.normal,
                    fontFamily: 'Caveat',
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBeliefsList() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: widget.dynamicBeliefs.map((belief) {
          final isSelected = _selectedBeliefs.contains(belief);
          return InkWell(
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedBeliefs.remove(belief);
                } else {
                  _selectedBeliefs.add(belief);
                }
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Checkbox(
                    value: isSelected,
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          _selectedBeliefs.add(belief);
                        } else {
                          _selectedBeliefs.remove(belief);
                        }
                      });
                    },
                    activeColor: const Color(0xFF2E7D32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      belief,
                      style: TextStyle(
                        fontSize: 15,
                        fontFamily: 'Caveat',
                        color: isSelected
                            ? const Color(0xFF2E7D32)
                            : const Color(0xFF2D3436),
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildConsequencesList() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: widget.dynamicConsequences.map((c) {
              final isSelected = _selectedConsequences.contains(c);
              return InkWell(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedConsequences.remove(c);
                    } else {
                      _selectedConsequences.add(c);
                    }
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Checkbox(
                        value: isSelected,
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              _selectedConsequences.add(c);
                            } else {
                              _selectedConsequences.remove(c);
                            }
                          });
                        },
                        activeColor: const Color(0xFF2E7D32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          c,
                          style: TextStyle(
                            fontSize: 15,
                            fontFamily: 'Caveat',
                            color: isSelected
                                ? const Color(0xFF2E7D32)
                                : const Color(0xFF2D3436),
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _otherController,
          maxLines: 3,
          style: const TextStyle(fontSize: 15, fontFamily: 'Caveat'),
          decoration: InputDecoration(
            labelText: 'Other (add your own)',
            labelStyle: const TextStyle(
              fontFamily: 'Caveat',
              color: Color(0xFF81C784),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF81C784), width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── CUSTOM PAINTERS ─────────────────────────────────────────────────────────

class LinedPaperPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE8E8E8)
      ..strokeWidth = 1;

    double y = 29;
    while (y < size.height) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      y += 29;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class WavyArrowPainter extends CustomPainter {
  final Color color;
  WavyArrowPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.6)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;
    final path = Path();
    path.moveTo(cx, 5);
    path.quadraticBezierTo(cx + 10, 15, cx, 25);
    path.quadraticBezierTo(cx - 10, 32, cx, size.height - 5);
    canvas.drawPath(path, paint);

    // Arrow head
    final arrowPaint = Paint()
      ..color = color.withOpacity(0.6)
      ..style = PaintingStyle.fill;
    final arrowPath = Path();
    final bottom = size.height - 5;
    arrowPath.moveTo(cx - 5, bottom - 5);
    arrowPath.lineTo(cx, bottom);
    arrowPath.lineTo(cx + 5, bottom - 5);
    arrowPath.close();
    canvas.drawPath(arrowPath, arrowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── DOODLE DECORATIONS ──────────────────────────────────────────────────────

class DoodleDecorations extends StatelessWidget {
  const DoodleDecorations({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildStar(top: 70, left: 20, angle: 0.26),
        _buildStar(top: 320, right: 15, angle: -0.35),
        _buildStar(bottom: 200, left: 25, angle: 0.78),
        _buildHeart(top: 480, left: 15),
        _buildHeart(bottom: 350, right: 20, angle: 0.52),
        _buildSpiral(top: 220, left: 10),
        _buildSpiral(bottom: 150, right: 10),
      ],
    );
  }

  Widget _buildStar({
    double? top,
    double? left,
    double? right,
    double? bottom,
    double angle = 0,
  }) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: Transform.rotate(
        angle: angle,
        child: Opacity(
          opacity: 0.3,
          child: CustomPaint(size: const Size(28, 28), painter: StarPainter()),
        ),
      ),
    );
  }

  Widget _buildHeart({
    double? top,
    double? left,
    double? right,
    double? bottom,
    double angle = 0,
  }) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: Transform.rotate(
        angle: angle,
        child: Opacity(
          opacity: 0.3,
          child: CustomPaint(size: const Size(24, 24), painter: HeartPainter()),
        ),
      ),
    );
  }

  Widget _buildSpiral({
    double? top,
    double? left,
    double? right,
    double? bottom,
  }) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: Opacity(
        opacity: 0.25,
        child: CustomPaint(size: const Size(36, 36), painter: SpiralPainter()),
      ),
    );
  }
}

class StarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final outer = i * 4 * math.pi / 5 - math.pi / 2;
      final inner = outer + 2 * math.pi / 5;
      final ox = cx + cx * math.cos(outer);
      final oy = cy + cy * math.sin(outer);
      final ix = cx + cx * 0.4 * math.cos(inner);
      final iy = cy + cy * 0.4 * math.sin(inner);
      if (i == 0) {
        path.moveTo(ox, oy);
      } else {
        path.lineTo(ox, oy);
      }
      path.lineTo(ix, iy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class HeartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFF69B4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;
    final path = Path();
    path.moveTo(w / 2, h * 0.85);
    path.cubicTo(w * 0.1, h * 0.6, -w * 0.1, h * 0.3, w / 2, h * 0.25);
    path.cubicTo(w * 1.1, h * 0.3, w * 0.9, h * 0.6, w / 2, h * 0.85);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SpiralPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF6A5ACD)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final cx = size.width / 2;
    final cy = size.height / 2;
    path.moveTo(cx, cy);
    for (double angle = 0; angle < 4 * math.pi; angle += 0.1) {
      final r = angle * (size.width / 2) / (4 * math.pi);
      path.lineTo(cx + r * math.cos(angle), cy + r * math.sin(angle));
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
