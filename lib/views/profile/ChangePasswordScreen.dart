import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:jonssony/widets/Custom_BackgroundDesign.dart';
import 'package:jonssony/widets/custom_appbar.dart';

class SettingChangePasswordScreen extends StatelessWidget {
  const SettingChangePasswordScreen({super.key});

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
                   SizedBox(height: 150),
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
                                _buildGlassTextField("Enter old password", isPassword: true),
                                const SizedBox(height: 20),

                                _buildLabel("New Password"),
                                _buildGlassTextField("Enter new password", isPassword: true),
                                const SizedBox(height: 20),

                                _buildLabel("Confirm Password"),
                                _buildGlassTextField("Re-enter new password", isPassword: true),
                                const SizedBox(height: 10), // Card-er bhetore ektu bottom space
                              ],
                            ),
                          ),
                        ),
                      ),
                      // --- Glasscard End ---

                      const SizedBox(height: 30),

                      // Update Button (Glasscard-er baire thaka bhalo, design onujayi)
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4F7957),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            "Update password",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
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
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF2E3E32),
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildGlassTextField(String hint, {bool isPassword = false}) {
    return TextField(
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.black.withOpacity(0.3), fontSize: 14),
        filled: true,
        fillColor: Colors.white.withOpacity(0.5), // Card-er bhetore field-ti ektu highlight korbe
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
    );
  }
}