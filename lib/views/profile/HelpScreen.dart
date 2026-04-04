import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jonssony/controller/static_content_controller.dart';
import 'package:jonssony/widets/custom_appbar.dart';
import '../../widets/Custom_BackgroundDesign.dart';
import 'package:jonssony/utils/app_text.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final StaticContentController _controller = Get.put(StaticContentController());

  @override
  void initState() {
    super.initState();
    _controller.fetchFaqs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BackgroundDesign(),
          Column(
            children: [
              Custom_AppBar(context, "Help"),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(height: 130),
                      Obx(() {
                        if (_controller.isFaqLoading.value) {
                          return const Center(
                              child: CircularProgressIndicator(
                                  color: Color(0xFF4F7957)));
                        }

                        if (_controller.faqError.isNotEmpty) {
                          return Center(
                            child: Column(
                              children: [
                                AppText(_controller.faqError.value,
                                    color: Colors.red),
                                TextButton(
                                  onPressed: () => _controller.fetchFaqs(),
                                  child: const Text("Retry"),
                                ),
                              ],
                            ),
                          );
                        }

                        final List faqs = _controller.faqList;

                        if (faqs.isEmpty) {
                          return const Center(child: AppText("No FAQs found."));
                        }

                        return ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                ),
                              ),
                              child: Column(
                                children: faqs.map((faq) {
                                  int index = faqs.indexOf(faq);
                                  return Column(
                                    children: [
                                      Theme(
                                        data: Theme.of(context).copyWith(
                                          dividerColor: Colors.transparent,
                                        ),
                                        child: ExpansionTile(
                                          iconColor: const Color(0xFF2E3E32),
                                          collapsedIconColor: Colors.black54,
                                          title: AppText(
                                            "${index + 1}. ${faq['question'] ?? faq['title'] ?? ''}",
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFF2E3E32),
                                          ),
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.fromLTRB(
                                                  20, 0, 20, 15),
                                              child: AppText(
                                                faq['answer'] ?? faq['content'] ?? '',
                                                fontSize: 14,
                                                color: Colors.black87,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      if (index != faqs.length - 1)
                                        Divider(
                                          color: Colors.white.withOpacity(0.2),
                                          indent: 20,
                                          endIndent: 20,
                                          height: 1,
                                        ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 30),
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