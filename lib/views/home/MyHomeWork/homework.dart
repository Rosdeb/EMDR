import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jonssony/views/profile/Subscription.dart';

import 'BehaviourScreen.dart';
import 'Thoughts.dart';
import 'emotion_start.dart';

class MyHomework extends StatefulWidget {
  const MyHomework({super.key});

  @override
  State<MyHomework> createState() => _MyHomeworkState();
}

class _MyHomeworkState extends State<MyHomework> {
  bool isOverlayVisible = false;

  Future<void> _onStartHealing() async {
    await Get.to(() => SubscriptionScreen());
    setState(() {
      isOverlayVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    const double appBarHeight = 64;
    final double appBarBottom = statusBarHeight + appBarHeight;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ── 1) Top header image (my_emdr.png) ──────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 180,
            child: Image.asset('assets/images/my_emdr.png', fit: BoxFit.cover),
          ),

          // ── 2) bg_library.jpg — starts below top image, rounded top corners ─
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
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

          // ── 3) Scrollable cards (sits on top of bg) ─────────────────────────
          Positioned(
            top: appBarBottom,
            left: 0,
            right: 0,
            bottom: 0,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
              child: Column(
                children: [
                  _resourceCard(
                    title: "Behaviours",
                    desc: "Transform what you're doing or not doing",
                    image: 'assets/images/behaviour_img.jpg',
                    onTap: (){
                      Get.to(BehaviourScreen());
                    }
                  ),
                  _resourceCard(
                    title: "Thoughts",
                    desc: "Understanding and reshaping your thinking",
                    image: 'assets/images/thoughts_img.jpg',
                    onTap: (){
                      Get.to(CalmExercise());
                    }
                  ),
                  _resourceCard(
                    title: "Emotions",
                    desc: "Tools to manage bigger emotions",
                    image: 'assets/images/emotions_img.jpg',
                    onTap: (){
                      Get.to(EmotionStartScreen());
                      }
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          // ── 4) Blur overlay — ONLY below AppBar, never touches AppBar ───────
          if (isOverlayVisible)
            Positioned(
              top: appBarBottom,
              left: 0,
              right: 0,
              bottom: 0,
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(color: Colors.white.withOpacity(0.18)),
                ),
              ),
            ),

          // ── 5) Start Healing button — centered in blurred area ───────────────
          if (isOverlayVisible)
            Positioned(
              top: appBarBottom,
              left: 0,
              right: 0,
              bottom: 0,
              child: Center(
                child: ElevatedButton(
                  onPressed: _onStartHealing,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    elevation: 10,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    "Start Healing",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),

          // ── 6) AppBar — always on top, always clear (no blur) ───────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: appBarBottom,
            child: _buildAppBar(context, statusBarHeight),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // AppBar — clear, no blur, my_homework.png on right
  // ---------------------------------------------------------------------------

  Widget _buildAppBar(BuildContext context, double statusBarHeight) {
    return Container(
      color: Colors.transparent, // fully transparent — no blur
      padding: EdgeInsets.only(top: statusBarHeight, left: 4, right: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF2E3E32)),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            "Homework",
            style: TextStyle(
              color: Color(0xFF2E3E32),
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Resource Card
  // ---------------------------------------------------------------------------

  Widget _resourceCard({
    required String title,
    required String desc,
    required String image,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 25),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.6)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              child: Row(
                children: [
                  // Circular image
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: AssetImage(image),
                    ),
                  ),

                  const SizedBox(width: 18),

                  // Text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E3E32),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          desc,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF537E5D),
                    size: 26,
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
