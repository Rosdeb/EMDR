import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:jonssony/widets/custom_appbar.dart';
import '../../widets/Custom_BackgroundDesign.dart';
import 'package:jonssony/utils/app_text.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> faqs = [
      "How do I book a delivery?",
      "How to track my order?",
      "Can I change my address?",
      "How do I cancel a request?",
      "What are the payment methods?",
      "How to contact support?"
    ];

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
                     SizedBox(height: 130),
                      ClipRRect(
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
                              children: faqs.map((question) {
                                int index = faqs.indexOf(question);
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
                                          "${index + 1}. $question",
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF2E3E32),
                                        ),
                                        children: const [
                                          Padding(
                                            padding: EdgeInsets.fromLTRB(20, 0, 20, 15),
                                            child: AppText(
                                              "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                                              fontSize: 14,
                                              color: Colors.black87,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    // Last item bade divider add kora hoyeche
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
                      ),
                      // --- Glassmorphism Card End ---
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