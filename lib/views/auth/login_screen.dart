import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jonssony/controller/auth_controller.dart';
import 'package:jonssony/healper/route.dart';
import 'package:jonssony/utils/app_colors.dart';
import 'package:jonssony/utils/app_text.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthController authController = Get.find<AuthController>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryButtonColor = Color(0xFF4C6D4D);
    const Color forgotPassColor = Color(0xFFE57373);
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/login.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // Gradient overlay
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
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(25, 20, 25, 30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/images/splash_log.png',
                      height: 90,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 25),
                    
                    const AppText(
                      "Sign in",
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F1912),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    const AppText(
                      "Sign in with email address",
                      color: Colors.black54,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),

                    const SizedBox(height: 25),

                    _textField(
                      controller: _emailController,
                      icon: Icons.email_outlined,
                      hint: "Enter Your Email",
                      keyboardType: TextInputType.emailAddress,
                    ),

                    const SizedBox(height: 16),

                    _textField(
                      controller: _passwordController,
                      icon: Icons.lock_outline,
                      hint: "Enter Your Password",
                      isObscure: !_isPasswordVisible,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey.shade600,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Get.toNamed(RouteHelper.forget);
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(50, 30),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const AppText(
                          "Forgot Password?",
                          color: forgotPassColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Obx(() => ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryButtonColor,
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 0,
                          ),
                          onPressed: authController.isLoading.value
                              ? null
                              : () {
                                  final email = _emailController.text.trim();
                                  final password = _passwordController.text.trim();
                                  if (email.isEmpty || password.isEmpty) {
                                    Get.snackbar(
                                      'Error',
                                      'Please enter email and password',
                                      snackPosition: SnackPosition.BOTTOM,
                                    );
                                    return;
                                  }
                                  authController.login(
                                    email: email,
                                    password: password,
                                  );
                                },
                          child: authController.isLoading.value
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const AppText(
                                  "Sign In",
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                        )),

                    const SizedBox(height: 25),

                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Get.toNamed(RouteHelper.signup);
                        },
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(
                                color: Colors.black54,
                                fontSize: 14,
                                fontFamily: 'Serif'),
                            children: [
                              TextSpan(text: "Don't have an account? "),
                              TextSpan(
                                text: "Sign up",
                                style: TextStyle(
                                  color: Color(0xFF0F1912),
                                  fontFamily: 'Serif',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    bool isObscure = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 15),
        prefixIcon: Icon(icon, color: Colors.grey.shade600, size: 22),
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(vertical: 20),
        filled: true,
        fillColor: const Color(0xFFFBFBFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: AppColors.mainAppColor),
        ),
      ),
    );
  }
}