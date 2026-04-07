import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jonssony/controller/profile_controller.dart';
import 'package:jonssony/widets/Custom_BackgroundDesign.dart';
import 'package:jonssony/widets/custom_appbar.dart';
import 'package:jonssony/utils/app_text.dart';

class SettingChangePasswordScreen extends StatefulWidget {
  const SettingChangePasswordScreen({super.key});

  @override
  State<SettingChangePasswordScreen> createState() => _SettingChangePasswordScreenState();
}

class _SettingChangePasswordScreenState extends State<SettingChangePasswordScreen> {
  final ProfileController _profileController = Get.find<ProfileController>();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BackgroundDesign(),
          Column(
            children: [
              Custom_AppBar(context, "Change Password"),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(height: 150),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel("Current Password"),
                                _buildGlassTextField(_currentPasswordController, "Enter old password", isPassword: true),
                                const SizedBox(height: 20),

                                _buildLabel("New Password"),
                                _buildGlassTextField(_newPasswordController, "Enter new password", isPassword: true),
                                const SizedBox(height: 20),

                                _buildLabel("Confirm Password"),
                                _buildGlassTextField(_confirmPasswordController, "Re-enter new password", isPassword: true),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      Obx(() {
                        return SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _profileController.isLoading.value ? null : () async {
                              final success = await _profileController.changePassword(
                                currentPassword: _currentPasswordController.text,
                                newPassword: _newPasswordController.text,
                                confirmPassword: _confirmPasswordController.text,
                              );
                              if (success) {
                                Get.snackbar(
                                  "Success",
                                  "Password changed successfully",
                                  snackPosition: SnackPosition.TOP,
                                  backgroundColor: const Color(0xFF4F7957).withOpacity(0.7),
                                  colorText: Colors.white,
                                  margin: const EdgeInsets.all(15),
                                  borderRadius: 15,
                                  duration: const Duration(seconds: 3),
                                );
                                Navigator.pop(context);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4F7957),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: _profileController.isLoading.value 
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const AppText(
                                "Update password",
                                color: Colors.white,
                                fontSize: 16,
                              ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 5),
      child: AppText(
        text,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF2E3E32),
        fontSize: 14,
      ),
    );
  }

  Widget _buildGlassTextField(TextEditingController controller, String hint, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.black.withOpacity(0.3), fontSize: 14),
        filled: true,
        fillColor: Colors.white.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
    );
  }
}