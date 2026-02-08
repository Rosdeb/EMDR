import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jonssony/healper/route.dart';
import 'package:jonssony/utils/app_colors.dart';
import 'package:jonssony/views/auth/ChangePasswordScreen.dart';
import 'package:jonssony/utils/app_text.dart';
import 'package:jonssony/views/auth/SendVerifyCodeScreen.dart';
import 'package:jonssony/views/auth/login_screen.dart';

class ForgetScreen extends StatelessWidget {
  const ForgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF537E5D);
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.mainAppColor,
      body: Stack(
        children: [

          Positioned(
            top: screenHeight * 0.08,
            left: -screenWidth * 0.01,
            right: -screenWidth * 0.01,
            child: Opacity(
              opacity: 0.9,
              child: Image.asset(
                'assets/images/vector_logo.png',
                height: screenHeight * 0.5,
                color: Colors.white,
                fit: BoxFit.contain,
              ),
            ),
          ),


          Center(
            child: Container(
              width: screenWidth * 0.88,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  Image.asset(
                    'assets/images/splash_log.png',
                    height: 50,
                  ),
                  const SizedBox(height: 20),


                  const AppText(
                    "Forget Password ?",
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 12),
                  const AppText(
                    "Don’t worry! Enter your registered email.",
                    textAlign: TextAlign.center,
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                  const SizedBox(height: 30),


                  _buildFullField("Enter your email address"),

                  const SizedBox(height: 30),


                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mainAppColor,
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Get.toNamed(RouteHelper.verify);
                    },
                    child: const AppText(
                      "Send Reset Code",
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 20),


                  GestureDetector(
                    onTap: () =>  Get.to(() => LoginScreen()),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_back, size: 16, color: primaryGreen),
                        SizedBox(width: 5),
                        const AppText(
                          "Back to Sign In",
                          fontSize: 13,
                          color: primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildFullField(String hint) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 14, color: Colors.black26),
        prefixIcon: const Icon(Icons.email_outlined, color: Colors.black38, size: 20),
        filled: true,
        fillColor: const Color(0xFFFBFBFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFE3E6F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFE3E6F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF537E5D), width: 1.5),
        ),
      ),
    );
  }
}