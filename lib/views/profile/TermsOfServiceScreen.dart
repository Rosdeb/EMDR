import 'dart:ui';
import 'package:flutter/material.dart';

import '../../widets/Custom_BackgroundDesign.dart';
import '../../widets/Custom_BackgroundDesign.dart';
import '../../widets/custom_appbar.dart';
import 'package:jonssony/utils/app_text.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BackgroundDesign(),
          Column(
            children: [
             Custom_AppBar(context, "Terms of service"),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                  child: Column(
                    children: [
                 SizedBox(height: 100),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText(
                                  "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
                                  fontSize: 14,
                                  color: Color(0xFF2E3E32),

                                ),
                                SizedBox(height: 25),

                                // Section 1
                                AppText(
                                  "Our Mission",
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2E3E32),
                                ),
                                SizedBox(height: 10),
                                AppText(
                                  "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer nec odio. Praesent libero. Sed cursus ante dapibus diam. Sed nisi. Nulla quis sem at nibh elementum imperdiet.",
                                  fontSize: 14, color: Color(0xFF2E3E32),
                                ),

                                SizedBox(height: 25),

                                // Section 2
                                AppText(
                                  "Our Vision",
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2E3E32),
                                ),
                                SizedBox(height: 10),
                                AppText(
                                  "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur sodales ligula in libero. Sed dignissim lacinia nunc. Curabitur tortor. Pellentesque nibh. Aenean quam. In scelerisque sem at dolor. Maecenas mattis.",
                                  fontSize: 14, color: Color(0xFF2E3E32),
                                ),

                                SizedBox(height: 25),

                                // Section 3
                                AppText(
                                  "Why Choose Us",
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2E3E32),
                                ),
                                SizedBox(height: 10),
                                AppText(
                                  "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin quam. Etiam ultrices. Suspendisse in justo eu magna luctus suscipit. Sed lectus.",
                                  fontSize: 14, color: Color(0xFF2E3E32),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // --- Card End ---
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}