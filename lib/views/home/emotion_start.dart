import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jonssony/views/Library/ACalmPage.dart';
import 'package:jonssony/views/Library/VCalmPage1.dart';
import 'package:jonssony/views/home/EmotionBodyMap.dart';
import 'package:jonssony/views/home/emdr2.dart';


class EmotionStartScreen extends StatefulWidget {
  const EmotionStartScreen({super.key});

  @override
  State<EmotionStartScreen> createState() => _EmotionStartScreenState();
}

class _EmotionStartScreenState extends State<EmotionStartScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [

          Positioned.fill(
            child: Image.asset(
              'assets/images/bg_library.jpg',
              fit: BoxFit.cover,
            ),
          ),


          SafeArea(
            child: Column(
              children: [
                _buildCustomAppBar(),
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeIn,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                      child: Column(
                        children: [
                          _buildModernCard(
                            category: "AUDIO",
                            icon: Icons.music_note,
                            title: "Spiral Technique",
                            desc: "A grounding technique to help when emotions feel overwhelming.",
                            onTap: () {
Get.to(() => ACalmPage());
                            },
                          ),
                          _buildModernCard(
                            category: "VIDEO",
                            icon: Icons.play_circle_fill,
                            title: "Hunder and Lightning",
                            desc: "A grounding technique to help when emotions feel overwhelming.",
                            onTap: () {
                              Get.to(() => VCalmPage());
                            },
                          ),
                          _buildModernCard(
                            category: "EMDR",
                            icon: Icons.layers,
                            title: "EMDR 2.0",
                            desc: "A grounding technique to help when emotions feel overwhelming.",
                            onTap: () {
                              Get.to(() => emdr());
                            },
                          ),
                          _buildModernCard(
                            category: "DRAWING",
                            icon: Icons.draw_sharp,
                            title: "Emotion Drawing exercise",
                            desc: "A grounding technique to help when emotions feel overwhelming.",
                            onTap: () {
                              Get.to(() => EmotionBodyMap());
                            },
                          ),
                        ],
                      ),
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

  // কাস্টম অ্যাপ বার (ইমেজের মতো ক্লিন লুক)
  Widget _buildCustomAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF2E3E32)),
            onPressed: () => Get.back(),
          ),
          const Text(
            'Emotions',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E3E32),
              fontFamily: 'Georgia', // ইমেজের মতো স্টাইল
            ),
          ),
        ],
      ),
    );
  }

  // ইমেজের ডিজাইনের সাথে মিল রেখে কার্ড উইজেট
  Widget _buildModernCard({
    required String category,
    required IconData icon,
    required String title,
    required String desc,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95), // হালকা ট্রান্সপারেন্সি যাতে ব্যাকগ্রাউন্ডের ফিল পাওয়া যায়
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ব্যাজ (ইমেজের মতো ডিজাইন)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F1EC),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(icon, size: 14, color: const Color(0xFF4A7C5F)),
                            const SizedBox(width: 6),
                            Text(
                              category,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4A7C5F),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // টাইটেল
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E3E32),
                        ),
                      ),
                      const SizedBox(height: 6),
                      // ডেসক্রিপশন
                      Text(
                        desc,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black.withOpacity(0.6),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),

                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.grey,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}