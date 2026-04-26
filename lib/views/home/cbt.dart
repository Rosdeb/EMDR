import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jonssony/utils/app_text.dart';
import 'package:get_storage/get_storage.dart';

class cbt extends StatefulWidget {
  const cbt({super.key});

  @override
  State<cbt> createState() => _cbtState();
}

class _cbtState extends State<cbt> {
  final box = GetStorage();
  // ── Sections from HTML (label, subtitle, answer) ──────────────────────
  final List<Map<String, String>> _sections = [
    {
      'section': 'THE BEGINNING',
      'label': 'When I Was Little',
      'question':
      'Write about early memories & experiences that may have shaped who you are today.\n\n'
          'Float back in time — were there specific events or patterns in your family? '
          'What messages did you receive about yourself growing up?',
      'answer': 'No answer provided yet.',
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
      'answer': 'No answer provided yet.',
    },
    {
      'section': 'MY SURVIVAL GUIDE',
      'label': 'The Rules',
      'question':
      'What "shoulds" or "musts" do you tell yourself that link to your situation and deep beliefs?\n\n'
          '• What do you believe you need to do to be accepted or safe?\n'
          '• What rules do you follow to avoid pain or anxiety?',
      'answer': 'No answer provided yet.',
    },
    {
      'section': 'LIFE HAPPENS',
      'label': 'Triggers',
      'question':
      'What has happened over the years that has triggered how you are feeling?\n\n'
          '• Was there a specific event, person, or place involved?\n'
          '• Have similar situations triggered you before?',
      'answer': 'No answer provided yet.',
    },
    {
      'section': 'RIGHT NOW',
      'label': 'A Recent Happening',
      'question':
      'Write the situation where you last felt the feeling that brought you here today. '
          'We want an actual situation that happened.\n\n'
          'Example: "I had an argument with my partner" or "I had feedback from my boss"',
      'answer': 'No answer provided yet.',
    },
    {
      'section': 'HOW I REACT — THOUGHTS',
      'label': 'My Thoughts',
      'question':
      'What was going on in your head in that moment?\n\n'
          '• What was the first thought that popped into your head?\n'
          '• What were you telling yourself about the situation?\n'
          '• What did you think it meant about you or others?',
      'answer': 'No answer provided yet.',
    },
    {
      'section': 'HOW I REACT — FEELINGS',
      'label': 'My Feelings',
      'question':
      'How did this situation make you feel negatively? '
          'Which emotions did you experience in your body?',
      'answer': 'No answer provided yet.',
    },
    {
      'section': 'HOW I REACT — BEHAVIOURS',
      'label': 'What I Did',
      'question':
      'What did you do immediately after or in the moment?\n\n'
          '• Did you avoid anything or anyone?\n'
          '• How did you cope with these feelings?',
      'answer': 'No answer provided yet.',
    },
    {
      'section': 'THE LOOP',
      'label': 'The Consequences',
      'question':
      'What are the consequences of the stuck loop you are in?',
      'answer': 'No answer provided yet.',
    },
    {
      'section': 'MY SUPERPOWERS',
      'label': 'Your Superpowers',
      'question':
      'What makes you strong, able to carry on, and resilient?\n\n'
          'It could even be something seen as a negative right now — like being very detailed or '
          'overthinking. Other ideas: kindness, warmth, intelligence, loyalty, creativity...',
      'answer': 'No answer provided yet.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadAnswers();
  }

  void _loadAnswers() {
    final savedAnswers = box.read('cbt_answers');
    if (savedAnswers != null && savedAnswers is Map) {
      setState(() {
        for (var section in _sections) {
          if (savedAnswers.containsKey(section['label'])) {
            section['answer'] = savedAnswers[section['label']];
          }
        }
      });
    }
  }

  final Color _green = const Color(0xFF537E5D);

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
                            image:
                            AssetImage('assets/images/chatbot_bg.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 30),
                        itemCount: _sections.length,
                        itemBuilder: (context, index) {
                          final s = _sections[index];
                          return _buildCard(
                            sectionLabel: s['section']!,
                            title: s['label']!,
                            question: s['question']!,
                            answer: s['answer']!,
                          );
                        },
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
    required String sectionLabel,
    required String title,
    required String question,
    required String answer,
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

                // Answer
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.person_outline_outlined,
                        size: 16, color: _green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AppText(
                        answer,
                        fontSize: 14,
                        color: _green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
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