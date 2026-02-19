import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jonssony/utils/app_colors.dart';
import 'package:jonssony/views/home/InKindChatBot.dart';


class BehaviourScreen extends StatelessWidget {
  const BehaviourScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 150,
            child: Image.asset('assets/images/my_emdr.png', fit: BoxFit.fill),
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
                            topLeft: Radius.circular(35),
                            topRight: Radius.circular(35),
                          ),
                          image: DecorationImage(
                            image: AssetImage('assets/images/bg_progress.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),

                    SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 70),


                          _buildIntroGlassCard(),

                          const SizedBox(height: 25),

                          _buildActionGlassSection(),

                          const SizedBox(height: 100),
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

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 10,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF2E3E32)),
            onPressed: () => Get.back(),
          ),
          const Text(
            "Behaviour",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E3E32),
            ),
          ),
        ],
      ),
    );
  }

  // ইন্ট্রো কার্ড - গ্লাস মরফিজম স্টাইল
  Widget _buildIntroGlassCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Color(0xFFECFDF5),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.8),
                    child: const Icon(Icons.psychology, color: AppColors.mainAppColor),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Why Behaviour Matters",
                    style: TextStyle(fontSize: 16, color: AppColors.mainAppColor , fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                "Understanding and changing ourbehaviour patterns is one of the most powerful tools we have for improving our wellbeing. Small, intentional changes in what we do can create ripple effects across how we think and feel.",
                style: TextStyle(fontSize: 14, color: AppColors.mainAppColor ,height: 1.4, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildActionGlassSection() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.35),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              // 'Make A New Homework' Button
              ElevatedButton.icon(
                onPressed: () {
                  Get.to(() =>InKindChatBot());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF537E5D), // Progress Page এর গ্রাফ কালার
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 0,
                ),
                icon: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 24,
                ),
                label: const Text(
                  'Make A New Homework',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 30),

              // Empty State Inside the Glass Box
              Container(
                padding: const EdgeInsets.symmetric(vertical: 30),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    Icon(Icons.history_toggle_off, color: Colors.black38, size: 45),
                    const SizedBox(height: 10),
                    const Text(
                      'No started homeworks yet',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Text(
                        'Your behaviour exercises will appear here.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.black45),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}