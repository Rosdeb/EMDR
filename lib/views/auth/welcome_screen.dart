import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jonssony/utils/app_colors.dart';
import 'package:jonssony/utils/app_text.dart';
import '../../healper/route.dart';

class AuthWelcomeScreen extends StatelessWidget {
  const AuthWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF52734D);
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [

          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.mainAppColor,
                  AppColors.mainAppColor,
                  Colors.white.withOpacity(0.8),
                  Colors.white,
                ],

                stops: const [0.0, 0.5, 0.75, 0.85],
              ),
            ),
          ),


          Positioned(
            top: -80,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: 1.0,
              child: Image.asset(
                'assets/images/vector_logo.png',
                height: screenHeight * 0.6,
                fit: BoxFit.cover,
              ),
            ),
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ShaderMask(
              shaderCallback: (rect) {
                return const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black,
                    Colors.black,
                    Colors.transparent,
                  ],
                  stops: [0.0, 0.55, 0.9],
                ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
              },
              blendMode: BlendMode.dstIn,
              child: Image.asset(
                'assets/images/bg_girl.png',
                height: screenHeight * 0.70,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(15, 0, 15, 25),
              padding: const EdgeInsets.fromLTRB(24, 35, 24, 25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AppText(
                    "Let's get started!",
                    textAlign: TextAlign.center,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                  const SizedBox(height: 12),
                  const AppText(
                    "Select to login with your account or create one",
                    textAlign: TextAlign.center,
                    fontSize: 15,
                    color: Colors.black54,
                  ),
                  const SizedBox(height: 35),

                  _buildButton(
                    "Sign Up",
                    primaryGreen,
                    Colors.white,
                        () => Get.toNamed(RouteHelper.signup),
                  ),

                  const SizedBox(height: 15),

                  _buildButton(
                    "Sign In",
                    Colors.white,
                    Colors.black,
                        () => Get.toNamed(RouteHelper.login),
                    isBorder: true,
                  ),

                  const SizedBox(height: 25),

                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black45, fontSize: 12, height: 1.5, fontFamily: "Serif"),
                      children: [
                        const TextSpan(text: "By tapping continue with Apple, Facebook, Google, you agree with our "),
                        TextSpan(
                          text: "Terms Conditions",
                          style: TextStyle(
                            color: primaryGreen,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                            fontFamily: "Serif",
                          ),
                        ),
                        const TextSpan(text: " and "),
                        TextSpan(
                          text: "Privacy Policy",
                          style: TextStyle(
                            color: primaryGreen,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                            fontFamily: "Serif",
                          ),
                        ),
                      ],
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
      height: 58,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: txt,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: isBorder ? BorderSide(color: Colors.grey.shade300, width: 1.5) : BorderSide.none,
          ),
        ),
        onPressed: tap,
        child: AppText(
          text,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}