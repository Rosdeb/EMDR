import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../healper/route.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    Future.delayed(
      const Duration(seconds: 5),
          () => Get.offNamed(RouteHelper.authWelcome),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(

        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFCFE1D4),
              Color(0xFFE7F1EA),
              Color(0xFFFFFFFF),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 3),

            Center(
              child: Image.asset(
                'assets/images/splash_log.png',
                width: MediaQuery.of(context).size.width * 0.55,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),

            const Spacer(flex: 4),
          ],
        ),
      ),
    );
  }
}