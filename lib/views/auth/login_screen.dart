import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jonssony/healper/route.dart';
import 'package:jonssony/views/home/home_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryButtonColor = Color(0xFF4C6D4D);
    const Color forgotPassColor = Color(0xFFE57373);
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // ১. ব্যাকগ্রাউন্ড ইমেজ
          Positioned.fill(
            child: Image.asset(
              'assets/images/login.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // ২. ট্রানজিশন ফেড ইফেক্ট
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.15),
                    Colors.transparent,
                    Colors.white.withOpacity(0.9),
                    Colors.white,
                  ],
                  stops: const [0.0, 0.35, 0.7, 1.0],
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: screenHeight * 0.38), 


                  Image.asset(
                    'assets/images/splash_log.png',
                    height: 90,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 10),


                  const Text(
                    "Sign in",
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF0F1912),
                      fontFamily: 'Serif',
                    ),
                  ),


                  SizedBox(height: screenHeight * 0.035),

                  const Text(
                    "Sign in with email address",
                    style: TextStyle(
                      color: Color(0xFF0F1912),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 15),


                  _textField(
                    icon: Icons.email_outlined,
                    hint: "tam@ui8.net",
                  ),

                  const SizedBox(height: 16),


                  _textField(
                    icon: Icons.lock_outline,
                    hint: "••••••••••••••••",
                    isObscure: true,
                  ),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Get.toNamed(RouteHelper.signup);
                      },
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(
                          color: forgotPassColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),


                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryButtonColor,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () => Get.to(() => const HomeScreen()),
                    child: const Text(
                      "Sign In",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),


                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Get.toNamed(RouteHelper.signup);
                      },
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(color: Colors.black54, fontSize: 14),
                          children: [
                            TextSpan(text: "Dont have an account? "),
                            TextSpan(
                              text: "Sign up",
                              style: TextStyle(
                                color: Color(0xFF0F1912),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _textField({required IconData icon, required String hint, bool isObscure = false}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFBFBFC),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Color(0xFFE3E6F0)),
      ),
      child: TextField(
        obscureText: isObscure,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 15),
          prefixIcon: Icon(icon, color: Colors.grey.shade600, size: 22),
          contentPadding: const EdgeInsets.symmetric(vertical: 20),
          border: InputBorder.none,
        ),
      ),
    );
  }
}