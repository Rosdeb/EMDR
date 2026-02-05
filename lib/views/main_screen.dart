import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jonssony/controller/navigation_controller.dart';
import 'package:jonssony/utils/app_colors.dart';
import 'package:jonssony/views/Library/library_page.dart';
import 'package:jonssony/views/home/home_screen.dart';
import 'package:jonssony/views/profile/profile_page.dart';
import 'package:jonssony/views/progress/progress_page.dart';
import 'package:jonssony/widets/navbar.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NavigationController controller = Get.put(NavigationController());

    final List<Widget> pages = [
      const HomeScreen(),
      const ProgressPage(),
      const LibraryPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: Stack(
        children: [
          // Content
          Obx(() => IndexedStack(
                index: controller.selectedIndex.value,
                children: pages,
              )),
          
          // Persistent NavBar
          Obx(() => CustomNavBar(
                currentIndex: controller.selectedIndex.value,
                onTap: (index) => controller.changeIndex(index),
                primaryColor: AppColors.mainAppColor,
              )),
        ],
      ),
    );
  }
}
