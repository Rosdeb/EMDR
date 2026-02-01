import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jonssony/utils/AppIcons/app_icons.dart';
import 'package:jonssony/utils/app_colors.dart';
import 'package:jonssony/views/home/VideoCalmPage.dart';
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
                                  _buildExerciseItem(Icons.description_outlined, "ACT Thoughts Exercise", "Text"),
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
                                                const AudioCalmPage()),
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

          _buildFloatingBottomNav(AppColors.mainAppColor),
        ],
      ),
    );
  }

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
              const Text(
                "My Calm Space",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E3E32),
                  fontFamily: 'Inter',
                ),
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
                  Text(
                    "Thoughts",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black.withOpacity(0.7)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                "Creating distance from our thoughts helps us see them clearly.",
                style: TextStyle(fontSize: 13, color: Colors.black54, height: 1.4),
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
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Serif'),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        type,
                        style: const TextStyle(fontSize: 12, color: Colors.black54),
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


  Widget _buildFloatingBottomNav(Color primaryColor) {
    return Positioned(
      bottom: 25,
      left: 15,
      right: 15,
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  height: 75,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _navItem(AppIcons.home, "Home", true, const Color(0xFF537E5D)),
                      _navItem(AppIcons.progress_nav, "", false, primaryColor),
                      _navItem(AppIcons.library, "", false, primaryColor),
                      _navItem(AppIcons.profile, "", false, primaryColor),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            height: 70,
            width: 70,
            decoration: const BoxDecoration(
              color: Color(0xFF537E5D),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 35),
          ),
        ],
      ),
    );
  }

  Widget _navItem(String iconPath, String label, bool isActive, Color activeColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: isActive ? BoxDecoration(
        color: activeColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(30),
      ) : null,
      child: Row(
        children: [
          SvgPicture.asset(
            iconPath,
            height: 24,
            colorFilter: ColorFilter.mode(isActive ? activeColor : Colors.black45, BlendMode.srcIn),
          ),
          if (isActive) const SizedBox(width: 6),
          if (isActive) Text(label, style: TextStyle(color: activeColor, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}