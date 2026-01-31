import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/app_colors.dart';
import '../../healper/route.dart';

class AuthWelcomeScreen extends StatelessWidget {
  const AuthWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryButtonColor = Color(0xFF4C6D4D);
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.mainAppColor,
      body: Stack(
        clipBehavior: Clip.none,
        children: [

          Positioned(
            top: - screenHeight * 0.07,
            left: -screenWidth * 0.20,
            right: -screenWidth * 0.20,
            child: Opacity(
              opacity: 0.8,
              child: Image.asset(
                'assets/images/vector_logo.png',
                height: screenHeight * 0.55,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // 2. Girl Image - Height aro boro kora hoyeche (Max size)
          Positioned(
            top: -9,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/bg_girl.png',
              height: screenHeight * 0.70, // Height aro barano hoyeche (Design onujayi boro)
              fit: BoxFit.cover, // Figma-r moto fill feel deyar jonno
              alignment: Alignment.topCenter,
            ),
          ),

          // 3. White Shadow/Fade at Bottom (Smooth Transition)
          Positioned(
            bottom: screenHeight * 0.32,
            left: 0,
            right: 0,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.2),
                    Colors.white,
                  ],
                ),
              ),
            ),
          ),

          // 4. Bottom White Card
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(25, 30, 25, 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Let's get started!",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Select to login with your account or create one",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 30),

                  _buildButton("Sign Up", primaryButtonColor, Colors.white,
                          () => Get.toNamed(RouteHelper.signup)),

                  const SizedBox(height: 12),

                  _buildButton("Sign In", Colors.white, Colors.black,
                          () => Get.toNamed(RouteHelper.login), isBorder: true),

                  const SizedBox(height: 20),

                  // Terms & Policy Part
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(color: Colors.black45, fontSize: 11, height: 1.4),
                        children: [
                          const TextSpan(text: "By tapping continue with Apple, Facebook, Google, you agree with our "),
                          TextSpan(
                            text: "Terms Conditions",
                            style: TextStyle(color: primaryButtonColor, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                          ),
                          const TextSpan(text: " and "),
                          TextSpan(
                            text: "Privacy Policy",
                            style: TextStyle(color: primaryButtonColor, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildButton(String text, Color bg, Color txt, VoidCallback tap, {bool isBorder = false}) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: isBorder ? BorderSide(color: Colors.grey.shade300) : BorderSide.none,
          ),
        ),
        onPressed: tap,
        child: Text(text, style: TextStyle(color: txt, fontSize: 15, fontWeight: FontWeight.w700)),
      ),
    );
  }
}