import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jonssony/utils/AppIcons/app_icons.dart';
import 'package:jonssony/utils/app_colors.dart';
import 'package:jonssony/utils/app_text.dart';
import 'package:jonssony/views/sessions/journry_page.dart';

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
      left: 10,
      right: 10,
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  height: 65,
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
                        "My Space",
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
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              Get.to(() => CreateJourneyPage());
            },
            child: Container(
              height: 65,
              width: 65,
              decoration: const BoxDecoration(
                color: Color(0xFF537E5D),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 30),
            ),
          ),
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: isActive
            ? BoxDecoration(
                color: AppColors.mainAppColor,
                borderRadius: BorderRadius.circular(30),
              )
            : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              iconPath,
              height: 22,
              colorFilter: ColorFilter.mode(
                isActive ? Colors.white : Colors.black45,
                BlendMode.srcIn,
              ),
            ),
            if (isActive) const SizedBox(width: 5),
            if (isActive)
              Flexible(
                child: AppText(
                  label,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
