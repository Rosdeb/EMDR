
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jonssony/utils/app_colors.dart';
import 'package:jonssony/utils/app_text.dart';
import 'package:jonssony/views/Library/bilateral_settings.dart';
import 'package:jonssony/views/Library/clam_space_ex.dart';
import 'package:jonssony/views/Library/settings_screen.dart';
import 'package:jonssony/views/home/act.dart';
import 'package:jonssony/views/home/cbt.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    const double appBarImageHeight = 170;

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
              fit: BoxFit.cover,
            ),
          ),

          Column(
            children: [
              _buildAppBar(context),
              const SizedBox(height: 20),

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

                    /// SCROLL
                    Positioned.fill(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            const SizedBox(height: 30),

                            _resourceCard(
                              title: "Calm Place Exercise",
                              desc:
                              "Access your saved safe place audio visualization.",
                              icon: Icons.anchor,
                              boxColor: const Color(0xFFC4FCEF),
                              iconColor: const Color(0xFF537E5D),
                              onTap: () {
                                Get.to(() => MyCalmSpaceExercise ());
                              },
                            ),

                            _resourceCard(
                              title: "Bilateral Settings",
                              desc:
                              "Customize your visual and audio stimulation preferences.",
                              icon: Icons.settings_outlined,
                              boxColor: const Color(0xFFF3F3F3),
                              iconColor: Colors.black54,
                              onTap: () {
                                Get.to(() => SettingsScreen());
                              },
                            ),

                            _resourceCard(
                              title: "My Story",
                              desc:
                              "Access your saved safe place audio visualization.",
                              icon: Icons.menu_book_outlined,
                              boxColor: const Color(0xFFFFF7CF),
                              iconColor: const Color(0xFFAD8C63),
                              onTap: () {
                                Get.to(() => cbt());
                              },
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
        ],
      ),
    );
  }
                       //// Appbar ///
  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 16,
        right: 16,
      ),
      child: Row(
        children: [

          // /// 🔙 BLUR BACK BUTTON
          // ClipRRect(
          //   borderRadius: BorderRadius.circular(14),
          //   child: BackdropFilter(
          //     filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          //     child: InkWell(
          //       onTap: () => Get.back(),
          //       child: Container(
          //         padding: const EdgeInsets.all(10),
          //         decoration: BoxDecoration(
          //           color: Colors.white.withOpacity(0.35),
          //           borderRadius: BorderRadius.circular(14),
          //           border: Border.all(
          //             color: Colors.white.withOpacity(0.3),
          //           ),
          //         ),
          //         child: const Icon(
          //           Icons.arrow_back_ios_new,
          //           size: 18,
          //           color: Color(0xFF2E3E32),
          //         ),
          //       ),
          //     ),
          //   ),
          // ),

          const SizedBox(width: 14),

          const AppText(
            "My Resources",
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E3E32),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // RESOURCE CARD
  // ---------------------------------------------------------------------------

  Widget _resourceCard({
    required String title,
    required String desc,
    required IconData icon,
    required Color boxColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(25),
            child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.4),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: boxColor,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(icon, color: iconColor, size: 28),
                    ),
                    const Icon(
                      Icons.play_circle_outline,
                      size: 28,
                      color: Colors.black87,
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                AppText(
                  title,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2E3E32),
                ),

                const SizedBox(height: 10),

                AppText(
                  desc,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),

                const SizedBox(height: 20),

                const AppText(
                  "Listen Now",
                  fontSize: 14,
                  color: AppColors.mainAppColor,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.mainAppColor,
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
