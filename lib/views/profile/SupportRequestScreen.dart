import 'dart:ui';
import 'package:flutter/material.dart';

import '../../widets/Custom_BackgroundDesign.dart';
import '../../widets/Custom_BackgroundDesign.dart';
import '../../widets/custom_appbar.dart';
import 'package:jonssony/utils/app_text.dart';

class SupportRequestScreen extends StatelessWidget {
  const SupportRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
       BackgroundDesign(),
          Column(
            children: [
              Custom_AppBar(context, "Support Requests"),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    children: [
                      SizedBox(height: 50),
                      Image.asset('assets/images/splash_log.png', height: 120),
                      const SizedBox(height: 20),
                      const AppText(
                        "If you face any kind of problem with our service feel free to contact us.",
                        textAlign: TextAlign.center,
                        fontWeight: FontWeight.w500,
                      ),
                      const SizedBox(height: 30),
                      _buildGlassField("ABCDE"),
                      const SizedBox(height: 15),
                      _buildGlassField("Write your complain here", maxLines: 5),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4F7957),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          child: const AppText("Send to admin", color: Colors.white),
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

  Widget _buildGlassField(String hint, {int maxLines = 1}) {
    return TextField(
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white.withOpacity(0.5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }
}