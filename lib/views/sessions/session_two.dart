import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jonssony/utils/app_text.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jonssony/views/sessions/session_three.dart';

class SessionTwo extends StatefulWidget {
  const SessionTwo({super.key});

  @override
  State<SessionTwo> createState() => _SessionTwoState();
}

class _SessionTwoState extends State<SessionTwo> {
  int _currentQuestionIndex = 0;
  final ScrollController _scrollController = ScrollController();
  final box = GetStorage();

  final List<Map<String, dynamic>> _sections = [
    {
      'section': 'THE BEGINNING',
      'label': 'When I Was Little',
      'question':
          'Write about early memories & experiences that may have shaped who you are today.\n\n'
          'Float back in time — were there specific events or patterns in your family? '
          'What messages did you receive about yourself growing up?',
      'controller': TextEditingController(),
      'hint': 'Type your answer here...',
    },
    {
      'section': 'WHAT I LEARNED',
      'label': 'Deep-Down Beliefs',
      'question':
          'These are deep beliefs about yourself that might have been activated.\n\n'
          'Think carefully — which of these feel true to you right now?\n\n'
          '• I am not good enough\n'
          '• I am worthless / inadequate\n'
          '• It\'s my fault\n'
          '• I cannot trust myself\n'
          '• I am alone\n'
          '• I have to be perfect / please everyone\n'
          '• I am powerless / helpless',
      'controller': TextEditingController(),
      'hint': 'Type your answer here...',
    },
    {
      'section': 'MY SURVIVAL GUIDE',
      'label': 'The Rules',
      'question':
          'What "shoulds" or "musts" do you tell yourself that link to your situation and deep beliefs?\n\n'
          '• What do you believe you need to do to be accepted or safe?\n'
          '• What rules do you follow to avoid pain or anxiety?',
      'controller': TextEditingController(),
      'hint': 'Type your answer here...',
    },
    {
      'section': 'LIFE HAPPENS',
      'label': 'Triggers',
      'question':
          'What has happened over the years that has triggered how you are feeling?\n\n'
          '• Was there a specific event, person, or place involved?\n'
          '• Have similar situations triggered you before?',
      'controller': TextEditingController(),
      'hint': 'Type your answer here...',
    },
    {
      'section': 'RIGHT NOW',
      'label': 'A Recent Happening',
      'question':
          'Write the situation where you last felt the feeling that brought you here today. '
          'We want an actual situation that happened.\n\n'
          'Example: "I had an argument with my partner" or "I had feedback from my boss"',
      'controller': TextEditingController(),
      'hint': 'Type your answer here...',
    },
    {
      'section': 'HOW I REACT — THOUGHTS',
      'label': 'My Thoughts',
      'question':
          'What was going on in your head in that moment?\n\n'
          '• What was the first thought that popped into your head?\n'
          '• What were you telling yourself about the situation?\n'
          '• What did you think it meant about you or others?',
      'controller': TextEditingController(),
      'hint': 'Type your answer here...',
    },
    {
      'section': 'HOW I REACT — FEELINGS',
      'label': 'My Feelings',
      'question':
          'How did this situation make you feel negatively? '
          'Which emotions did you experience in your body?',
      'controller': TextEditingController(),
      'hint': 'Type your answer here...',
    },
    {
      'section': 'HOW I REACT — BEHAVIOURS',
      'label': 'What I Did',
      'question':
          'What did you do immediately after or in the moment?\n\n'
          '• Did you avoid anything or anyone?\n'
          '• How did you cope with these feelings?',
      'controller': TextEditingController(),
      'hint': 'Type your answer here...',
    },
    {
      'section': 'THE LOOP',
      'label': 'The Consequences',
      'question':
          'What are the consequences of the stuck loop you are in?',
      'controller': TextEditingController(),
      'hint': 'Type your answer here...',
    },
    {
      'section': 'MY SUPERPOWERS',
      'label': 'Your Superpowers',
      'question':
          'What makes you strong, able to carry on, and resilient?\n\n'
          'It could even be something seen as a negative right now — like being very detailed or '
          'overthinking. Other ideas: kindness, warmth, intelligence, loyalty, creativity...',
      'controller': TextEditingController(),
      'hint': 'Type your answer here...',
    },
  ];

  final Color _green = const Color(0xFF537E5D);

  @override
  void dispose() {
    for (var section in _sections) {
      section['controller'].dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _sections.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
      // Scroll to bottom
      Future.delayed(const Duration(milliseconds: 300), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void _saveAnswers() {
    Map<String, String> answers = {};
    for (var section in _sections) {
      answers[section['label']] = section['controller'].text;
    }
    box.write('cbt_answers', answers);
  }

  @override
  Widget build(BuildContext context) {
    const double appBarImageHeight = 150;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: appBarImageHeight,
            child: Image.asset('assets/images/my_emdr.png', fit: BoxFit.fill),
          ),
          Column(
            children: [
              _buildAppBar(context),
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
                            image: AssetImage('assets/images/chatbot_bg.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              controller: _scrollController,
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 30),
                              itemCount: _currentQuestionIndex + 1,
                              itemBuilder: (context, index) {
                                final s = _sections[index];
                                bool isLastShown = index == _currentQuestionIndex;
                                return _buildCard(
                                  index: index,
                                  sectionLabel: s['section']!,
                                  title: s['label']!,
                                  question: s['question']!,
                                  controller: s['controller']!,
                                  hint: s['hint']!,
                                  isLastShown: isLastShown,
                                );
                              },
                            ),
                          ),
                          if (_currentQuestionIndex == _sections.length - 1 && _sections.last['controller'].text.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  _saveAnswers();
                                  Get.to(() => const SessionThreePage());
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _green,
                                  minimumSize: const Size(double.infinity, 55),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                ),
                                child: const Text("Save & Continue", style: TextStyle(color: Colors.white, fontSize: 18)),
                              ),
                            ),
                        ],
                      ),
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

  Widget _buildCard({
    required int index,
    required String sectionLabel,
    required String title,
    required String question,
    required TextEditingController controller,
    required String hint,
    required bool isLastShown,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _green.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    sectionLabel,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                      color: _green,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Title
                AppText(
                  title,
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w700,
                ),
                const SizedBox(height: 6),

                // Question
                AppText(
                  question,
                  fontSize: 13,
                  color: Colors.black54,
                  fontWeight: FontWeight.w400,
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(color: Colors.black12, thickness: 1),
                ),

                // Answer Input
                TextField(
                  controller: controller,
                  maxLines: null,
                  onChanged: (val) {
                    setState(() {}); // Refresh to show "Save & Continue" button if last
                  },
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(color: Colors.black26, fontSize: 14),
                    border: InputBorder.none,
                    icon: Icon(Icons.edit_note, color: _green, size: 20),
                  ),
                  style: TextStyle(
                    fontSize: 14,
                    color: _green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                if (isLastShown && index < _sections.length - 1)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: controller.text.isNotEmpty ? _nextQuestion : null,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("Next Question", style: TextStyle(color: controller.text.isNotEmpty ? _green : Colors.grey)),
                          Icon(Icons.arrow_forward, size: 16, color: controller.text.isNotEmpty ? _green : Colors.grey),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 10, left: 10),
      child: Row(children: [
        IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back()),
        const AppText('CBT Formulation',
            fontSize: 20, fontWeight: FontWeight.bold),
      ]),
    );
  }
}