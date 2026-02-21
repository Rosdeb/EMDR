import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jonssony/views/chatbot/roadmap.dart';
import 'package:jonssony/widets/custom_home_bg.dart';

class CreateJourneyPage extends StatefulWidget {
  const CreateJourneyPage({super.key});

  @override
  State<CreateJourneyPage> createState() => _CreateJourneyPageState();
}

class _CreateJourneyPageState extends State<CreateJourneyPage> {
  int selectedImageIndex = 1;
  String? selectedJourney;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2E3E32)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Create Your Journey",
          style: TextStyle(
            color: Color(0xFF2E3E32),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Stack(
        children: [

          Custom_Home_Bg(),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 25),
                  const Text("Journey Name", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        hint: const Text(
                          "Select your journey",
                          style: TextStyle(color: Colors.black45, fontSize: 14),
                        ),
                        value: selectedJourney,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded,
                            color: Color(0xFF5D7E5D)),
                        items: const [
                          DropdownMenuItem(
                            value: 'Anxiety Management Journey',
                            child: Text('Anxiety Management Journey'),
                          ),
                          DropdownMenuItem(
                            value: 'Childhood Trauma Processing',
                            child: Text('Childhood Trauma Processing'),
                          ),
                          DropdownMenuItem(
                            value: 'Grief and Loss Support',
                            child: Text('Grief and Loss Support'),
                          ),
                        ],
                        onChanged: (value) =>
                            setState(() => selectedJourney = value),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),


                  Container(
                    height: 120,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const TextField(
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: "Description (Optional)",
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),
                  const Text("Choose Your Journey Image", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 15),


                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: 9,
                    itemBuilder: (context, index) {
                      bool isSelected = selectedImageIndex == index;
                      return GestureDetector(
                        onTap: () => setState(() => selectedImageIndex = index),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: isSelected
                                ? Border.all(color: const Color(0xFF5D7E5D), width: 3)
                                : null,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              'assets/images/journey_image.jpg',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 30),


                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.to(() => CreateRoadmapPage());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5D7E5D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Start Session",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  /* back button has more blur , image picker and audio player add kore dew    */
}