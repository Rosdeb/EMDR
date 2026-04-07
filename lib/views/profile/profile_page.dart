import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jonssony/controller/auth_controller.dart'; // Added missing import
import 'package:jonssony/controller/profile_controller.dart';
import 'package:jonssony/views/profile/ProfileDetailScreen.dart';
import 'package:jonssony/views/profile/SettingsScreen.dart';
import 'package:jonssony/views/profile/Subscription.dart';
import 'package:jonssony/views/profile/permission.dart';
import 'package:jonssony/utils/app_text.dart';
import 'package:intl/intl.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject Controller
    final profileController = Get.put(ProfileController());
    const double appBarImageHeight = 150;

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
              _buildAppBar(context),
              const SizedBox(height: 20),
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
                            Obx(() {
                              if (profileController.isLoading.value &&
                                  profileController.userProfile.isEmpty) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              return _buildMainProfileCard(profileController);
                            }),
                            const SizedBox(height: 25),
                            _buildSettingsGroup([
                              _settingsTile(Icons.person_outline, "Profile", () {
                                Get.to(() => const ProfileDetailScreen());
                              }),
                              _settingsTile(
                                  Icons.assignment_outlined, "Subscription Offer",
                                  () {
                                Get.to(() => SubscriptionScreen());
                              }),
                            ]),
                            const SizedBox(height: 20),
                            _buildSettingsGroup([
                              _settingsTile(
                                  Icons.check_circle_outline, "Permission", () {
                                Get.to(() => PermissionScreen());
                              }),
                              _settingsTile(Icons.settings_outlined, "Settings",
                                  () {
                                Get.to(() => SettingsScreen());
                              }),
                            ]),
                            // Account Deletion Option
                            const SizedBox(height: 20),
                            _buildSettingsGroup([
                              _settingsTile('assets/icons/delete.svg',
                                  "Delete Account", () {
                                _showDeleteDialog(context, profileController);
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
      padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 10, left: 10),
      child: const Row(
        children: [
          SizedBox(width: 15),
          AppText(
            "Profile",
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E3E32),
          ),
        ],
      ),
    );
  }

  Widget _buildMainProfileCard(ProfileController controller) {
    final profile = controller.userProfile;
    final fullName = profile['fullName'] ?? 'User';
    final memberSinceStr = profile['memberSince'] ?? '';
    String formattedDate = '';
    if (memberSinceStr.isNotEmpty) {
      try {
        DateTime date = DateTime.parse(memberSinceStr);
        formattedDate = "Member since ${DateFormat('MMM yyyy').format(date)}";
      } catch (e) {
        formattedDate = memberSinceStr;
      }
    }

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
              CircleAvatar(
                radius: 35,
                backgroundImage: profile['avatar'] != null
                    ? NetworkImage(profile['avatar'])
                    : const AssetImage('assets/images/home_profile.png')
                        as ImageProvider,
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      fullName,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2E3E32),
                    ),
                    AppText(
                      formattedDate,
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  _showLogoutDialog(Get.context!);
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.black12),
                  ),
                  child:
                      const Icon(Icons.logout, color: Colors.black87, size: 24),
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

  Widget _settingsTile(dynamic icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.white12, width: 0.5)),
        ),
        child: Row(
          children: [
            if (icon is IconData)
              Icon(icon, color: Colors.black87, size: 24)
            else if (icon is String)
              SvgPicture.asset(
                icon,
                colorFilter:
                    const ColorFilter.mode(Colors.black87, BlendMode.srcIn),
                height: 24,
                width: 24,
              )
            else
              const SizedBox(width: 24, height: 24),
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

  void _showLogoutDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
              onPressed: () {
                Get.back();
                Get.find<AuthController>().logout();
              },
              child: const Text('Logout')),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, ProfileController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
            'Are you sure you want to delete your account? This action is irreversible.'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
              onPressed: () {
                Get.back();
                controller.deleteAccount();
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }
}
