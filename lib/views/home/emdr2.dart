import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:jonssony/views/home/StroopTestScreen.dart';
import 'package:jonssony/views/home/TetrisGameScreen.dart';
import 'package:jonssony/views/home/battleship.dart';
import 'package:jonssony/views/home/spelling.dart';

class emdr extends StatefulWidget {
  const emdr({super.key});

  @override
  State<emdr> createState() => _emdrState();
}

class _emdrState extends State<emdr> {
  bool isBlurred = false;

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
            child: Image.asset(
              'assets/images/my_emdr.png',
              fit: BoxFit.cover,
            ),
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
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                          image: DecorationImage(
                            image: const AssetImage('assets/images/bg_library.jpg'),
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

                            // --- Backwards Challenge (Spelling & Counting) ---
                            _buildGlassItem(
                                "Battleship",
                                "Locate hidden ships on a grid. Strategic thinking engages your working memory.",
                                'assets/images/behaviour_img.jpg',
                                    () => Navigator.push(context, MaterialPageRoute(builder: (context) => const GameScreenN(mode: 'counting', difficulty: 'medium')))
                            ),

                            // --- The Stroop Test ---
                            _buildGlassItem(
                                "Stroop Test",
                                "Locate hidden ships on a grid. Strategic thinking engages your working memory.",
                                'assets/images/thoughts_img.jpg',
                                    () => Navigator.push(context, MaterialPageRoute(builder: (context) => const StroopTestScreen()))
                            ),

                            // --- Pattern Memory ---
                            _buildGlassItem(
                                "Pattern Memory",
                                "Locate hidden ships on a grid. Strategic thinking engages your working memory.",
                                'assets/images/behaviour_img.jpg',
                                    () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PatternMemoryGame()))
                            ),

                            // --- Watercolor Tetris ---
                            _buildGlassItem(
                                "Tetris",
                                "Locate hidden ships on a grid. Strategic thinking engages your working memory.",
                                'assets/images/emotions_img.jpg',
                                    () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TetrisGameScreen()))
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

          // if (isBlurred)
          //   Positioned.fill(
          //     child: BackdropFilter(
          //       filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          //       child: Container(
          //         color: Colors.black.withOpacity(0.4),
          //         child: Center(
          //           child: Column(
          //             mainAxisSize: MainAxisSize.min,
          //             children: [
          //               const Text(
          //                 "Resting the mind...",
          //                 style: TextStyle(
          //                     color: Colors.white,
          //                     fontSize: 24,
          //                     fontFamily: 'Georgia',
          //                     fontStyle: FontStyle.italic
          //                 ),
          //               ),
          //               const SizedBox(height: 20),
          //               ElevatedButton(
          //                 onPressed: () => setState(() => isBlurred = false),
          //                 style: ElevatedButton.styleFrom(
          //                   backgroundColor: const Color(0xFF4A7C5F),
          //                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          //                   padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          //                 ),
          //                 child: const Text("Continue Session", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          //               ),
          //             ],
          //           ),
          //         ),
          //       ),
          //     ),
          //   ),
        ],
      ),

      // // ৫. ফ্লোটিং অ্যাকশন বাটন (মোড টগল)
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => setState(() => isBlurred = !isBlurred),
      //   backgroundColor: const Color(0xFF4A7C5F),
      //   child: Icon(isBlurred ? Icons.visibility : Icons.visibility_off, color: Colors.white),
      // ),
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
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new, size: 20, color: Color(0xFF2E3E32)),
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
  Widget _buildGlassItem(String title, String subtitle, String imagePath, VoidCallback onTap) {
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
                color: Colors.white.withOpacity(0.55),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(imagePath, width: 65, height: 65, fit: BoxFit.cover),
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
                          style: TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 14,
                              color: Colors.grey,
                              height: 1.2
                          ),
                        ),
                      ],
                    ),
                  ),
                  const CircleAvatar(
                    radius: 14,
                    backgroundColor: Color(0xFF4A7C5F),
                    child: Icon(Icons.arrow_forward_ios, size: 12, color: Colors.white),
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