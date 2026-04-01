import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jonssony/controller/auth_controller.dart';
import 'package:jonssony/healper/route.dart';
import 'package:jonssony/utils/app_colors.dart';
import 'package:jonssony/utils/app_text.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    const Color primaryGreen = AppColors.mainAppColor;
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
              margin: const EdgeInsets.symmetric(vertical: 40),
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
                    Image.asset(
                      'assets/images/splash_log.png',
                      height: 50,
                    ),
                    const SizedBox(height: 15),

                    const AppText(
                      "Step Into Success Mode",
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    const SizedBox(height: 10),

                    const AppText(
                      "Create your account and start transforming your sales and marketing strategy now.",
                      textAlign: TextAlign.center,
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                    const SizedBox(height: 25),

                    Row(
                      children: [
                        Expanded(child: _buildSmallField(firstNameController, "First Name")),
                        const SizedBox(width: 10),
                        Expanded(child: _buildSmallField(lastNameController, "Last Name")),
                      ],
                    ),
                    const SizedBox(height: 15),

                    _buildFullField(emailController, "Enter your email", keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 15),

                    _buildFullField(passwordController, "Create your password", isPassword: true),
                    const SizedBox(height: 15),

                    _buildFullField(confirmPasswordController, "Confirm your password", isPassword: true),

                    const SizedBox(height: 30),

                    Obx(() => ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.mainAppColor,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 0,
                          ),
                          onPressed: authController.isLoading.value
                              ? null
                              : () {
                                  final fName = firstNameController.text.trim();
                                  final lName = lastNameController.text.trim();
                                  final email = emailController.text.trim();
                                  final password = passwordController.text.trim();
                                  final cPassword = confirmPasswordController.text.trim();

                                  if (fName.isEmpty || lName.isEmpty || email.isEmpty || password.isEmpty) {
                                    Get.snackbar('Error', 'Please fill all fields');
                                    return;
                                  }
                                  if (password != cPassword) {
                                    Get.snackbar('Error', 'Passwords do not match');
                                    return;
                                  }

                                  authController.signup(
                                    firstName: fName,
                                    lastName: lName,
                                    email: email,
                                    password: password,
                                  );
                                },
                          child: authController.isLoading.value
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const AppText(
                                  "Sign Up",
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                        )),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const AppText("Already have an account? ", fontSize: 11, color: Colors.black54),
                        GestureDetector(
                          onTap: () {
                            Get.toNamed(RouteHelper.login);
                          },
                          child: const AppText(
                            "Sign In here",
                            fontSize: 11,
                            color: primaryGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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

  Widget _buildSmallField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 12, color: Colors.black26),
        filled: true,
        fillColor: const Color(0xFFFBFBFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
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
          borderSide: const BorderSide(color: AppColors.mainAppColor),
        ),
      ),
    );
  }

  Widget _buildFullField(TextEditingController controller, String hint, {bool isPassword = false, TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: Colors.black26),
        suffixIcon: isPassword ? const Icon(Icons.visibility_outlined, size: 18, color: Colors.black38) : null,
        filled: true,
        fillColor: const Color(0xFFFBFBFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
          borderSide: const BorderSide(color: AppColors.mainAppColor),
        ),
      ),
    );
  }
}