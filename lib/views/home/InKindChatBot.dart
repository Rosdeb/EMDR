import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jonssony/utils/app_text.dart';

enum _ChatMode { planning, followUp }

enum _ChatStep {
  idle,
  collectingStep,
  ratingSuds,
  collectingNextWeekSupport,
}

enum _MessageType {
  bot,
  user,
  behaviorOptions,
  initialFollowUpOptions,
  hierarchyPlan,
  hierarchyReview,
  repetitionTipsOptions,
  obstacleOptions,
  recommendations,
}

class InKindChatBot extends StatefulWidget {
  const InKindChatBot({super.key, this.forceNewHomework = false});

  final bool forceNewHomework;

  @override
  State<InKindChatBot> createState() => _InKindChatBotState();
}

class _InKindChatBotState extends State<InKindChatBot> {
  static const String _homeworkExistsKey = 'behaviour_homework_exists';
  static const String _behaviorKey = 'behaviour_homework_behavior';
  static const String _hierarchyKey = 'behaviour_homework_hierarchy';
  static const String _weekKey = 'behaviour_homework_week';

  final box = GetStorage();
  final List<_ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isTyping = false;
  bool _inputEnabled = false;
  String _inputPlaceholder = 'Type your response here...';
  _ChatMode _mode = _ChatMode.planning;
  _ChatStep _currentStep = _ChatStep.idle;
  String? _selectedBehavior;
  int _currentWeek = 1;
  int? _reviewingStepIndex;
  final List<_ExposureStep> _exposureHierarchy = [];

  final List<String> _clientBehaviors = [
    'Avoiding social situations',
    'Checking doors repeatedly',
    'Procrastinating on important tasks',
    'Avoiding conflict conversations',
    'Excessive reassurance seeking',
  ];

  @override
  void initState() {
    super.initState();
    _loadSavedHomework();
    _mode = !widget.forceNewHomework && _exposureHierarchy.isNotEmpty
        ? _ChatMode.followUp
        : _ChatMode.planning;
    _startConversation();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadSavedHomework() {
    _selectedBehavior = box.read<String>(_behaviorKey);
    _currentWeek = box.read<int>(_weekKey) ?? 1;
    final saved = box.read<List>(_hierarchyKey) ?? [];
    _exposureHierarchy
      ..clear()
      ..addAll(saved.map((item) {
        return _ExposureStep.fromMap(Map<String, dynamic>.from(item as Map));
      }));
  }

  Future<void> _startConversation() async {
    if (_mode == _ChatMode.followUp) {
      await _startFollowUpConversation();
      return;
    }

    await _delayedBot(
      "Welcome. I'm here to support you with the behavioral aspects of your therapy as part of your weekly homework plan.",
    );
    await _delayedBot(
      "Working on behaviors that maintain or exacerbate your difficulties can be an important part of your recovery journey. This is entirely optional, and we'll proceed at a pace that feels comfortable for you.",
    );
    await _delayedBot(
      "Based on your CBT formulation, you've identified several behaviors that may be contributing to your current difficulties. Let's explore which one you'd like to address this week:",
    );
    _addMessage(_ChatMessage(type: _MessageType.behaviorOptions));
  }

  Future<void> _startFollowUpConversation() async {
    final behavior = _selectedBehavior ?? 'your chosen behavior';
    final week = _currentWeek;
    await _delayedBot(
      week == 1
          ? "Welcome back. I hope you've had a chance to begin working with your exposure hierarchy for '$behavior'."
          : "Welcome to week $week of your exposure therapy journey. Let's continue working on '$behavior'.",
    );
    await _delayedBot(
      "Remember: successful exposure therapy isn't about rushing through steps. It's about repeating each step until your anxiety naturally decreases. Most people need 5-10 repetitions of the same exposure before their SUDS drops significantly.",
    );
    await _delayedBot('How have you been finding the homework this week?');
    _addMessage(_ChatMessage(type: _MessageType.initialFollowUpOptions));
  }

  Future<void> _delayedBot(String text) async {
    if (!mounted) return;
    setState(() => _isTyping = true);
    _scrollToBottom();
    await Future.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;
    setState(() => _isTyping = false);
    _addBotMessage(text);
  }

  void _addBotMessage(String text) {
    _addMessage(_ChatMessage(type: _MessageType.bot, text: text));
  }

  void _addUserMessage(String text) {
    _addMessage(_ChatMessage(type: _MessageType.user, text: text));
  }

  void _addMessage(_ChatMessage message) {
    if (!mounted) return;
    setState(() => _messages.add(message));
    _scrollToBottom();
  }

  void _setInput({
    required bool enabled,
    String placeholder = 'Type your response here...',
  }) {
    setState(() {
      _inputEnabled = enabled;
      _inputPlaceholder = placeholder;
    });
  }

  void _selectBehavior(String behavior) async {
    _selectedBehavior = behavior;
    _addUserMessage(behavior);
    await _delayedBot(
      'That\'s a thoughtful choice. Working on "$behavior" can lead to meaningful change. Together, we\'ll create a gradual exposure hierarchy that feels manageable and achievable.',
    );
    await _delayedBot(
      "We'll break this down into small, manageable steps. Starting with situations that cause minimal distress and gradually working towards more challenging ones. This approach ensures you build confidence at each stage.",
    );
    _buildHierarchy();
  }

  void _buildHierarchy() {
    final behavior = _selectedBehavior ?? '';
    String prompt;
    if (behavior == 'Avoiding social situations') {
      prompt =
          "Let's begin gently. Can you describe a social situation that would cause you minimal anxiety? Perhaps something around 2-3 out of 10 on the distress scale?";
    } else if (behavior == 'Checking doors repeatedly') {
      prompt =
          'What would be a small first step in reducing your checking behavior? For instance, might checking just once before bed feel manageable?';
    } else if (behavior == 'Procrastinating on important tasks') {
      prompt =
          "What's the smallest step you could take towards an important task? Perhaps spending just 5 minutes on it, or simply organizing your materials?";
    } else if (behavior == 'Avoiding conflict conversations') {
      prompt =
          'Could we start with something very mild? Perhaps expressing a small preference or disagreement about something minor?';
    } else {
      prompt =
          'For "$behavior", what would be the smallest, most gentle first step you could imagine taking?';
    }

    _addBotMessage(prompt);
    _currentStep = _ChatStep.collectingStep;
    _setInput(
      enabled: true,
      placeholder: 'Describe a manageable first step...',
    );
  }

  void _handleUserInput() {
    final input = _controller.text.trim();
    if (input.isEmpty || !_inputEnabled) return;

    _controller.clear();
    _addUserMessage(input);

    switch (_currentStep) {
      case _ChatStep.collectingStep:
        _processHierarchyStep(input);
        break;
      case _ChatStep.ratingSuds:
        if (_mode == _ChatMode.followUp && _reviewingStepIndex != null) {
          _processCurrentSudsRating(input);
        } else {
          _processSudsRating(input);
        }
        break;
      case _ChatStep.collectingNextWeekSupport:
        _processNextWeekPlan(input);
        break;
      case _ChatStep.idle:
        break;
    }
  }

  Future<void> _processHierarchyStep(String step) async {
    _exposureHierarchy.add(_ExposureStep(step: step));
    _currentStep = _ChatStep.ratingSuds;
    _setInput(enabled: true, placeholder: 'Enter a number from 0-10...');
    await _delayedBot(
      'Thank you for sharing that. To help us understand the challenge level, could you rate how much distress this would cause on a scale from 0 to 10? (0 being no distress at all, 10 being maximum distress)',
    );
  }

  Future<void> _processSudsRating(String rating) async {
    final suds = int.tryParse(rating);
    if (suds == null || suds < 0 || suds > 10) {
      _addBotMessage('Please enter a number between 0 and 10.');
      return;
    }

    _exposureHierarchy.last.originalSuds = suds;

    if (_exposureHierarchy.length < 5) {
      final nextPrompt = _nextHierarchyPrompt(suds);
      _currentStep = _ChatStep.collectingStep;
      _setInput(enabled: true, placeholder: 'Describe the next step...');
      await _delayedBot(nextPrompt);
      return;
    }

    _completeHierarchy();
  }

  String _nextHierarchyPrompt(int suds) {
    final ratings = _exposureHierarchy
        .map((item) => item.originalSuds)
        .whereType<int>()
        .toList();
    final maxSuds = ratings.fold<int>(0, (max, value) => value > max ? value : max);
    final stepsLeft = 5 - _exposureHierarchy.length;

    if (_exposureHierarchy.length == 4) {
      return "That's helpful - a $suds/10. For our final step, let's consider your most challenging scenario. What situation would represent the biggest step, perhaps around 8-10/10?";
    }

    if (maxSuds >= 9) {
      final minSuds = ratings.fold<int>(10, (min, value) => value < min ? value : min);
      final missing = <int>[];
      for (var i = minSuds + 1; i < maxSuds; i++) {
        if (!ratings.contains(i)) missing.add(i);
      }
      final nextSuds = missing.isNotEmpty ? missing[missing.length ~/ 2] : maxSuds;
      return "Thank you - that's a $suds/10. Now let's fill in our hierarchy. Can you think of a step that would be around $nextSuds/10 in terms of distress?";
    }

    final increment = ((10 - maxSuds) / stepsLeft).ceil();
    final nextSuds = (maxSuds + increment).clamp(0, 10);
    return "Good - that's a $suds/10. Let's gradually increase the challenge. What would be a step that might cause around $nextSuds/10 distress?";
  }

  Future<void> _completeHierarchy() async {
    _setInput(enabled: false);
    _currentStep = _ChatStep.idle;
    _exposureHierarchy.sort((a, b) {
      return (a.originalSuds ?? 0).compareTo(b.originalSuds ?? 0);
    });

    await box.write(_homeworkExistsKey, true);
    await box.write(_behaviorKey, _selectedBehavior);
    await box.write(_weekKey, 1);
    await box.write(
      _hierarchyKey,
      _exposureHierarchy.map((step) => step.toMap()).toList(),
    );

    await _delayedBot("Excellent work. Here's your personalised exposure hierarchy:");
    _addMessage(_ChatMessage(type: _MessageType.hierarchyPlan));
    await _delayedBot(
      "Remember, you're in control of this process. If any step feels too challenging, we can adjust it in your next session. Your wellbeing and comfort are our priority.",
    );
  }

  void _selectInitialFollowUp(String response) async {
    final labels = {
      'good': "I've made some progress",
      'challenging': "It's been challenging",
      'mixed': 'Mixed - some good, some difficult',
      'unable': "I wasn't able to practice",
    };
    _addUserMessage(labels[response] ?? response);

    final botResponse = switch (response) {
      'good' =>
        "That's wonderful to hear. Every step forward, no matter how small, is meaningful progress. Let's look at what you've accomplished.",
      'challenging' =>
        "Thank you for your honesty. Exposure work can be difficult, and acknowledging the challenge is important. Let's explore what's been happening.",
      'mixed' =>
        "That's very normal and expected. Exposure therapy often has ups and downs. Let's review both the successes and the challenges.",
      _ =>
        "That's completely okay. Sometimes life gets in the way, or we're not ready yet. There's no judgment here. Let's talk about what happened and how we can adjust.",
    };

    await _delayedBot(botResponse);
    _showHierarchyReview();
  }

  Future<void> _showHierarchyReview() async {
    await _delayedBot(
      "Let's review each step from your hierarchy. We'll go through them one by one, and you can tell me about your experience with each.",
    );
    _addMessage(_ChatMessage(type: _MessageType.hierarchyReview));
  }

  void _reviewStep(int index) async {
    _reviewingStepIndex = index;
    final step = _exposureHierarchy[index];
    _addUserMessage('Review Step ${index + 1}: ${step.step}');
    await _delayedBot('Did you practice this step during the week?');
    _addMessage(
      _ChatMessage(
        type: _MessageType.bot,
        text: 'Choose one:',
        options: const ['Yes, I practiced it', 'Not yet'],
        optionValues: const ['practiced', 'not-started'],
      ),
    );
  }

  void _handleInlineOption(String value) async {
    if (_reviewingStepIndex == null) return;
    final step = _exposureHierarchy[_reviewingStepIndex!];

    if (value == 'not-started') {
      _addUserMessage('Not yet');
      step.status = 'not-started';
      step.attempts = 0;
      await _saveHierarchy();
      await _delayedBot(
        "That's okay. This week, consider making the step smaller or scheduling a specific time to practice.",
      );
      _showSummaryAndNextActions();
      return;
    }

    _addUserMessage('Yes, I practiced it');
    step.attempts += 1;
    _currentStep = _ChatStep.ratingSuds;
    _setInput(
      enabled: true,
      placeholder: 'Current SUDS for this step, 0-10...',
    );
    await _delayedBot(
      'Great. What is your current SUDS rating for this step now, from 0 to 10?',
    );
  }

  Future<void> _saveHierarchy() async {
    await box.write(
      _hierarchyKey,
      _exposureHierarchy.map((step) => step.toMap()).toList(),
    );
  }

  Future<void> _showSummaryAndNextActions() async {
    await _saveHierarchy();
    _addMessage(_ChatMessage(type: _MessageType.recommendations));
    await _delayedBot(
      'Would you like tips on making repetition more effective and less boring?',
    );
    _addMessage(_ChatMessage(type: _MessageType.repetitionTipsOptions));
  }

  Future<void> _processCurrentSudsRating(String rating) async {
    final suds = int.tryParse(rating);
    if (suds == null || suds < 0 || suds > 10) {
      _addBotMessage('Please enter a number between 0 and 10.');
      return;
    }

    final step = _exposureHierarchy[_reviewingStepIndex!];
    step.currentSuds = suds;
    step.status = suds <= 2 ? 'completed' : 'in-progress';
    _reviewingStepIndex = null;
    _currentStep = _ChatStep.idle;
    _setInput(enabled: false);

    if (suds <= 2) {
      await _delayedBot(
        'That suggests this step is becoming mastered. Excellent work - repeated practice is paying off.',
      );
    } else {
      await _delayedBot(
        'Thank you. A current SUDS of $suds/10 means this step still deserves more repetition before moving forward.',
      );
    }

    await _showSummaryAndNextActions();
  }

  void _handleRepetitionTips(bool wantsTips) async {
    _addUserMessage(
      wantsTips ? 'Yes, give me repetition strategies' : 'No, continue to obstacles',
    );
    if (wantsTips) {
      _addMessage(
        _ChatMessage(
          type: _MessageType.bot,
          text:
              'Making repetition effective:\n\n- Vary the context: same exposure, different settings or times.\n- Track SUDS before, during, and after.\n- Extend duration gradually.\n- Stay present and resist safety behaviors.\n\nThe 85% rule: when an exposure feels about 85% comfortable, you may be ready for the next step.',
        ),
      );
    }
    await _delayedBot(
      'Would you like me to help you identify potential obstacles and solutions for next week?',
    );
    _addMessage(_ChatMessage(type: _MessageType.obstacleOptions));
  }

  void _handleObstacles(bool wantsHelp) async {
    _addUserMessage(
      wantsHelp ? "Yes, let's problem-solve obstacles" : "No, I'm ready to start",
    );
    if (wantsHelp) {
      _addMessage(
        _ChatMessage(
          type: _MessageType.bot,
          text:
              'Common obstacles and solutions:\n\n- “I forgot”: set two reminders and link practice to an existing habit.\n- “I felt too anxious”: make the step easier and start with three deep breaths.\n- “I avoided it”: reduce the step by 50% and commit to 30 seconds.\n- “The opportunity did not arise”: create a backup plan or use mental rehearsal.',
        ),
      );
    }
    await _delayedBot('What specific support would help you succeed next week?');
    _currentStep = _ChatStep.collectingNextWeekSupport;
    _setInput(enabled: true, placeholder: 'Share what would help...');
  }

  Future<void> _processNextWeekPlan(String plan) async {
    _setInput(enabled: false);
    _currentStep = _ChatStep.idle;
    await box.write(_weekKey, _currentWeek + 1);
    await _delayedBot(
      'Thank you for that thoughtful reflection. Your insights will help guide your practice in the coming week.',
    );
    await _delayedBot(
      'Focus on mastering one step at a time. Quality over quantity - one mastered step is worth more than five partially completed ones.',
    );
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
          Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(35),
                            topRight: Radius.circular(35),
                          ),
                          image: DecorationImage(
                            image: AssetImage('assets/images/home_bg1.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 30,
                      ),
                      itemCount: _messages.length + (_isTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _messages.length && _isTyping) {
                          return _buildTypingIndicator();
                        }
                        return _buildMessage(_messages[index]);
                      },
                    ),
                  ],
                ),
              ),
              _buildInputArea(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(_ChatMessage message) {
    switch (message.type) {
      case _MessageType.bot:
        if (message.options != null && message.optionValues != null) {
          return _buildInlineOptionsCard(message);
        }
        return _buildChatBubble(message.text ?? '', isBot: true);
      case _MessageType.user:
        return _buildChatBubble(message.text ?? '', isBot: false);
      case _MessageType.behaviorOptions:
        return _buildBehaviorOptionsCard();
      case _MessageType.initialFollowUpOptions:
        return _buildInitialFollowUpOptions();
      case _MessageType.hierarchyPlan:
        return _buildHierarchyPlanCard();
      case _MessageType.hierarchyReview:
        return _buildHierarchyReviewCard();
      case _MessageType.repetitionTipsOptions:
        return _buildChoiceCard(
          options: const [
            'Yes, give me repetition strategies',
            'No, continue to obstacles',
          ],
          onTap: (index) => _handleRepetitionTips(index == 0),
        );
      case _MessageType.obstacleOptions:
        return _buildChoiceCard(
          options: const [
            "Yes, let's problem-solve obstacles",
            "No, I'm ready to start",
          ],
          onTap: (index) => _handleObstacles(index == 0),
        );
      case _MessageType.recommendations:
        return _buildRecommendationsCard();
    }
  }

  Widget _buildChatBubble(String text, {required bool isBot}) {
    return Align(
      alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment:
              isBot ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(15),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.78,
                  ),
                  decoration: BoxDecoration(
                    color: isBot
                        ? Colors.white.withOpacity(0.85)
                        : const Color(0xFFD9E4D5).withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: AppText(text, fontSize: 14, color: Colors.black87),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBehaviorOptionsCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildChatBubble(
          'Which behavior would you like to focus on?',
          isBot: true,
        ),
        _buildChoiceCard(
          options: _clientBehaviors,
          onTap: (index) => _selectBehavior(_clientBehaviors[index]),
        ),
      ],
    );
  }

  Widget _buildInitialFollowUpOptions() {
    const options = [
      "I've made some progress",
      "It's been challenging",
      'Mixed - some good, some difficult',
      "I wasn't able to practice",
    ];
    const values = ['good', 'challenging', 'mixed', 'unable'];
    return _buildChoiceCard(
      options: options,
      onTap: (index) => _selectInitialFollowUp(values[index]),
    );
  }

  Widget _buildInlineOptionsCard(_ChatMessage message) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildChatBubble(message.text ?? '', isBot: true),
        _buildChoiceCard(
          options: message.options!,
          onTap: (index) => _handleInlineOption(message.optionValues![index]),
        ),
      ],
    );
  }

  Widget _buildChoiceCard({
    required List<String> options,
    required ValueChanged<int> onTap,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(15),
          margin: const EdgeInsets.only(top: 10, bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Column(
            children: List.generate(options.length, (index) {
              return GestureDetector(
                onTap: () => onTap(index),
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(
                    bottom: index == options.length - 1 ? 0 : 10,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: AppText(
                    options[index],
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildHierarchyPlanCard() {
    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText(
            'Your Weekly Plan',
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
          const SizedBox(height: 12),
          ...List.generate(_exposureHierarchy.length, (index) {
            final step = _exposureHierarchy[index];
            return _buildPlanStepTile(index, step);
          }),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0.2,
              minHeight: 5,
              color: Colors.black87,
              backgroundColor: Colors.black.withOpacity(0.08),
            ),
          ),
          const SizedBox(height: 16),
          const AppText(
            "This Week's Focus: Begin with Step 1. Practice it daily when possible, and observe how your distress level naturally decreases with repetition. Progress is personal - move at your own pace and be compassionate with yourself.",
            fontSize: 13,
            color: Colors.black87,
          ),
        ],
      ),
    );
  }

  Widget _buildPlanStepTile(int index, _ExposureStep step) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.88),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          AppText(
            'Step ${index + 1}',
            fontSize: 11,
            color: Colors.black54,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AppText(step.step, fontSize: 13, color: Colors.black87),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(999),
            ),
            child: AppText(
              'SUDS ${step.originalSuds ?? 0}/10',
              fontSize: 11,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHierarchyReviewCard() {
    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            'Your Exposure Hierarchy - Week $_currentWeek',
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
          const SizedBox(height: 12),
          ...List.generate(_exposureHierarchy.length, (index) {
            final step = _exposureHierarchy[index];
            return GestureDetector(
              onTap: () => _reviewStep(index),
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.88),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _statusColor(step).withOpacity(0.45),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: AppText(
                            'Step ${index + 1}',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        _statusBadge(step.status),
                      ],
                    ),
                    const SizedBox(height: 8),
                    AppText(step.step, fontSize: 13, color: Colors.black87),
                    const SizedBox(height: 8),
                    AppText(
                      step.currentSuds == null
                          ? 'Original SUDS ${step.originalSuds}/10'
                          : 'Original SUDS ${step.originalSuds}/10 -> Current ${step.currentSuds}/10',
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),
            );
          }),
          const AppText(
            'Tap any step to update your progress.',
            fontSize: 12,
            color: Colors.black54,
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsCard() {
    final needsWork = _exposureHierarchy.where((step) {
      return step.currentSuds != null && step.currentSuds! > 2;
    }).toList();
    final mastered = _exposureHierarchy.where((step) => step.mastered).toList();
    final notStarted = _exposureHierarchy.where((step) {
      return step.status == 'not-started';
    }).toList();

    final recommendations = <String>[];
    if (needsWork.isNotEmpty) {
      recommendations.add(
        'PRIORITY FOCUS: Continue practicing "${needsWork.first.step}" until SUDS reaches 0-2.',
      );
      recommendations.add(
        'Current SUDS: ${needsWork.first.currentSuds}/10 -> Target: 0-2/10.',
      );
      recommendations.add('Do not move to harder steps until this is mastered.');
    } else if (mastered.isNotEmpty && notStarted.isNotEmpty) {
      recommendations.add(
        'NEXT STEP: You may be ready to try "${notStarted.first.step}".',
      );
      recommendations.add('Start with brief exposures and build up gradually.');
    } else {
      recommendations.add('Aim to practice 3-4 times this week.');
    }
    recommendations.add('Practice at the same time each day to build a routine.');
    recommendations.add('Keep a simple log: Date, Step, SUDS before and after.');

    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            'Your Homework Plan for Week ${_currentWeek + 1}',
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 12),
          ...List.generate(recommendations.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.black87,
                    child: AppText(
                      '${index + 1}',
                      fontSize: 11,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppText(
                      recommendations[index],
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFEF5350)),
            ),
            child: const AppText(
              'Critical rule: each step should reach SUDS 0-2 before progressing. If SUDS is still high, keep practicing or make the step easier.',
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.78),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withOpacity(0.35)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    final label = status.replaceAll('-', ' ');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: _statusColorByName(status).withOpacity(0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: AppText(
        label.toUpperCase(),
        fontSize: 10,
        color: _statusColorByName(status),
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Color _statusColor(_ExposureStep step) => _statusColorByName(step.status);

  Color _statusColorByName(String status) {
    if (status == 'completed') return const Color(0xFF4CAF50);
    if (status == 'in-progress') return const Color(0xFFFF9800);
    return Colors.black26;
  }

  Widget _buildTypingIndicator() {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: AppText('Bot is typing...', fontSize: 12, color: Colors.black45),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: _inputEnabled ? Colors.white : Colors.white54,
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: _controller,
                enabled: _inputEnabled,
                decoration: InputDecoration(
                  hintText: _inputPlaceholder,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _handleUserInput(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            backgroundColor:
                _inputEnabled ? const Color(0xFF537E5D) : Colors.grey.shade400,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: _inputEnabled ? _handleUserInput : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 10,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
          const AppText(
            'Behaviors',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  const _ChatMessage({
    required this.type,
    this.text,
    this.options,
    this.optionValues,
  });

  final _MessageType type;
  final String? text;
  final List<String>? options;
  final List<String>? optionValues;
}

class _ExposureStep {
  _ExposureStep({
    required this.step,
    this.originalSuds,
    this.currentSuds,
    this.status = 'not-started',
    this.attempts = 0,
  });

  final String step;
  int? originalSuds;
  int? currentSuds;
  String status;
  int attempts;

  bool get mastered => status == 'completed' || (currentSuds != null && currentSuds! <= 2);

  Map<String, dynamic> toMap() {
    return {
      'step': step,
      'originalSuds': originalSuds,
      'currentSuds': currentSuds,
      'status': status,
      'attempts': attempts,
    };
  }

  factory _ExposureStep.fromMap(Map<String, dynamic> map) {
    return _ExposureStep(
      step: map['step']?.toString() ?? '',
      originalSuds: map['originalSuds'] is int
          ? map['originalSuds'] as int
          : int.tryParse(map['originalSuds']?.toString() ?? ''),
      currentSuds: map['currentSuds'] is int
          ? map['currentSuds'] as int
          : int.tryParse(map['currentSuds']?.toString() ?? ''),
      status: map['status']?.toString() ?? 'not-started',
      attempts: map['attempts'] is int
          ? map['attempts'] as int
          : int.tryParse(map['attempts']?.toString() ?? '') ?? 0,
    );
  }
}
