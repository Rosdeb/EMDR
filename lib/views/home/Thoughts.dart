import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jonssony/views/Library/ACalmPage.dart';
import 'package:jonssony/views/Library/VCalmPage1.dart';
import 'package:jonssony/views/Library/VCalmPage2.dart';

class CalmExercise extends StatefulWidget {
  const CalmExercise({super.key});

  @override
  State<CalmExercise> createState() => _CalmExerciseState();
}

class _CalmExerciseState extends State<CalmExercise> {
  // ✅ Track how many steps are unlocked (starts at 1 — only first is open)
  int _unlockedUpTo = 0; // index: 0 = 1st unlocked

  final List<Map<String, dynamic>> _exercises = [
    {
      'icon': Icons.play_arrow_rounded,
      'title': 'spiral_technique.mp4',
      'type': 'Video',
    },
    {
      'icon': Icons.play_arrow_rounded,
      'title': 'Light_stream.mp4',
      'type': 'Video',
    },
    {
      'icon': Icons.music_note_rounded,
      'title': 'Calm place.wav',
      'type': 'Audio',
    },
  ];

  /// Navigate to the correct page based on index.
  /// After returning, if the page signals completion (returns true),
  /// unlock the next step.
  Future<void> _handleTap(int index) async {
    Widget? page;

    if (index == 0) {
      page = VCalmPage1();
    } else if (index == 1) {
      page = VCalmPage2();
    } else if (index == 2) {
      page = ACalmPage();
    }

    if (page == null) return;

    // Wait for the page to return a result.
    // The child page should call Get.back(result: true) when video/audio ends.
    final result = await Get.to(() => page!);

    if (result == true) {
      // Unlock the next step
      setState(() {
        if (_unlockedUpTo == index && index < _exercises.length - 1) {
          _unlockedUpTo = index + 1;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Top header image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 180,
            child: Image.asset(
              'assets/images/my_emdr.png',
              fit: BoxFit.fill,
            ),
          ),

          // Background
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.only(top: 100),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(35),
                  topRight: Radius.circular(35),
                ),
                image: DecorationImage(
                  image: AssetImage('assets/images/bg_library.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Overlay
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.only(top: 150),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(35),
                  topRight: Radius.circular(35),
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAppBar(),
                const SizedBox(height: 70),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    physics: const BouncingScrollPhysics(),
                    itemCount: _exercises.length,
                    itemBuilder: (context, index) {
                      final item = _exercises[index];
                      final bool locked = index > _unlockedUpTo;
                      final bool completed = index < _unlockedUpTo;

                      return _buildExerciseItem(
                        icon: item['icon'] as IconData,
                        title: item['title'] as String,
                        type: item['type'] as String,
                        locked: locked,
                        completed: completed,
                        onTap: locked
                            ? () => _showLockedDialog()
                            : () => _handleTap(index),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // APP BAR
  // ---------------------------------------------------------------------------

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF4A4A4A)),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            'Calm Place Exercise',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Color(0xFF4A4A4A),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // EXERCISE ITEM
  // ---------------------------------------------------------------------------

  Widget _buildExerciseItem({
    required IconData icon,
    required String title,
    required String type,
    required bool locked,
    required bool completed,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: GestureDetector(
            onTap: onTap,
            child: Opacity(
              opacity: locked ? 0.55 : 1.0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: completed
                      ? const Color(0xFFC4FCEF).withOpacity(0.6) // green tint for done
                      : const Color(0xFFE6E7D9).withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: completed
                        ? const Color(0xFF537E5D).withOpacity(0.4)
                        : Colors.white.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    // Icon circle
                    Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color: completed
                            ? const Color(0xFF537E5D)
                            : locked
                            ? Colors.grey.shade300
                            : Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        completed
                            ? Icons.check_rounded
                            : locked
                            ? Icons.lock_rounded
                            : icon,
                        color: completed
                            ? Colors.white
                            : locked
                            ? Colors.grey.shade500
                            : Colors.black87,
                        size: 26,
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: locked
                                  ? const Color(0xFF7A7A7A)
                                  : const Color(0xFF3E433E),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            type,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Right badge
                    if (locked)
                      _badge(
                        icon: Icons.lock_rounded,
                        label: 'Locked',
                        bgColor: Colors.black.withOpacity(0.08),
                        textColor: const Color(0xFF7A7A7A),
                      ),
                    if (completed)
                      _badge(
                        icon: Icons.check_circle_rounded,
                        label: 'Done',
                        bgColor: const Color(0xFF537E5D).withOpacity(0.15),
                        textColor: const Color(0xFF537E5D),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _badge({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // LOCKED DIALOG
  // ---------------------------------------------------------------------------

  void _showLockedDialog() {
    showDialog(
      context: context,
      builder: (_) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: Colors.white.withOpacity(0.95),
          contentPadding: const EdgeInsets.fromLTRB(28, 28, 28, 20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF7CF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_rounded,
                    size: 36, color: Color(0xFFAD8C63)),
              ),
              const SizedBox(height: 16),
              const Text(
                'Content Locked',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E3E32),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Complete the previous exercise first to unlock this content.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A7C5F),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  child: const Text(
                    'Got it',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600),
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