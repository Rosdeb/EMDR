import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jonssony/utils/app_text.dart';

import 'package:jonssony/views/sessions/ai_guide.dart' hide AppText;
import 'package:jonssony/views/sessions/session_five.dart';
import 'package:url_launcher/url_launcher.dart';

class SessionFourPage extends StatefulWidget {
  const SessionFourPage({super.key});

  @override
  State<SessionFourPage> createState() => _SessionFourPageState();
}

class _SessionFourPageState extends State<SessionFourPage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Roadmap Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/roadmap_path.png',
              fit: BoxFit.cover,
            ),
          ),

          // Glassmorphic Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.3),
                  ],
                ),
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                const Spacer(),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const AppText(
                          "Create Your Roadmap",
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        const AppText(
                          "Choose how you want to prepare for your EMDR journey",
                          fontSize: 14,
                          color: Colors.white70,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),
                        
                        _buildRoadmapOption(
                          title: "AI-Guided Roadmap",
                          subtitle: "Prepare via interactive sessions",
                          icon: Icons.auto_awesome,
                          imagePath: 'assets/images/ai_guide_bg.jpg',
                          onTap: () => Get.to(() => const EmdrCompanionPage()),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        _buildRoadmapOption(
                          title: "Psychologist Consultation",
                          subtitle: "Professional one-on-one help",
                          icon: Icons.psychology,
                          imagePath: 'assets/images/book_bg.jpg',
                          onTap: () => _showConsultationDialog(),
                        ),
                        
                        const SizedBox(height: 40),

                        // Continue to Session 5
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: () => Get.to(() => const SessionFive()),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF537E5D),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              elevation: 0,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AppText("Save & Continue", color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          const AppText("Session 4", color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ],
      ),
    );
  }

  Widget _buildRoadmapOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken),
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withOpacity(0.2)),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(title, color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        const SizedBox(height: 5),
                        AppText(subtitle, color: Colors.white70, fontSize: 13),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showConsultationDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(25),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_month, color: Color(0xFF537E5D), size: 50),
            const SizedBox(height: 20),
            const AppText("Book a Consultation", fontSize: 20, fontWeight: FontWeight.bold),
            const SizedBox(height: 10),
            const AppText(
              "Schedule a session with a qualified psychologist to create your roadmap manually.",
              textAlign: TextAlign.center,
              color: Colors.black54,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  // Link to book (placeholder)
                  const url = 'https://sparktechagency.com/booking';
                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(Uri.parse(url));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF537E5D),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const AppText("Visit Booking Site", color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 15),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const AppText("Cancel", color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
