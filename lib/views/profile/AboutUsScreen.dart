import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:jonssony/widets/Custom_BackgroundDesign.dart';
import 'package:jonssony/widets/custom_appbar.dart';

class AboutUsScreen extends StatelessWidget {
  final String title;
  const AboutUsScreen({super.key, this.title = "About Us"});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BackgroundDesign(),
          Column(
            children: [
              Custom_AppBar(context, title),
              SizedBox(height: 120),
              Expanded(
                child: SingleChildScrollView(

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
                          border: Border.all(color: Colors.white.withOpacity(0.3)),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis.", style: TextStyle(fontSize: 14,   fontFamily: 'Serif',height: 1.5)),
                            SizedBox(height: 20),
                            Text("Our Mission", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis.", style: TextStyle(fontSize: 14,  fontFamily: 'Serif')),
                            SizedBox(height: 20),
                            Text("Our Vision", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis.", style: TextStyle(fontFamily: 'Serif',fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
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