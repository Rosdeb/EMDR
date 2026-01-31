import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../healper/route.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 3 second por welcome screen-e niye jabe
    Future.delayed(const Duration(seconds: 3), () => Get.offNamed(RouteHelper.authWelcome));

    return Scaffold(
      backgroundColor: const Color(0xFFD3E2D4), // Soft Green Background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/splash_log.png', width: 180),
          ],
        ),
      ),
    );
  }
}