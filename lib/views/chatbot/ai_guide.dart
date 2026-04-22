import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

// ─── Replace with your actual AppText widget import ───
// import 'package:yourapp/utils/app_text.dart';

// ─── Temporary AppText shim (remove if you have your own) ───
class AppText extends StatelessWidget {
  final String text;
  final double? fontSize;
  final Color? color;
  final FontWeight? fontWeight;
  const AppText(this.text,
      {super.key, this.fontSize, this.color, this.fontWeight});
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
        fontSize: fontSize, color: color, fontWeight: fontWeight),
  );
}
// ─────────────────────────────────────────────────────────────

// ══════════════════════════════════════════════════════════════
//  DATA MODELS
// ══════════════════════════════════════════════════════════════

class BeliefPair {
  final String negative;
  final String positive;
  BeliefPair({required this.negative, required this.positive});
  Map<String, dynamic> toMap() => {'negative': negative, 'positive': positive};
}

// ══════════════════════════════════════════════════════════════
//  BELIEFS DATA
// ══════════════════════════════════════════════════════════════

const Map<String, List<String>> kNegativeBeliefs = {
  "RESPONSIBILITY – I AM SOMETHING 'WRONG'": [
    "I don't deserve love",
    "I am a bad person",
    "I am terrible",
    "I am worthless (inadequate)",
    "I am shameful",
    "I am not lovable",
    "I am not good enough",
    "I deserve only bad things",
    "I am permanently damaged",
    "I am ugly (my body is hateful)",
    "I am stupid (not smart enough)",
    "I am insignificant (unimportant)",
    "I am a disappointment",
    "I deserve to die",
    "I deserve to be miserable",
    "I am different (don't belong)",
  ],
  "RESPONSIBILITY – I DID SOMETHING 'WRONG'": [
    "I should have done something",
    "I did something wrong",
    "I should have known better",
  ],
  "SAFETY / VULNERABILITY": [
    "I cannot be trusted",
    "I cannot trust myself",
    "I cannot trust my judgment",
    "I cannot trust anyone",
    "I cannot protect myself",
    "I am in danger",
    "It's not okay to feel (show) my emotions",
    "I cannot stand up for myself",
    "I cannot let it out",
  ],
  "CONTROL / CHOICE": [
    "I am not in control",
    "I am powerless (helpless)",
    "I am weak",
    "I cannot get what I want",
    "I am a failure (will fail)",
    "I cannot succeed",
    "I have to be perfect (please everyone)",
    "I cannot stand it",
    "I am inadequate",
  ],
};

const Map<String, List<String>> kPositiveBeliefs = {
  "RESPONSIBILITY – I AM SOMETHING 'RIGHT'": [
    "I deserve love; I can have love",
    "I am a good (loving) person",
    "I am fine as I am",
    "I am worthy; I am worthwhile",
    "I am honorable",
    "I am lovable",
    "I am deserving (fine/okay)",
    "I deserve good things",
    "I am (can be) healthy",
    "I am fine (attractive/lovable)",
    "I am intelligent (able to learn)",
    "I am significant (important)",
    "I am okay just the way I am",
    "I deserve to live",
    "I deserve to be happy",
  ],
  "RESPONSIBILITY – I DID THE BEST I COULD": [
    "I did the best I could",
    "I learned (can learn) from it",
    "I do the best I can (I can learn)",
  ],
  "SAFETY / TRUST": [
    "I can be trusted",
    "I can (learn to) trust myself",
    "I can trust my judgment",
    "I can choose whom to trust",
    "I can (learn to) take care of myself",
    "It's over; I am safe now",
    "I can safely feel (show) my emotions",
    "I can make my needs known",
    "I can choose to let it out",
  ],
  "CONTROL / CHOICE": [
    "I am now in control",
    "I now have choices",
    "I am strong",
    "I can get what I want",
    "I can succeed",
    "I can be myself (make mistakes)",
    "I can handle it",
    "I am capable",
  ],
};

// ══════════════════════════════════════════════════════════════
//  QUESTION FLOWS
// ══════════════════════════════════════════════════════════════

const Map<String, List<String>> kQuestionFlows = {
  'memory': [
    "Can you describe the memory or event you'd like to work with? Take your time and share as much or as little as feels comfortable.",
    "When you think of this memory, try to 'freeze frame' the most difficult or disturbing moment. What do you see, hear?",
    '__NEGATIVE_BELIEFS__',
    '__POSITIVE_BELIEFS__',
    '__VOC_RATING__',
    "What emotions are you noticing as you think about this memory? (e.g., sad, frightened, angry, ashamed)",
    "Are there other emotions that come along with the main one?",
    "Where do you feel these emotions in your body?",
    '__SUD_RATING__',
  ],
  'future': [
    "Can you describe the future scenario or worst-case situation you're imagining?",
    "If you had to pick one 'freeze frame' moment from this scenario – the worst part – what would that look like?",
    '__NEGATIVE_BELIEFS__',
    '__POSITIVE_BELIEFS__',
    '__VOC_RATING__',
    "What emotions come up when you imagine this future scenario?",
    "Are there other emotions that come along with the main one?",
    "Where do you notice these feelings in your body?",
    '__SUD_RATING__',
  ],
  'words': [
    "What are the words or thoughts that keep running through your mind?",
    "Can you think of a specific situation where these words feel especially true or painful? Freeze frame that moment.",
    '__NEGATIVE_BELIEFS__',
    '__POSITIVE_BELIEFS__',
    '__VOC_RATING__',
    "What emotions arise when these words run through your mind?",
    "Are there other emotions that come along with the main one?",
    "Where do you feel this in your body?",
    '__SUD_RATING__',
  ],
  'negative': [
    "What difficult emotion are you experiencing that you'd like to work with?",
    "Can you recall a specific time when you felt this emotion very intensely? Freeze frame that moment.",
    '__NEGATIVE_BELIEFS__',
    '__POSITIVE_BELIEFS__',
    '__VOC_RATING__',
    "Are there other emotions that come along with the main one?",
    "Where do you notice these emotions in your body?",
    '__SUD_RATING__',
  ],
  'addiction': [
    "What aspect of this addictive behavior has the most intense feeling? (e.g., the rush, the anticipation, the first time)",
    "What is the specific positive feeling? (e.g., relaxed, excited, euphoric, powerful, free, numb)",
    '__PFS_RATING__',
    "Are there any thoughts that go with this positive feeling? What does your mind tell you?",
    "Where does this positive feeling sit in your body?",
    "What color, shape, or image comes to mind when you focus on this feeling?",
    '__BLS_INSTRUCTION__',
  ],
};

// Suggested opposites map
const Map<String, String> kSuggestedOpposites = {
  "I am not good enough": "I am good enough",
  "I am not lovable": "I am lovable",
  "I don't deserve love": "I deserve love; I can have love",
  "I am worthless (inadequate)": "I am worthy; I am worthwhile",
  "I am powerless (helpless)": "I now have choices",
  "I am weak": "I am strong",
  "I cannot succeed": "I can succeed",
  "I am a bad person": "I am a good (loving) person",
  "I cannot trust myself": "I can (learn to) trust myself",
  "I am not in control": "I am now in control",
  "I am in danger": "It's over; I am safe now",
  "I am stupid (not smart enough)": "I am intelligent (able to learn)",
  "I am permanently damaged": "I am (can be) healthy",
  "I deserve to die": "I deserve to live",
  "I am a failure (will fail)": "I can succeed",
  "I cannot protect myself": "I can (learn to) take care of myself",
  "I should have done something": "I did the best I could",
  "I did something wrong": "I learned (can learn) from it",
};

// ══════════════════════════════════════════════════════════════
//  CHAT MESSAGE MODEL
// ══════════════════════════════════════════════════════════════

enum MessageType { bot, user, widget }

class ChatMessage {
  final MessageType type;
  final String text;
  ChatMessage({required this.type, required this.text});
}

// ══════════════════════════════════════════════════════════════
//  MAIN PAGE
// ══════════════════════════════════════════════════════════════

class EmdrCompanionPage extends StatefulWidget {
  const EmdrCompanionPage({super.key});

  @override
  State<EmdrCompanionPage> createState() => _EmdrCompanionPageState();
}

class _EmdrCompanionPageState extends State<EmdrCompanionPage> {
  final box = GetStorage();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  // Chat state
  final List<ChatMessage> _messages = [];
  bool _showInput = false;
  bool _showStartingOptions = true;

  // Flow state
  List<String>? _currentFlow;
  int _currentStep = 0;
  final List<dynamic> _responses = [];

  // Belief state
  List<String> _selectedNegativeBeliefs = [];
  List<String> _selectedPositiveBeliefs = [];
  int _negativeBeliefIndex = 0;
  final List<BeliefPair> _beliefPairs = [];

  // Rating state
  int? _selectedRating;

  // UI state enum
  _UIState _uiState = _UIState.startOptions;

  @override
  void initState() {
    super.initState();
    _addBotMessage(
        "Where would you like to start? Do you have a clear memory of an event, an image of a future worst-case scenario, words running through your mind, a difficult emotion, or an addiction/craving?");
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _inputController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────

  void _addBotMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(type: MessageType.bot, text: text));
    });
    _scrollToBottom();
  }

  void _addUserMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(type: MessageType.user, text: text));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 200,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      }
    });
  }

  bool get _isAddictionFlow =>
      _responses.isNotEmpty &&
          _responses[0].toString().contains('Addiction');

  // ── Starting choice ────────────────────────────────────────

  void _handleStartingChoice(String choice) {
    String label;
    switch (choice) {
      case 'memory':
        label = 'Memory / Past Event';
        break;
      case 'future':
        label = 'Future Scenario';
        break;
      case 'words':
        label = 'Words / Thoughts';
        break;
      case 'negative':
        label = 'Difficult Emotions';
        break;
      case 'addiction':
        label = 'Addiction / Craving';
        break;
      default:
        label = choice;
    }

    _addUserMessage(label);
    _responses.add('Starting point: $label');

    _currentFlow = kQuestionFlows[choice];
    _currentStep = 0;

    setState(() {
      _showStartingOptions = false;
      _uiState = _UIState.chat;
    });

    Future.delayed(const Duration(milliseconds: 700), _askNext);
  }

  // ── Main flow logic ────────────────────────────────────────

  void _askNext() {
    if (_currentFlow == null || _currentStep >= _currentFlow!.length) {
      _finishSession();
      return;
    }

    final question = _currentFlow![_currentStep];

    if (question == '__NEGATIVE_BELIEFS__') {
      if (_isAddictionFlow) {
        _currentStep++;
        _askNext();
        return;
      }
      _selectedNegativeBeliefs = [];
      _negativeBeliefIndex = 0;
      _beliefPairs.clear();
      _addBotMessage(
          'What negative belief about yourself comes up when you hold that freeze frame?');
      setState(() => _uiState = _UIState.negativeBeliefs);
    } else if (question == '__POSITIVE_BELIEFS__') {
      if (_isAddictionFlow) {
        _currentStep++;
        _askNext();
        return;
      }
      _addBotMessage(
          'What would you prefer to believe about yourself in that situation instead?');
      setState(() => _uiState = _UIState.positiveBeliefs);
    } else if (question == '__VOC_RATING__') {
      if (_isAddictionFlow) {
        _currentStep++;
        _askNext();
        return;
      }
      setState(() => _uiState = _UIState.vocRating);
      _scrollToBottom();
    } else if (question == '__SUD_RATING__') {
      if (_isAddictionFlow) {
        _currentStep++;
        _askNext();
        return;
      }
      setState(() => _uiState = _UIState.sudRating);
      _scrollToBottom();
    } else if (question == '__PFS_RATING__') {
      setState(() => _uiState = _UIState.pfsRating);
      _scrollToBottom();
    } else if (question == '__BLS_INSTRUCTION__') {
      _addBotMessage(
          'Great. Now we\'ll begin bilateral stimulation (BLS) to process this positive feeling. Continue with BLS until the Positive Feeling Scale reaches 0 or 1.\n\nRemember: The goal is to reduce the intensity of the pleasurable feeling associated with the addictive behavior, not to eliminate all positive feelings in your life.');
      setState(() {
        _uiState = _UIState.done;
        _showInput = false;
      });
      Future.delayed(const Duration(milliseconds: 2000), _finishSession);
    } else {
      _addBotMessage(question);
      setState(() {
        _uiState = _UIState.chat;
        _showInput = true;
      });
      Future.delayed(
          const Duration(milliseconds: 300), () => _focusNode.requestFocus());
    }
  }

  void _submitTextAnswer() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    _addUserMessage(text);
    _responses.add(text);
    _inputController.clear();
    _currentStep++;
    setState(() => _showInput = false);
    Future.delayed(const Duration(milliseconds: 700), _askNext);
  }

  void _finishSession() {
    setState(() {
      _uiState = _UIState.summary;
      _showInput = false;
    });
    _saveSummary();
    _scrollToBottom();
  }

  void _saveSummary() {
    final sessionData = {
      'date': DateTime.now().toIso8601String(),
      'startingPoint': _responses.isNotEmpty ? _responses[0] : '',
      'beliefPairs': _beliefPairs.map((p) => p.toMap()).toList(),
      'responses': _responses.map((r) => r.toString()).toList(),
    };
    List sessions = box.read('emdrSessions') ?? [];
    sessions.add(sessionData);
    box.write('emdrSessions', sessions);
    box.write('lastEMDRSession', sessionData);
  }

  // ── Belief selection submit ────────────────────────────────

  void _submitNegativeBeliefs(List<String> selected) {
    _selectedNegativeBeliefs = selected;
    _addUserMessage('Selected: ${selected.join(', ')}');
    _responses.add('Negative beliefs: ${selected.join(', ')}');
    _currentStep++;
    setState(() => _uiState = _UIState.chat);
    Future.delayed(const Duration(milliseconds: 700), _askNext);
  }

  void _submitPositiveBelief(String belief) {
    _beliefPairs.add(BeliefPair(
      negative: _selectedNegativeBeliefs[_negativeBeliefIndex],
      positive: belief,
    ));
    _addUserMessage(
        'For "${_selectedNegativeBeliefs[_negativeBeliefIndex]}", I choose: "$belief"');
    _negativeBeliefIndex++;

    if (_negativeBeliefIndex < _selectedNegativeBeliefs.length) {
      _addBotMessage(
          'Now, what would you prefer to believe about yourself instead of the next negative belief?');
      setState(() => _uiState = _UIState.positiveBeliefs);
    } else {
      _selectedPositiveBeliefs = _beliefPairs.map((p) => p.positive).toList();
      _responses.add(
          'Positive beliefs: ${_selectedPositiveBeliefs.join(', ')}');
      _currentStep++;
      setState(() => _uiState = _UIState.chat);
      Future.delayed(const Duration(milliseconds: 700), _askNext);
    }
  }

  void _submitRating(String type, int value) {
    String label;
    if (type == 'voc') {
      label = 'VoC Rating: $value / 7';
    } else if (type == 'sud') {
      label = 'SUD Rating: $value / 10';
    } else {
      label = 'Positive Feeling Scale: $value / 10';
    }
    _addUserMessage(label);
    _responses.add(value);
    _selectedRating = null;
    _currentStep++;
    setState(() => _uiState = _UIState.chat);
    Future.delayed(const Duration(milliseconds: 700), _askNext);
  }

  // ══════════════════════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background image top
          Positioned(
            top: 0, left: 0, right: 0, height: 150,
            child: Image.asset('assets/images/my_emdr.png', fit: BoxFit.fill),
          ),
          Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: Stack(
                  children: [
                    // Background
                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(35),
                            topRight: Radius.circular(35),
                          ),
                          image: DecorationImage(
                            image: AssetImage('assets/images/chatbot_bg.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    // Chat list
                    Positioned.fill(
                      child: ListView(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: 24,
                          bottom: _showInput ? 160 : 100,
                        ),
                        children: [
                          ..._messages.map((m) => _buildMessageBubble(m)),
                          // Inline UI widgets based on state
                          if (_uiState == _UIState.startOptions)
                            _StartingOptionsWidget(
                              onChoose: _handleStartingChoice,
                            ),
                          if (_uiState == _UIState.negativeBeliefs)
                            _BeliefSelectionWidget(
                              type: 'negative',
                              beliefs: kNegativeBeliefs,
                              onSubmit: (sel) => _submitNegativeBeliefs(sel),
                            ),
                          if (_uiState == _UIState.positiveBeliefs)
                            _BeliefSelectionWidget(
                              type: 'positive',
                              beliefs: kPositiveBeliefs,
                              currentNegative:
                              _negativeBeliefIndex <
                                  _selectedNegativeBeliefs.length
                                  ? _selectedNegativeBeliefs[
                              _negativeBeliefIndex]
                                  : null,
                              onSubmitSingle: (s) => _submitPositiveBelief(s),
                            ),
                          if (_uiState == _UIState.vocRating)
                            _RatingScaleWidget(
                              type: 'voc',
                              positiveBeliefs: _selectedPositiveBeliefs,
                              negativeBeliefs: _selectedNegativeBeliefs,
                              onSubmit: (v) => _submitRating('voc', v),
                            ),
                          if (_uiState == _UIState.sudRating)
                            _RatingScaleWidget(
                              type: 'sud',
                              positiveBeliefs: _selectedPositiveBeliefs,
                              negativeBeliefs: _selectedNegativeBeliefs,
                              onSubmit: (v) => _submitRating('sud', v),
                            ),
                          if (_uiState == _UIState.pfsRating)
                            _RatingScaleWidget(
                              type: 'pfs',
                              positiveBeliefs: const [],
                              negativeBeliefs: const [],
                              onSubmit: (v) => _submitRating('pfs', v),
                            ),
                          if (_uiState == _UIState.summary)
                            _SummaryWidget(
                              responses: _responses,
                              beliefPairs: _beliefPairs,
                              isAddiction: _isAddictionFlow,
                            ),
                        ],
                      ),
                    ),
                    // Input bar
                    if (_showInput && _uiState == _UIState.chat)
                      Positioned(
                        bottom: 0, left: 0, right: 0,
                        child: _buildInputBar(context),
                      ),
                    // Done button
                    if (_uiState == _UIState.summary)
                      Positioned(
                        bottom: 0, left: 0, right: 0,
                        child: _buildDoneBar(context),
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

  Widget _buildMessageBubble(ChatMessage msg) {
    final isBot = msg.type == MessageType.bot;
    return Align(
      alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints:
        BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isBot ? 4 : 20),
            bottomRight: Radius.circular(isBot ? 20 : 4),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isBot
                    ? Colors.white.withOpacity(0.75)
                    : const Color(0xFF537E5D).withOpacity(0.9),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isBot)
                    Row(children: [
                      const Icon(Icons.spa_outlined,
                          size: 13, color: Color(0xFF537E5D)),
                      const SizedBox(width: 4),
                      AppText('EMDR Companion',
                          fontSize: 11,
                          color: const Color(0xFF537E5D),
                          fontWeight: FontWeight.w600),
                    ]),
                  if (isBot) const SizedBox(height: 5),
                  AppText(msg.text,
                      fontSize: 14,
                      color: isBot ? Colors.black87 : Colors.white,
                      fontWeight: FontWeight.w400),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar(BuildContext context) {
    return ClipRRect(
      borderRadius:
      const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.only(
            left: 16, right: 16, top: 14,
            bottom: MediaQuery.of(context).padding.bottom + 14,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.45),
            border: Border(top: BorderSide(color: Colors.white.withOpacity(0.3))),
          ),
          child: Row(children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.black12),
                ),
                child: TextField(
                  controller: _inputController,
                  focusNode: _focusNode,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 3,
                  minLines: 1,
                  style: const TextStyle(fontSize: 15),
                  decoration: const InputDecoration(
                    hintText: 'Type your response...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.black38, fontSize: 14),
                  ),
                  onSubmitted: (_) => _submitTextAnswer(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: _submitTextAnswer,
              child: Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFF537E5D),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildDoneBar(BuildContext context) {
    return ClipRRect(
      borderRadius:
      const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 16,
            bottom: MediaQuery.of(context).padding.bottom + 16,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.4),
            border: Border(top: BorderSide(color: Colors.white.withOpacity(0.3))),
          ),
          child: Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Get.back(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Color(0xFF537E5D), width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const AppText('Back', fontSize: 15, color: Color(0xFF537E5D), fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to BLS page
                  // Get.to(() => const BilateralStimulationPage());
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF537E5D),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const AppText('Begin BLS', fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, left: 10),
      child: Row(children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        const AppText('EMDR Companion', fontSize: 20, fontWeight: FontWeight.bold),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  UI STATE ENUM
// ══════════════════════════════════════════════════════════════

enum _UIState {
  startOptions,
  chat,
  negativeBeliefs,
  positiveBeliefs,
  vocRating,
  sudRating,
  pfsRating,
  summary,
  done,
}

// ══════════════════════════════════════════════════════════════
//  STARTING OPTIONS WIDGET
// ══════════════════════════════════════════════════════════════

class _StartingOptionsWidget extends StatelessWidget {
  final void Function(String) onChoose;
  const _StartingOptionsWidget({required this.onChoose});

  @override
  Widget build(BuildContext context) {
    final options = [
      {
        'key': 'memory',
        'title': 'Memory / Past Event',
        'subtitle': '"Something that happened"',
        'examples': ['The assault', 'Car accident', 'Being bullied'],
        'color': const Color(0xFFa8c3b8),
        'bg': const Color(0xFFf0f5f2),
      },
      {
        'key': 'future',
        'title': 'Future Scenario',
        'subtitle': '"What if..." fears',
        'examples': ['Contaminating others', 'Failing & losing job', 'Being judged'],
        'color': const Color(0xFFc3b8a8),
        'bg': const Color(0xFFf5f2f0),
      },
      {
        'key': 'words',
        'title': 'Words / Thoughts',
        'subtitle': '"Loops in my head"',
        'examples': ['"Is this the right person?"', '"What if I hurt someone?"', '"Did I lock the door?"'],
        'color': const Color(0xFFb8a8c3),
        'bg': const Color(0xFFf2f0f5),
      },
      {
        'key': 'negative',
        'title': 'Difficult Emotions',
        'subtitle': '"I just feel..."',
        'examples': ['Frozen / numb', 'Random panic', 'Overwhelming shame'],
        'color': const Color(0xFFc3a8b3),
        'bg': const Color(0xFFf5f0f2),
      },
      {
        'key': 'addiction',
        'title': 'Addiction / Craving',
        'subtitle': '"Pleasurable but problematic"',
        'examples': ['Alcohol / drug high', 'Shopping rush', 'Gaming excitement'],
        'color': const Color(0xFFd4b896),
        'bg': const Color(0xFFfaf6f0),
      },
    ];

    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: AppText(
              'Choose what feels most present for you:',
              fontSize: 13,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.15,
            children: options
                .map((o) => _OptionCard(option: o, onChoose: onChoose))
                .toList(),
          ),
          const SizedBox(height: 10),
          Center(
            child: AppText(
              'Tip: Choose the one that feels strongest right now',
              fontSize: 12,
              color: Colors.black38,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final Map<String, dynamic> option;
  final void Function(String) onChoose;
  const _OptionCard({required this.option, required this.onChoose});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChoose(option['key'] as String),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (option['bg'] as Color).withOpacity(0.85),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: (option['color'] as Color).withOpacity(0.6), width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(option['title'] as String,
                    fontSize: 13,
                    color: const Color(0xFF3e4e44),
                    fontWeight: FontWeight.bold),
                const SizedBox(height: 3),
                AppText(option['subtitle'] as String,
                    fontSize: 10,
                    color: Colors.black45,
                    fontWeight: FontWeight.w400),
                const SizedBox(height: 6),
                ...(option['examples'] as List<String>)
                    .map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Row(children: [
                    const Icon(Icons.circle,
                        size: 5, color: Colors.black38),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(e,
                          style: const TextStyle(
                              fontSize: 10, color: Colors.black54),
                          overflow: TextOverflow.ellipsis),
                    ),
                  ]),
                ))
                    .toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  BELIEF SELECTION WIDGET
// ══════════════════════════════════════════════════════════════

class _BeliefSelectionWidget extends StatefulWidget {
  final String type; // 'negative' or 'positive'
  final Map<String, List<String>> beliefs;
  final String? currentNegative;
  final void Function(List<String>)? onSubmit; // for negative
  final void Function(String)? onSubmitSingle; // for positive

  const _BeliefSelectionWidget({
    required this.type,
    required this.beliefs,
    this.currentNegative,
    this.onSubmit,
    this.onSubmitSingle,
  });

  @override
  State<_BeliefSelectionWidget> createState() =>
      _BeliefSelectionWidgetState();
}

class _BeliefSelectionWidgetState extends State<_BeliefSelectionWidget> {
  final Set<String> _selected = {};

  @override
  Widget build(BuildContext context) {
    final isNegative = widget.type == 'negative';
    final suggestedOpposite = widget.currentNegative != null
        ? kSuggestedOpposites[widget.currentNegative]
        : null;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isNegative && widget.currentNegative != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF537E5D).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(children: [
                          const Icon(Icons.arrow_forward_ios,
                              size: 11, color: Color(0xFF537E5D)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'For: "${widget.currentNegative}"',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF537E5D),
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ]),
                      ),
                      const SizedBox(height: 10),
                    ],
                    // Suggested opposite
                    if (!isNegative && suggestedOpposite != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBF0),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: const Color(0xFFD4B896), width: 2),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Suggested Positive Belief:',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF8B6914),
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selected.clear();
                                  _selected.add(suggestedOpposite);
                                });
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: _selected.contains(suggestedOpposite)
                                      ? const Color(0xFF537E5D)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: const Color(0xFFD4B896)),
                                ),
                                child: Text(
                                  '"$suggestedOpposite"',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: _selected.contains(suggestedOpposite)
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Tap if this feels right, or choose below',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.black45,
                                  fontStyle: FontStyle.italic),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    Center(
                      child: Text(
                        isNegative
                            ? 'Select belief(s) that resonate with you:'
                            : 'Select your preferred positive belief:',
                        style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF537E5D),
                            fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              // Belief list (max height scrollable)
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 260),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: widget.beliefs.entries.map((entry) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 10, bottom: 6),
                            child: Text(entry.key,
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF537E5D),
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.3)),
                          ),
                          ...entry.value.map((belief) {
                            final isSelected = _selected.contains(belief);
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isNegative) {
                                    if (isSelected) {
                                      _selected.remove(belief);
                                    } else {
                                      _selected.add(belief);
                                    }
                                  } else {
                                    _selected.clear();
                                    _selected.add(belief);
                                  }
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.only(bottom: 6),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF537E5D)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF537E5D)
                                        : Colors.black12,
                                  ),
                                ),
                                child: Text(belief,
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.black87)),
                              ),
                            );
                          }).toList(),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
              // Continue button
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_selected.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isNegative
                                ? 'Please select at least one negative belief'
                                : 'Please select a positive belief'),
                            backgroundColor: const Color(0xFF537E5D),
                          ),
                        );
                        return;
                      }
                      if (isNegative) {
                        widget.onSubmit?.call(_selected.toList());
                      } else {
                        widget.onSubmitSingle?.call(_selected.first);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF537E5D),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      isNegative
                          ? 'Continue with selected belief(s)'
                          : 'Continue with positive belief',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
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

// ══════════════════════════════════════════════════════════════
//  RATING SCALE WIDGET
// ══════════════════════════════════════════════════════════════

class _RatingScaleWidget extends StatefulWidget {
  final String type; // 'voc', 'sud', 'pfs'
  final List<String> positiveBeliefs;
  final List<String> negativeBeliefs;
  final void Function(int) onSubmit;

  const _RatingScaleWidget({
    required this.type,
    required this.positiveBeliefs,
    required this.negativeBeliefs,
    required this.onSubmit,
  });

  @override
  State<_RatingScaleWidget> createState() => _RatingScaleWidgetState();
}

class _RatingScaleWidgetState extends State<_RatingScaleWidget> {
  int? _selected;

  @override
  Widget build(BuildContext context) {
    String title, instruction, minLabel, maxLabel;
    int maxVal;

    if (widget.type == 'voc') {
      final beliefs = widget.positiveBeliefs.join(', ');
      title = 'Holding the freeze frame in mind, how true does\n"$beliefs"\nfeel right now?';
      instruction = 'Rate from 1 (not true at all) to 7 (completely true)';
      minLabel = 'Not true at all';
      maxLabel = 'Completely true';
      maxVal = 7;
    } else if (widget.type == 'sud') {
      final neg = widget.negativeBeliefs.join(', ');
      title = 'Keeping that frozen moment in mind and thinking about\n"$neg"\nHow intense is the distress right now?';
      instruction = 'All negative emotions together (0 = none, 10 = most intense)';
      minLabel = 'No distress';
      maxLabel = 'Most intense';
      maxVal = 10;
    } else {
      title = 'How intense is this positive feeling right now when you think about it?';
      instruction = 'Rate from 0 (no positive feeling) to 10 (most intense positive feeling)';
      minLabel = 'No positive feeling';
      maxLabel = 'Most intense';
      maxVal = 10;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.65),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.4)),
          ),
          child: Column(
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF537E5D),
                      fontWeight: FontWeight.w600,
                      height: 1.5),
                  textAlign: TextAlign.center),
              const SizedBox(height: 6),
              Text(instruction,
                  style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black45,
                      fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center),
              const SizedBox(height: 18),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: List.generate(maxVal + 1 - (widget.type == 'voc' ? 1 : 0), (i) {
                  final val = i + (widget.type == 'voc' ? 1 : 0);
                  final isSel = _selected == val;
                  return GestureDetector(
                    onTap: () => setState(() => _selected = val),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSel
                            ? const Color(0xFF537E5D)
                            : Colors.white,
                        border: Border.all(
                          color: isSel
                              ? const Color(0xFF537E5D)
                              : Colors.black12,
                          width: 2,
                        ),
                        boxShadow: isSel
                            ? [
                          BoxShadow(
                              color: const Color(0xFF537E5D)
                                  .withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2))
                        ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          '$val',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isSel
                                  ? Colors.white
                                  : const Color(0xFF537E5D)),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(minLabel,
                          style: const TextStyle(
                              fontSize: 11, color: Colors.black45)),
                      Text(maxLabel,
                          style: const TextStyle(
                              fontSize: 11, color: Colors.black45)),
                    ]),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_selected == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select a rating to continue'),
                          backgroundColor: Color(0xFF537E5D),
                        ),
                      );
                      return;
                    }
                    widget.onSubmit(_selected!);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF537E5D),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Continue',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  SUMMARY WIDGET
// ══════════════════════════════════════════════════════════════

class _SummaryWidget extends StatelessWidget {
  final List<dynamic> responses;
  final List<BeliefPair> beliefPairs;
  final bool isAddiction;

  const _SummaryWidget({
    required this.responses,
    required this.beliefPairs,
    required this.isAddiction,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.75),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF537E5D).withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Icon(Icons.spa, color: Color(0xFF537E5D), size: 20),
                const SizedBox(width: 8),
                const Text('Your EMDR Session Summary',
                    style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF537E5D),
                        fontWeight: FontWeight.bold)),
              ]),
              const SizedBox(height: 16),
              if (responses.isNotEmpty)
                _row('Starting Point',
                    responses[0].toString().replaceAll('Starting point: ', '')),
              if (responses.length > 1) _row('Target', responses[1].toString()),
              if (responses.length > 2)
                _row('Freeze Frame', responses[2].toString()),
              if (!isAddiction && beliefPairs.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text('Belief Pairs:',
                    style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF537E5D),
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                ...beliefPairs.map((pair) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF537E5D).withOpacity(0.07),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('✗ ${pair.negative}',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black54)),
                        const SizedBox(height: 4),
                        Text('✓ ${pair.positive}',
                            style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF537E5D),
                                fontWeight: FontWeight.w600)),
                      ]),
                )),
              ],
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF537E5D).withOpacity(0.07),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'This summary has been saved to your My Space area for your next session.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Colors.black45),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: RichText(
      text: TextSpan(children: [
        TextSpan(
            text: '$label: ',
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF537E5D),
                fontSize: 13)),
        TextSpan(
            text: value,
            style:
            const TextStyle(color: Colors.black87, fontSize: 13)),
      ]),
    ),
  );
}