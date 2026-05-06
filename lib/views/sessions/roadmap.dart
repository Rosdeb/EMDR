import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jonssony/utils/app_colors.dart';
import 'package:jonssony/views/sessions/session_one.dart';

class CreateRoadmapPage extends StatelessWidget {
  const CreateRoadmapPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Color(0xFFFFF8F0),
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
              icon: Icons.assignment_turned_in_outlined,
              title: "Session",
              description: "Chat with our intelligent assistant to identify your target memory, negative beliefs, and emotions.",
              buttonText: "View Sessions",
              buttonColor: AppColors.mainAppColor,
              onTap: () {
                Get.to(() => SessionOne());
              },


            ),

            const SizedBox(height: 25),

            _buildRoadmapCard(
              context,
              imagePath: 'assets/images/book_bg.jpg',
              icon: Icons.bar_chart_rounded,
              title: "Book Consultation",
              description: "Schedule a video call with a qualified psychologist to help you create your roadmap.",
              buttonText: "Book Session",
              buttonColor: AppColors.mainAppColor,
              onTap: () {},
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
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