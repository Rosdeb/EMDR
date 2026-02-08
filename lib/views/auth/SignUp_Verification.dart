import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jonssony/utils/app_colors.dart';
import 'package:jonssony/utils/app_text.dart';
import 'package:jonssony/views/auth/login_screen.dart';
import 'package:jonssony/views/home/home_screen.dart';

import '../../healper/route.dart';

class SignUpVerification extends StatefulWidget {
  const SignUpVerification({super.key});

  @override
  State<SignUpVerification> createState() => _SignUpVerificationState();
}

class _SignUpVerificationState extends State<SignUpVerification> {
  // 1. Controllers and FocusNodes for the 6 digits
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    const SizedBox(height: 20),

                    const AppText(
                      "Verification",
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    const SizedBox(height: 12),

                    const AppText(
                      "Enter the 6-digit code sent to your email.",
                      textAlign: TextAlign.center,
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                    const SizedBox(height: 30),

                    // --- OTP Input Row ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (index) {
                        return SizedBox(
                          width: 40,
                          height: 48,
                          child: TextField(
                            controller: _controllers[index],
                            focusNode: _focusNodes[index],
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            maxLength: 1,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            decoration: InputDecoration(
                              counterText: '',
                              filled: true,
                              fillColor: const Color(0xFFFBFBFC),
                              contentPadding: EdgeInsets.zero,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: Color(0xFFE3E6F0)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: primaryGreen, width: 1.5),
                              ),
                            ),
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            onChanged: (value) {
                              if (value.isNotEmpty && index < 5) {
                                _focusNodes[index + 1].requestFocus();
                              } else if (value.isEmpty && index > 0) {
                                _focusNodes[index - 1].requestFocus();
                              }
                            },
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 20),

                    // --- Paste Code ---
                    GestureDetector(
                      onTap: () {
                        // Logic to paste code could go here
                      },
                      child: const AppText(
                        'Paste Code',
                        fontSize: 14,
                        color: primaryGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // --- Verify Button ---
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

                          Get.offAllNamed(RouteHelper.main);

                        String otp = _controllers.map((c) => c.text).join();
                        print("Entered OTP: $otp");
                      },
                      child: const AppText(
                        "Verify",
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // --- Resend Section ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const AppText("Didn't receive the code? ", fontSize: 13, color: Colors.black54),
                        GestureDetector(
                          onTap: () {},
                          child: const AppText(
                            "Resend",
                            fontSize: 13,
                            color: primaryGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    GestureDetector(
                      onTap: () =>  Get.to(() => LoginScreen()),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.arrow_back, size: 16, color: primaryGreen),
                          SizedBox(width: 5),
                          AppText(
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
          ),
        ],
      ),
    );
  }
}