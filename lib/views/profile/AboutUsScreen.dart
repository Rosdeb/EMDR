import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jonssony/controller/static_content_controller.dart';
import 'package:jonssony/widets/Custom_BackgroundDesign.dart';
import 'package:jonssony/widets/custom_appbar.dart';
import 'package:jonssony/utils/app_text.dart';

class AboutUsScreen extends StatelessWidget {
  final String title;
  const AboutUsScreen({super.key, this.title = "About Us"});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StaticContentController());

    // Fetch data when screen builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchAboutUs();
    });

    return Scaffold(
      body: Stack(
        children: [
          BackgroundDesign(),
          Column(
            children: [
              Custom_AppBar(context, title),
              const SizedBox(height: 30),
              Expanded(
                child: Obx(() {
                  if (controller.isAboutUsLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF4F7957),
                      ),
                    );
                  }

                  if (controller.aboutUsError.isNotEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AppText(
                            controller.aboutUsError.value,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () => controller.fetchAboutUs(),
                            child: const Text("Retry"),
                          ),
                        ],
                      ),
                    );
                  }

                  final data = controller.aboutUsData;
                  final overview = data['overview'] ?? '';
                  final List sections = data['sections'] ?? [];

                  // Sort sections by order if available
                  sections.sort(
                    (a, b) => (a['order'] ?? 0).compareTo(b['order'] ?? 0),
                  );

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: ClipRRect(
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
                              if (overview.isNotEmpty) ...[
                                AppText(overview, fontSize: 14),
                                const SizedBox(height: 20),
                              ],
                              ...sections.map((section) {
                                final sTitle = section['title'] ?? '';
                                final sContent = section['content'] ?? '';
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (sTitle.isNotEmpty)
                                        AppText(
                                          sTitle,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      if (sContent.isNotEmpty)
                                        AppText(sContent, fontSize: 14),
                                    ],
                                  ),
                                );
                              }),
                              if (overview.isEmpty && sections.isEmpty)
                                const Center(
                                  child: AppText("No content available."),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
