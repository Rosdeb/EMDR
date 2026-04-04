import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jonssony/controller/static_content_controller.dart';
import 'package:jonssony/widets/Custom_BackgroundDesign.dart';
import 'package:jonssony/widets/custom_appbar.dart';
import 'package:jonssony/utils/app_text.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  final StaticContentController _controller = Get.put(StaticContentController());

  @override
  void initState() {
    super.initState();
    _controller.fetchPrivacyPolicy();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BackgroundDesign(),
          Column(
            children: [
              Custom_AppBar(context, "Privacy Policy"),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                  child: Column(
                    children: [
                      const SizedBox(height: 120),
                      Obx(() {
                        if (_controller.isPrivacyLoading.value) {
                          return const Center(child: CircularProgressIndicator(color: Color(0xFF4F7957)));
                        }

                        if (_controller.privacyError.isNotEmpty) {
                          return Center(
                            child: Column(
                              children: [
                                AppText(_controller.privacyError.value, color: Colors.red),
                                TextButton(
                                  onPressed: () => _controller.fetchPrivacyPolicy(),
                                  child: const Text("Retry"),
                                ),
                              ],
                            ),
                          );
                        }

                        final privacy = _controller.privacyData;
                        final String content = privacy['content'] ?? privacy['description'] ?? 'No policy content available.';
                        final String lastUpdated = privacy['updatedAt'] ?? privacy['lastUpdated'] ?? '';

                        return ClipRRect(
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
                                  AppText(
                                    content,
                                    fontSize: 14,
                                    color: const Color(0xFF2E3E32),
                                  ),
                                  if (lastUpdated.isNotEmpty) ...[
                                    const SizedBox(height: 20),
                                    AppText(
                                      "Last updated: $lastUpdated",
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ],
                                ],
                              ),
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
}