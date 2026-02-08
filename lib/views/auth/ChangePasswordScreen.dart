import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jonssony/healper/route.dart';
import 'package:jonssony/utils/app_colors.dart';
import 'package:jonssony/views/auth/login_screen.dart';
import 'package:jonssony/utils/app_text.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF537E5D);
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.mainAppColor,
      body: Stack(
        children: [
          // ১. ব্যাকগ্রাউন্ড ভেক্টর পজিশনিং (Sign Up পেজের মতো)
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

          // ২. মেইন ফর্ম কার্ড
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
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ব্র্যান্ড লোগো
                    Image.asset(
                      'assets/images/splash_log.png',
                      height: 50,
                    ),
                    const SizedBox(height: 15),

                    // টাইটেল
                    const AppText(
                      "Set New Password",
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    const SizedBox(height: 10),

                    // সাব-টাইটেল
                    const AppText(
                      "Your new password must be different from previously used passwords.",
                      textAlign: TextAlign.center,
                      fontSize: 12,
                      color: Colors.black54,

                    ),
                    const SizedBox(height: 25),

                    // নিউ পাসওয়ার্ড ফিল্ড
                    _buildFullField("New Password", isPassword: true),
                    const SizedBox(height: 15),

                    // কনফার্ম পাসওয়ার্ড ফিল্ড
                    _buildFullField("Confirm New Password", isPassword: true),

                    const SizedBox(height: 30),

                    // বাটন
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mainAppColor,
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Get.offAllNamed(RouteHelper.login);
                      },
                      child: const AppText(
                        "Update Password",
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ব্যাক টু লগইন
                GestureDetector(
                  onTap: () => Get.back(),


                child: const AppText(
                        "Back to Sign In",
                        fontSize: 12,
                        color: primaryGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // পাসওয়ার্ড ইনপুট ফিল্ড (Sign Up পেজের সাথে মিল রেখে)
  Widget _buildFullField(String hint, {bool isPassword = false}) {
    return TextField(
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: Colors.black26),
        prefixIcon: const Icon(Icons.lock_outline, size: 20, color: Colors.black38),
        suffixIcon: isPassword
            ? const Icon(Icons.visibility_outlined, size: 18, color: Colors.black38)
            : null,
        filled: true,
        fillColor: const Color(0xFFFBFBFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
          borderSide: const BorderSide(color: Color(0xFF537E5D), width: 1.2),
        ),
      ),
    );
  }
}