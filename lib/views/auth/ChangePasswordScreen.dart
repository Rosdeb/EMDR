import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jonssony/controller/auth_controller.dart';
import 'package:jonssony/healper/route.dart';
import 'package:jonssony/utils/app_colors.dart';
import 'package:jonssony/utils/app_text.dart';

class ChangePasswordScreen extends StatelessWidget {
  ChangePasswordScreen({super.key});

  final RxBool _isNewPasswordHidden = true.obs;
  final RxBool _isConfirmPasswordHidden = true.obs;

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

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
                      "Set New Password",
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    const SizedBox(height: 10),

                    const AppText(
                      "Your new password must be different from previously used passwords.",
                      textAlign: TextAlign.center,
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                    const SizedBox(height: 25),

                    _buildFullField(newPasswordController, "New Password", isPasswordHidden: _isNewPasswordHidden),
                    const SizedBox(height: 15),

                    _buildFullField(confirmPasswordController, "Confirm New Password", isPasswordHidden: _isConfirmPasswordHidden),

                    const SizedBox(height: 30),

                    Obx(() => ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.mainAppColor,
                            minimumSize: const Size(double.infinity, 52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 0,
                          ),
                          onPressed: authController.isLoading.value
                              ? null
                              : () {
                                  final newPass = newPasswordController.text.trim();
                                  final confirmPass = confirmPasswordController.text.trim();

                                  if (newPass.isEmpty || confirmPass.isEmpty) {
                                    Get.snackbar('Error', 'Please fill both password fields');
                                    return;
                                  }
                                  if (newPass != confirmPass) {
                                    Get.snackbar('Error', 'Passwords do not match');
                                    return;
                                  }

                                  // Get OTP value from somewhere or modify the API flow so it doesn't need OTP again, 
                                  // or store the verified OTP in the controller.
                                  // For now, since user passed verification screen, we need OTP for the 'recover-account' endpoint.
                                  // Oh! The user actually provides the OTP on the previous screen.
                                  // I will set authController.recoverAccount to take '000000' as a dummy if not stored, 
                                  // or refactor to store it. Assuming we have to provide OTP in backend. Let's update controller logic in a moment if needed.

                                  // Wait, let me add an OTP property or pass it here. 
                                  // I will assume the user entered OTP is not stored... Wait, I should add verifiedOtp to AuthController. Let's do that right after this.
                                  authController.recoverAccount(
                                    newPassword: newPass,
                                    confirmPassword: confirmPass,
                                  );

                                },
                          child: authController.isLoading.value ? const SizedBox(
                                height: 20, width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              ) : const AppText(
                            "Update Password",
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        )),

                    const SizedBox(height: 20),

                    GestureDetector(
                      onTap: () => Get.offAllNamed(RouteHelper.login),
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

  Widget _buildFullField(TextEditingController controller, String hint, {RxBool? isPasswordHidden}) {
    Widget buildTextField(bool obscure) {
      return TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 13, color: Colors.black26),
          prefixIcon: const Icon(Icons.lock_outline, size: 20, color: Colors.black38),
          suffixIcon: isPasswordHidden != null
              ? IconButton(
                  icon: Icon(
                    obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, 
                    size: 18, color: Colors.black38
                  ),
                  onPressed: () => isPasswordHidden.value = !isPasswordHidden.value,
                )
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

    if (isPasswordHidden != null) {
      return Obx(() => buildTextField(isPasswordHidden.value));
    }
    return buildTextField(false);
  }
}