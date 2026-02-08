import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Required for SVG
import 'package:get/get.dart';
import 'package:jonssony/utils/app_colors.dart';
import 'package:jonssony/utils/app_text.dart';
import 'package:jonssony/views/profile/PrivacyPolicyScreen.dart';
import 'package:jonssony/views/profile/TermsOfServiceScreen.dart';
import '../../healper/route.dart';

class AuthWelcomeScreen extends StatelessWidget {
  const AuthWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Gradient
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

          // Vector Logo Background
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

          // White Login Card
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(15, 0, 15, 35),
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 30),
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
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                  const SizedBox(height: 10),
                  const AppText(
                    "Select to login with your account or create one",
                    textAlign: TextAlign.center,
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                  const SizedBox(height: 25),

                  // Sign Up Button
                  _buildButton(
                    "Sign Up",
                    AppColors.mainAppColor,
                    Colors.white,
                        () => Get.toNamed(RouteHelper.signup),
                  ),

                  const SizedBox(height: 15),

                  // Sign In Button
                  _buildButton(
                    "Sign In",
                    Colors.white,
                    Colors.black,
                        () => Get.toNamed(RouteHelper.login),
                    isBorder: true,
                  ),

                  const SizedBox(height: 20),

                  // "Or continue with" text
                  const AppText(
                    "Or continue with",
                    fontSize: 14,
                    color: Colors.black45,
                  ),

                  const SizedBox(height: 20),

                  // Google Button with SVG
                  _buildSocialButton(
                    "Google",
                    'assets/icons/google.svg', // Verify your path here
                        () {
                      // Handle Google Login logic
                    },
                  ),

                  const SizedBox(height: 25),

                  // Terms and Conditions Text
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                          color: Colors.black45,
                          fontSize: 12,
                          height: 1.5,
                          fontFamily: "Serif"
                      ),
                      children: [
                        const TextSpan(text: "By tapping continue with Google, you agree with our "),
                        TextSpan(
                          text: "Terms Conditions",
                          style: TextStyle(
                            color: AppColors.mainAppColor,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                            fontFamily: "Serif",
                          ),
                          recognizer: TapGestureRecognizer()..onTap = () {
                            Get.to(() => const TermsOfServiceScreen());
                          },
                        ),
                        const TextSpan(text: " and "),
                        TextSpan(
                          text: "Privacy Policy",
                          style: TextStyle(
                            color: AppColors.mainAppColor,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                            fontFamily: "Serif",
                          ),
                          recognizer: TapGestureRecognizer()..onTap = () {
                            Get.to(() => const PrivacyPolicyScreen());
                          },
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

  // Helper for the Google Button
  Widget _buildSocialButton(String text, String iconPath, VoidCallback tap) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey.shade200, width: 1.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          backgroundColor: const Color(0xFFFAFAFA),
          elevation: 0,
        ),
        onPressed: tap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              iconPath,
              height: 24,
              width: 24,
            ),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper for primary buttons
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
          color: txt,
        ),
      ),
    );
  }
}