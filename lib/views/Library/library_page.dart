import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:jonssony/utils/app_colors.dart';
import 'package:jonssony/utils/app_text.dart';


class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    const double appBarImageHeight = 150;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [

          Positioned(
            top: 0, left: 0, right: 0, height: appBarImageHeight,
            child: Image.asset(
              'assets/images/my_emdr.png',
              fit: BoxFit.fill,
            ),
          ),

          Column(
            children: [
              _buildAppBarContent(context),
              SizedBox(height: 20),

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
                          children: [
                            const SizedBox(height: 30),


                            _buildResourceCard(
                              "Calm Place Exercise",
                              "Access your saved safe place audio visualization.",
                              Icons.anchor,
                              const Color(0xFFC4FCEF),
                              const Color(0xFF537E5D),
                            ),

                            _buildResourceCard(
                              "Bilateral Settings",
                              "Customize your visual and audio stimulation preferences.",
                              Icons.settings_outlined,
                              const Color(0xFFF3F3F3),
                              Colors.black54,
                            ),

                            _buildResourceCard(
                              "My Story",
                              "Access your saved safe place audio visualization.",
                              Icons.menu_book_outlined,
                              const Color(0xFFFFF7CF),
                              const Color(0xFFAD8C63),
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


  Widget _buildAppBarContent(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 10,
      ),
      child: Row(
        children: [
          const SizedBox(width: 15),
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

  Widget _buildResourceCard(
      String title,
      String desc,
      IconData icon,
      Color boxColor,
      Color iconColor
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
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

                    const Icon(Icons.play_circle_outline, color: Colors.black87, size: 28),
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

                GestureDetector(
                  onTap: () {},
                  child: const AppText(
                    "Listen Now",
                    fontSize: 14,
                    color: AppColors.mainAppColor,
                    decorationColor: AppColors.mainAppColor,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
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