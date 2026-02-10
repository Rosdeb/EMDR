import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jonssony/utils/AppIcons/app_icons.dart';
import 'package:jonssony/utils/app_colors.dart';
import 'package:jonssony/utils/app_text.dart';
import 'package:jonssony/views/chatbot/journry_page.dart';
import 'package:jonssony/views/chatbot/SessionFourPage.dart';

class CustomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final Color primaryColor;

  const CustomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
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
                      _navItem(
                        AppIcons.home,
                        "Home",
                        0,
                        currentIndex == 0,
                        const Color(0xFF537E5D),
                      ),
                      _navItem(
                        AppIcons.progress_nav,
                        "Progress",
                        1,
                        currentIndex == 1,
                        primaryColor,
                      ),
                      _navItem(
                        AppIcons.library,
                        "Library",
                        2,
                        currentIndex == 2,
                        primaryColor,
                      ),
                      _navItem(
                        AppIcons.profile,
                        "Profile",
                        3,
                        currentIndex == 3,
                        primaryColor,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {
              Get.to(() =>  CreateJourneyPage());
            },
            child: Container(
              height: 70,
              width: 70,
              decoration: const BoxDecoration(
                color: Color(0xFF537E5D),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  )
                ],
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 35),
            ),
          )
        ],
      ),
    );
  }

  Widget _navItem(
    String iconPath,
    String label,
    int index,
    bool isActive,
    Color activeColor,
  ) {
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: isActive
            ? BoxDecoration(
                color: AppColors.mainAppColor,
                borderRadius: BorderRadius.circular(30),
              )
            : null,
        child: Row(
          children: [
            SvgPicture.asset(
              iconPath,
              height: 24,
              colorFilter: ColorFilter.mode(
                isActive ? Colors.white : Colors.black45, // White when active
                BlendMode.srcIn,
              ),
            ),
            if (isActive) const SizedBox(width: 6),
            if (isActive)
              AppText(
                label,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
          ],
        ),
      ),
    );
  }
}