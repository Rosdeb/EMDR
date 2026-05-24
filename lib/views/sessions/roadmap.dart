import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jonssony/utils/app_colors.dart';
import 'package:jonssony/views/sessions/session_one.dart';

class CreateRoadmapPage extends StatelessWidget {
  const CreateRoadmapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1EA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2E3E32)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Create Your Roadmap",
          style: TextStyle(
            color: Color(0xFF2E3E32),
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            _buildRoadmapCard(
              context,
              imagePath: 'assets/images/ai_guide_bg.jpg',
              icon: Icons.psychology_alt_outlined,
              title: "Chat to virtual assistant Sigmund",
              description:
                  "With the help of Sigmund and his psychological assessment questions you can begin to create your EMDR roadmap.",
              buttonText: "Start now",
              buttonColor: AppColors.mainAppColor,
              onTap: () {
                _showSessionIntro(context);
              },
            ),

            const SizedBox(height: 25),

            _buildRoadmapCard(
              context,
              imagePath: 'assets/images/book_bg.jpg',
              icon: Icons.calendar_month_outlined,
              title: "Book Consultation",
              description:
                  "Book a 60 minute consultation (Price not included in your plan) with one of our EMDR trained clinical psychologists.",
              buttonText: "Book now",
              buttonColor: AppColors.mainAppColor,
              onTap: () {},
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  void _showSessionIntro(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Before you start",
                style: TextStyle(
                  color: Color(0xFF2E3E32),
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Please watch this video to help understand about EMDR.",
                style: TextStyle(
                  color: Color(0xFF4B5563),
                  fontSize: 15,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Get.to(() => const SessionOne(), arguments: Get.arguments);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mainAppColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Watch video",
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRoadmapCard(
    BuildContext context, {
    required String imagePath,
    required IconData icon,
    required String title,
    required String description,
    required String buttonText,
    required Color buttonColor,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
                child: Image.asset(
                  imagePath,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: const Color(0xFF00A382), size: 30),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(22.0),
            child: Column(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A4A4A),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF7A7A7A),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      // shape: circular(12),
                      elevation: 0,
                    ),
                    child: Text(
                      buttonText,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
