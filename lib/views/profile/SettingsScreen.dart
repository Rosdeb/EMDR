import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jonssony/views/profile/AboutUsScreen.dart';
import 'package:jonssony/views/profile/ChangePasswordScreen.dart';
import 'package:jonssony/views/profile/HelpScreen.dart';
import 'package:jonssony/views/profile/PrivacyPolicyScreen.dart';
import 'package:jonssony/views/profile/TermsOfServiceScreen.dart';
import 'package:jonssony/widets/Custom_BackgroundDesign.dart';
import 'package:jonssony/widets/custom_appbar.dart';

import 'package:jonssony/views/profile/SupportRequestScreen.dart';
import 'package:jonssony/utils/app_text.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> settingsMenu = [
      {
        "title": "Change Password",
        "route": () => const SettingChangePasswordScreen(),
      },
      {"title": "About Us", "route": () => const AboutUsScreen()},
      {"title": "Help", "route": () => const HelpScreen()},
      {
        "title": "Support Requests",
        "route": () => const SupportRequestScreen(),
      },
      {"title": "Privacy Policy", "route": () => const PrivacyPolicyScreen()},
      {
        "title": "Terms of service",
        "route": () => const TermsOfServiceScreen(),
      },
    ];

    return Scaffold(
      body: Stack(
        children: [
          BackgroundDesign(),
          Column(
            children: [
              Custom_AppBar(context, "Settings"),
              SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      SizedBox(height: 150),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              children: settingsMenu.map((item) {
                                int index = settingsMenu.indexOf(item);
                                return Column(
                                  children: [
                                    ListTile(
                                      title: AppText(
                                        item["title"],
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                        color: Color(0xFF2E3E32),
                                      ),
                                      trailing: const Icon(
                                        Icons.arrow_forward_ios,
                                        size: 16,
                                      ),
                                      onTap: () {
                                        Get.to(item["route"]);
                                      },
                                    ),
                                    if (index != settingsMenu.length - 1)
                                      Divider(
                                        color: Colors.white.withOpacity(0.2),
                                        indent: 20,
                                        endIndent: 20,
                                        height: 1,
                                      ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // // Delete Account Button
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
              //   child: SizedBox(
              //     width: double.infinity,
              //     height: 55,
              //     child: ElevatedButton.icon(
              //       onPressed: () {
              //         // Delete account logic ba dialog
              //       },
              //       icon: SvgPicture.asset(
              //         'assets/icons/delete.svg',
              //         color: Colors.white,
              //         height: 24,
              //         width: 24,
              //       ),
              //       label: const AppText("Delete Account", color: Colors.white),
              //       style: ElevatedButton.styleFrom(
              //           backgroundColor: const Color(0xFF4F7957),
              //           elevation: 0,
              //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
              //       ),
              //     ),
              //   ),
              // )
            ],
          ),
        ],
      ),
    );
  }
}
