import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:jonssony/widets/Custom_BackgroundDesign.dart';
import 'package:jonssony/widets/custom_appbar.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
         BackgroundDesign(),


          Column(
            children: [
              Custom_AppBar(context, "Privacy Policy"),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                  child: Column(
                    children: [
                   SizedBox(height: 120),
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
                                Text(
                                  "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF2E3E32),
                                    height: 1.5,
                                  ),
                                ),
                                SizedBox(height: 25),

                                // Section 1
                                Text(
                                  "Data Collection",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2E3E32),
                                    fontFamily: 'Serif',
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident.",
                                  style: TextStyle(fontSize: 14, color: Color(0xFF2E3E32), height: 1.4),
                                ),

                                SizedBox(height: 25),

                                // Section 2
                                Text(
                                  "How We Use Information",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2E3E32),
                                    fontFamily: 'Serif',
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "Sunt in culpa qui officia deserunt mollit anim id est laborum. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur sodales ligula in libero.",
                                  style: TextStyle(fontSize: 14, color: Color(0xFF2E3E32), height: 1.4),
                                ),

                                SizedBox(height: 25),

                                // Section 3
                                Text(
                                  "Security",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2E3E32),
                                    fontFamily: 'Serif',
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "Sed dignissim lacinia nunc. Curabitur tortor. Pellentesque nibh. Aenean quam. In scelerisque sem at dolor. Maecenas mattis. Lorem ipsum dolor sit amet.",
                                  style: TextStyle(fontSize: 14, color: Color(0xFF2E3E32), height: 1.4),
                                ),

                                SizedBox(height: 20),
                                Text(
                                  "Last updated: October 2023",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.black54,
                                  ),
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