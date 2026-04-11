import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jonssony/healper/route.dart';
import 'package:jonssony/views/home/BehaviourScreen.dart';
import 'package:jonssony/views/home/emdr2.dart';
import 'package:jonssony/views/home/InKindChatBot.dart';
import 'package:jonssony/views/home/Thoughts.dart';
import 'package:jonssony/views/home/emotion_start.dart';

class MyHomeworkPri extends StatelessWidget {
  const MyHomeworkPri({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2E3E32)),
          onPressed: () {
            Get.offAllNamed(RouteHelper.main);
          },
        ),
        title: const Text(
          "My Resources",
          style: TextStyle(
            color: Color(0xFF2E3E32),
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Stack(
        children: [
// Custom_AppBar(context, "My Resourc"),
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg_library.jpg',
              fit: BoxFit.cover,
            ),
          ),


          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
              child: Column(
                children: [
                  _buildResourceCard(
                    "Behaviours",
                    "Transform what you're doing or not doing",
                    'assets/images/behaviour_img.jpg',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => BehaviourScreen()),
                      );
                    },
                  ),
                  _buildResourceCard(
                    "Thoughts",
                    "Understanding and reshaping your thinking",
                    'assets/images/thoughts_img.jpg',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CalmExercise()),
                      );
                    },
                  ),
                  _buildResourceCard(
                    "Emotions",
                    "Tools to manage bigger emotions",
                    'assets/images/emotions_img.jpg',
                    onTap: () {
                      Navigator.push(
                        context,
                        // MaterialPageRoute(builder: (context) => const EmotionBodyMap()),
                        // MaterialPageRoute(builder: (context) => EmotionsScreen()),
                        MaterialPageRoute(builder: (context) => EmotionStartScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceCard(String title, String desc, String imagePath, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 25),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.transparent,
                backgroundImage: AssetImage(imagePath),
              ),
              const SizedBox(height: 25),


              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4A4A4A),
                ),
              ),
              const SizedBox(height: 12),


              Text(
                desc,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6A6A6A),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}