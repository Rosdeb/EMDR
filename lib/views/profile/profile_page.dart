import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:jonssony/views/profile/ProfileDetailScreen.dart';
import 'package:jonssony/views/profile/SettingsScreen.dart';
import 'package:jonssony/views/profile/Subscription.dart';
import 'package:jonssony/views/profile/permission.dart';
import 'package:jonssony/utils/app_text.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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
              _buildAppBar(context),
              SizedBox(height: 20),
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
                            image: AssetImage('assets/images/bg_profile.jpg'),
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
                            _buildMainProfileCard(),
                            const SizedBox(height: 25),
                            _buildSettingsGroup([
                              _settingsTile(Icons.person_outline, "Profile", () {
                                Get.to(() => ProfileDetailScreen());
                              }),
                              _settingsTile(Icons.assignment_outlined, "Subscription Offer", () {
                                Get.to(() => SubscriptionScreen());
                              }),
                            ]),

                            const SizedBox(height: 20),


                            _buildSettingsGroup([
                              _settingsTile(Icons.check_circle_outline, "Permission", () {
                                Get.to(() => PermissionScreen());
                              }),
                              _settingsTile(Icons.settings_outlined, "Settings", () {
                                Get.to(() => SettingsScreen());
                              }),
                            ]),

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


  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, left: 10),
      child: Row(
        children: [
          const SizedBox(width: 15),
          const AppText(
            "Profile",
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E3E32),
          ),
        ],
      ),
    );
  }


  Widget _buildMainProfileCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 35,
                backgroundImage: AssetImage('assets/images/home_profile.png'),
              ),
              const SizedBox(width: 15),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      "Anaya Sharma",
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2E3E32),
                    ),
                    AppText(
                      "Member since Nov 2025",
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),

              GestureDetector(
                onTap: () {

                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: const Icon(Icons.logout, color: Colors.black87, size: 24),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildSettingsGroup(List<Widget> tiles) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.4),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(children: tiles),
        ),
      ),
    );
  }


  Widget _settingsTile(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.white12, width: 0.5)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.black87, size: 24),
            const SizedBox(width: 15),
            Expanded(
              child: AppText(
                title,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black54),
          ],
        ),
      ),
    );
  }


}