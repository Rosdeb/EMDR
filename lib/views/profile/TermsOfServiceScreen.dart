import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jonssony/controller/static_content_controller.dart';
import 'package:jonssony/widets/Custom_BackgroundDesign.dart';
import 'package:jonssony/widets/custom_appbar.dart';
import 'package:jonssony/utils/app_text.dart';

class TermsOfServiceScreen extends StatefulWidget {
  const TermsOfServiceScreen({super.key});

  @override
  State<TermsOfServiceScreen> createState() => _TermsOfServiceScreenState();
}

class _TermsOfServiceScreenState extends State<TermsOfServiceScreen> {
  final StaticContentController _controller = Get.put(StaticContentController());

  @override
  void initState() {
    super.initState();
    // Fetch latest active terms
    _controller.fetchTermsOfService();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BackgroundDesign(),
          Column(
            children: [
              Custom_AppBar(context, "Terms of Service"),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                  child: Column(
                    children: [
                      const SizedBox(height: 120),
                      Obx(() {
                        if (_controller.isTermsLoading.value) {
                          return const Center(
                              child: CircularProgressIndicator(
                                  color: Color(0xFF4F7957)));
                        }

                        if (_controller.termsError.isNotEmpty) {
                          return Center(
                            child: Column(
                              children: [
                                AppText(_controller.termsError.value,
                                    color: Colors.red),
                                const SizedBox(height: 10),
                                TextButton(
                                  onPressed: () =>
                                      _controller.fetchTermsOfService(),
                                  child: const Text("Retry"),
                                ),
                              ],
                            ),
                          );
                        }

                        final terms = _controller.termsData;
                        final String content = terms['content'] ?? 'No terms available.';
                        final String version = terms['version'] ?? '';

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
                                  if (version.isNotEmpty) ...[
                                    AppText(
                                      "Version: $version",
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black54,
                                    ),
                                    const SizedBox(height: 15),
                                  ],
                                  AppText(
                                    content,
                                    fontSize: 14,
                                    color: const Color(0xFF2E3E32),
                                  ),
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