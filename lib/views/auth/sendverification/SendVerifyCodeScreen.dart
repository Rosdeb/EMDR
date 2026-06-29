import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jonssony/controller/auth_controller.dart';
import 'package:jonssony/utils/app_colors.dart';
import 'package:jonssony/utils/app_text.dart';

class Verification extends StatefulWidget {
  const Verification({super.key});

  @override
  State<Verification> createState() => _VerificationState();
}

class _VerificationState extends State<Verification> {
  final AuthController authController = Get.find<AuthController>();
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
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
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/images/splash_log.png', height: 50),
                    const SizedBox(height: 20),

                    const AppText(
                      "Forgot Password Verification",
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    const SizedBox(height: 12),

                    Obx(
                      () => AppText(
                        "Enter the 6-digit code sent to ${authController.pendingEmail.value.isNotEmpty ? authController.pendingEmail.value : 'your email'}.",
                        textAlign: TextAlign.center,
                        fontSize: 13,
                        color: Colors.black54,
                      ),
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
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              counterText: '',
                              filled: true,
                              fillColor: const Color(0xFFFBFBFC),
                              contentPadding: EdgeInsets.zero,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE3E6F0),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: primaryGreen,
                                  width: 1.5,
                                ),
                              ),
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
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
                      onTap: () async {
                        ClipboardData? clipboardData = await Clipboard.getData(
                          Clipboard.kTextPlain,
                        );
                        if (clipboardData != null &&
                            clipboardData.text != null) {
                          String text = clipboardData.text!.trim();
                          if (text.length == 6 && int.tryParse(text) != null) {
                            for (int i = 0; i < 6; i++) {
                              _controllers[i].text = text[i];
                            }
                          }
                        }
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
                    Obx(
                      () => ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mainAppColor,
                          minimumSize: const Size(double.infinity, 54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 0,
                        ),
                        onPressed: authController.isLoading.value
                            ? null
                            : () {
                                String otp = _controllers
                                    .map((c) => c.text)
                                    .join();
                                if (otp.length < 6) {
                                  Get.snackbar(
                                    'Error',
                                    'Please enter a valid 6-digit code',
                                  );
                                  return;
                                }
                                // Use verifyPasswordOtp which redirects to Reset Password
                                authController.verifyPasswordOtp(otp: otp);
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
                                "Verify",
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // --- Resend Section ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const AppText(
                          "Didn't receive the code? ",
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                        GestureDetector(
                          onTap: () {
                            authController.resendForgotPasswordOtp();
                          },
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
                      onTap: () => Get.back(),
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
