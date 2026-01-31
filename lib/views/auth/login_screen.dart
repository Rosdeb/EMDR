import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/app_colors.dart';
import '../../healper/route.dart';

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
          // 1. Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/login.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // 2. Dynamic Bottom Shadow/Gradient (Image-er upore white shadow)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: screenHeight * 0.7, // Screen-er niche theke 70% porjonto shadow
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.0), // Upore transparent
                    Colors.white.withOpacity(0.2),
                   // Majhkane halka white shadow
                    Colors.white.withOpacity(.8), // Niche gaaro white
                    Colors.white,
                  ],
                ),
              ),
            ),
          ),

          // 3. Main Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                children: [
                  const SizedBox(height: 50),

                  // Brand Logo
                  Center(
                    child: Image.asset(
                      'assets/images/splash_log.png',
                      height: 100,
                    ),
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    "Sign in",
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                      fontFamily: 'Serif',
                    ),
                  ),

                  const SizedBox(height: 322),

                  // Email Field
                  _textField(
                    icon: Icons.email_outlined,
                    hint: "Email address",
                  ),

                  const SizedBox(height: 20),

                  // Password Field
                  _textField(
                    icon: Icons.lock_outline,
                    hint: "Password",
                    isObscure: true,
                    suffixIcon: Icons.visibility_off_outlined,
                  ),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
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

                  const SizedBox(height: 20),

                  // Sign In Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryButtonColor,
                      minimumSize: const Size(double.infinity, 56),
                      elevation: 4, // Halka shadow button-e
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () => Get.to(RouteHelper.home),
                    child: const Text(
                      "Sign In",
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Sign Up Navigation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? ", style: TextStyle(color: Colors.black54)),
                      GestureDetector(
                        // onPressed: () => Get.toNamed(RouteHelper.signup),
                        child: const Text(
                          "Sign up",
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
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

  Widget _textField({required IconData icon, required String hint, bool isObscure = false, IconData? suffixIcon}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        obscureText: isObscure,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.grey.shade400),
          suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: Colors.grey.shade400) : null,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}