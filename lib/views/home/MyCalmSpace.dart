import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jonssony/utils/AppIcons/app_icons.dart';
import 'package:jonssony/utils/app_colors.dart';
import 'package:jonssony/views/Library/ACalmPage.dart';
import 'package:jonssony/views/chatbot/SessionFourPage.dart';
import 'package:jonssony/views/home/act.dart';
import 'package:jonssony/widets/navbar.dart';
import 'package:jonssony/views/home/VideoCalmPage.dart';
import 'package:jonssony/utils/app_text.dart';
import 'AudioCalmPage.dart';

class MyCalmSpace extends StatelessWidget {
  const MyCalmSpace({super.key});

  @override
  Widget build(BuildContext context) {
    const double appBarImageHeight = 180;
    const double overlapAmount = 5;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: appBarImageHeight,
            child: Image.asset(
              'assets/images/my_emdr.png',
              fit: BoxFit.fill,
            ),
          ),

          Column(
            children: [

              _buildCalmAppBar(context),

              Expanded(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [

                    Positioned.fill(
                      top: -overlapAmount,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
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


                    Positioned.fill(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 40),
                            _buildThoughtsCard(
                              child: Column(
                                children: [
                                  _buildExerciseItem(Icons.description_outlined, "ACT Thoughts Exercise", "Text",
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                            const act()),
                                      );
                                    },),
                                  _buildExerciseItem(
                                    Icons.play_circle_outline,
                                    "ACT Thoughts Exercise",
                                    "Video",
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                            const VideoCalmPage()),
                                      );
                                    },
                                  ),
                                  _buildExerciseItem(
                                    Icons.music_note_outlined,
                                    "ACT Thoughts Exercise",
                                    "Audio",
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const ACalmPage()),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 150),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // // Custom NavBar
          // CustomNavBar(
          //   currentIndex: 0,
          //   onTap: (index) => _handleNavigation(context, index),
          //   primaryColor: AppColors.mainAppColor,
          // ),
        ],
      ),
    );
  }

  // void _handleNavigation(BuildContext context, int index) {
  //   switch (index) {
  //     case 0:
  //       // Go back to Home - just pop this page
  //       Navigator.pop(context);
  //       break;
  //     case 1:
  //       // Navigate to Progress
  //       Navigator.pushReplacementNamed(context, '/progress');
  //       break;
  //     case 2:
  //       // Navigate to Library
  //       Navigator.pushReplacementNamed(context, '/library');
  //       break;
  //     case 3:
  //       // Navigate to Profile
  //       Navigator.pushReplacementNamed(context, '/profile');
  //       break;
  //   }
  // }

  Widget _buildCalmAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        left: 10,
        right: 20,
        bottom: 10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF2E3E32)),
                onPressed: () => Navigator.pop(context),
              ),
              const AppText(
                "My Calm Space",
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E3E32),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThoughtsCard({Widget? child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.4),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 12,
                    backgroundImage: AssetImage('assets/images/emdr_sun.jpg'),
                  ),
                  const SizedBox(width: 8),
                  AppText(
                    "Thoughts",
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black.withOpacity(0.7),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const AppText(
                "Creating distance from our thoughts helps us see them clearly.",
                fontSize: 13,
                color: Colors.black54,
              ),
              if (child != null) ...[
                const SizedBox(height: 20),
                child,
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseItem(IconData icon, String title, String type, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.35),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: Colors.black87, size: 24),
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        title,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      const SizedBox(height: 4),
                      AppText(
                        type,
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ],
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