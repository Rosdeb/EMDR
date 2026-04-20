import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jonssony/controller/notification_controller.dart';
import 'package:jonssony/controller/profile_controller.dart';
import 'package:jonssony/utils/AppIcons/app_icons.dart';
import 'package:jonssony/utils/app_colors.dart';
import 'package:jonssony/views/home/homework.dart';
import 'package:jonssony/utils/app_text.dart';
import 'package:jonssony/healper/route.dart';

import 'MyCalmSpace.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure ProfileController is available and fetch profile data
    Get.put(ProfileController());
    Get.put(NotificationController());



    const double appBarImageHeight = 170;
    const double overlapAmount = 1;

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

              _buildAppBarContent(context),

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
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 15,
                              offset: Offset(0, -5),
                            )
                          ],
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
                            const SizedBox(height: 35),
                            const AppText(
                              "Quick Access",
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E3E32),
                            ),
                            const SizedBox(height: 20),


                            Row(
                              children: [
                                Expanded(
                                  child: _buildQuickAccessCard(
                                    "Calm Space",
                                    "Find peace now",
                                    AppIcons.calm,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => const MyCalmSpace()),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(child: _buildQuickAccessCard("My HomeWork", "Prime+", AppIcons.homework,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => const MyHomework()),
                                    );
                                  },
                                )),
                              ],
                            ),

                            const SizedBox(height: 25),


                            _buildJourneyCard("Anxiety Management Journey", "20 sessions", "95/100", AppColors.mainAppColor),
                            _buildJourneyCard("Mindfulness Practice", "15 sessions", "80/100", AppColors.mainAppColor),
                            _buildJourneyCard("Focus Training", "10 sessions", "60/100", AppColors.mainAppColor),

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
    final profileController = Get.find<ProfileController>();
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 5,
        left: 20,
        right: 10,
        bottom: 15,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Obx(() {
              final profile = profileController.userProfile;
              final name = profile['fullName']?.toString() ?? 'User';
              final avatarUrl = profile['avatar']?.toString();
              final hour = DateTime.now().hour;
              final greeting = hour < 12 ? 'Good morning,' : (hour < 17 ? 'Good afternoon,' : 'Good evening,');

              return Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF81C784), width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                          ? NetworkImage(avatarUrl) as ImageProvider
                          : const AssetImage('assets/images/home_profile.png'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppText(greeting, fontSize: 13, color: Colors.black87, maxLines: 1, overflow: TextOverflow.ellipsis),
                        AppText(name, fontSize: 19, fontWeight: FontWeight.bold, color: const Color(0xFF2E3E32), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ),
          // ─── Notification Bell with Badge & Feedback ──────────
          Obx(() {
            final notifController = Get.find<NotificationController>();
            final unread = notifController.unreadCount;
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  notifController.reloadFromStorage();

                  Get.toNamed(RouteHelper.notifications);

                  Future.delayed(const Duration(milliseconds: 500), () {
                    notifController.markAllAsRead();
                  });
                },
                borderRadius: BorderRadius.circular(30),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFAD8C63),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 5)
                          ],
                        ),
                        child: SvgPicture.asset(
                          AppIcons.notification,
                          height: 16,
                          colorFilter: const ColorFilter.mode(
                              Colors.white, BlendMode.srcIn),
                        ),
                      ),
                      if (unread > 0)
                        Positioned(
                          top: -2,
                          right: -2,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFFE53935),
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              unread > 99 ? '99+' : '$unread',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildQuickAccessCard(String title, String subtitle, String iconPath, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.asset(iconPath, height: 28),
                const SizedBox(height: 15),
                AppText(title, fontWeight: FontWeight.w600, fontSize: 15),
                AppText(subtitle, fontSize: 13, color: AppColors.mainAppColor, fontWeight: FontWeight.w600,),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJourneyCard(String title, String subTitle, String progress, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(35),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),

            child: Column(
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 24,
                      backgroundImage: AssetImage('assets/images/emdr_sun.jpg'),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(title, fontWeight: FontWeight.bold, fontSize: 15),
                          AppText(subTitle, fontSize: 12, color: Colors.black54),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: 0.95,
                    minHeight: 7,
                    backgroundColor: Colors.white.withValues(alpha: 0.3),

                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppText(progress, fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                    Row(
                      children: [
                        _iconLabel(Icons.calendar_today_outlined, "Daily"),
                        const SizedBox(width: 15),
                        _iconLabel(Icons.access_time_rounded, "10m"),
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _iconLabel(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF537E5D)),
        const SizedBox(width: 5),
        AppText(label, fontSize: 13, color: Colors.black87),
      ],
    );
  }
}