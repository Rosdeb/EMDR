import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:jonssony/views/home/StroopTestScreen.dart';
import 'package:jonssony/views/home/TetrisGameScreen.dart';
import 'package:jonssony/views/home/battleship.dart';
import 'package:jonssony/views/home/spelling.dart';

class EmdrScreen extends StatefulWidget {
  const EmdrScreen({super.key});

  @override
  State<EmdrScreen> createState() => _EmdrScreenState();
}

class _EmdrScreenState extends State<EmdrScreen> {
  static const List<String> _instructionSteps = [
    'Rate your emotion 1-10.',
    'Hold the emotion in mind and force it to the forefront as much as you can through the exercise.',
    'Tap your feet in a non bilateral rhythm: 1, 1, 2, like We Will Rock You.',
    'Start the game.',
    'Rate your emotion again.',
    'Repeat until feeling better.',
  ];

  @override
  Widget build(BuildContext context) {
    const double appBarImageHeight = 150;

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: appBarImageHeight,
            child: Image.asset('assets/images/my_emdr.png', fit: BoxFit.cover),
          ),

          Column(
            children: [
              _buildAppBar(context),
              const SizedBox(height: 5),

              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                          image: DecorationImage(
                            image: AssetImage('assets/images/bg_library.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),

                    Positioned.fill(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 35),
                            _buildInstructionsCard(),
                            const SizedBox(height: 18),

                            _buildGlassItem(
                              "Battleship",
                              "Locate hidden ships on a grid. Strategic thinking engages your working memory.",
                              'assets/images/behaviour_img.jpg',
                              () => _showGameReminderAndOpen(
                                () => const GameScreenN(
                                  mode: 'counting',
                                  difficulty: 'medium',
                                ),
                              ),
                            ),

                            _buildGlassItem(
                              "Stroop Test",
                              "Name the ink color while ignoring the written word.",
                              'assets/images/thoughts_img.jpg',
                              () => _showGameReminderAndOpen(
                                () => const StroopTestScreen(),
                              ),
                            ),

                            _buildGlassItem(  
                              "Pattern Memory",
                              "Hold a color sequence in mind and repeat it back.",
                              'assets/images/behaviour_img.jpg',
                              () => _showGameReminderAndOpen(
                                () => const PatternMemoryGame(),
                              ),
                            ),

                            _buildGlassItem(
                              "Tetris",
                              "Use spatial planning to keep your working memory busy.",
                              'assets/images/emotions_img.jpg',
                              () => _showGameReminderAndOpen(
                                () => const TetrisGameScreen(),
                              ),
                            ),

                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),

      // // ৫. ফ্লোটিং অ্যাকশন বাটন (মোড টগল)
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 16,
        right: 16,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    size: 20,
                    color: Color(0xFF2E3E32),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          const Text(
            'EMDR 2.0',
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E3E32),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showGameReminderAndOpen(Widget Function() gameBuilder) async {
    final shouldStart = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFFCF8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Before you start',
            style: TextStyle(
              color: Color(0xFF2E3E32),
              fontWeight: FontWeight.w700,
            ),
          ),
          content: const Text(
            'Hold your emotion in the forefront of your mind as much as you can!',
            style: TextStyle(
              color: Color(0xFF4A4A4A),
              fontSize: 15,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A7C5F),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Start Game'),
            ),
          ],
        );
      },
    );

    if (!mounted || shouldStart != true) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => gameBuilder()),
    );
  }

  Widget _buildInstructionsCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.62),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.42)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'How to use EMDR 2.0',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E3E32),
                ),
              ),
              const SizedBox(height: 12),
              ..._instructionSteps.asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4A7C5F),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${entry.key + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: const TextStyle(
                            color: Color(0xFF3D463F),
                            fontSize: 14,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 6),
              const Text(
                'Choose one of the working memory tasks below and start!',
                style: TextStyle(
                  color: Color(0xFF2E3E32),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassItem(
    String title,
    String subtitle,
    String imagePath,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(
                      imagePath,
                      width: 65,
                      height: 65,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E3E32),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 14,
                            color: Colors.grey,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const CircleAvatar(
                    radius: 14,
                    backgroundColor: Color(0xFF4A7C5F),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
