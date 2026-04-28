import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jonssony/controller/journey_controller.dart';
import 'package:jonssony/controller/media_controller.dart';
import 'package:jonssony/views/sessions/session_one.dart';
import 'package:jonssony/widets/custom_home_bg.dart';

class CreateJourneyPage extends StatefulWidget {
  const CreateJourneyPage({super.key});

  @override
  State<CreateJourneyPage> createState() => _CreateJourneyPageState();
}

class _CreateJourneyPageState extends State<CreateJourneyPage> {
  final JourneyController _journeyController = Get.find<JourneyController>();
  final MediaController _mediaController = Get.find<MediaController>();

  // User-typed journey name (POST body: journeyName)
  final _nameController = TextEditingController();
  final _descController = TextEditingController();

  int _selectedApiImageIndex = -1;

  static const _imgCat = 'Create Your Journey img';



  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      Get.snackbar('Error', 'Please enter a journey name',
          backgroundColor: Colors.red.shade100, colorText: Colors.red.shade800);
      return;
    }

    final imgs = _mediaController.mediaByCategory[_imgCat] ?? [];
    if (_selectedApiImageIndex < 0) {
      Get.snackbar('Error', 'Please choose an image',
          backgroundColor: Colors.red.shade100, colorText: Colors.red.shade800);
      return;
    }

    final imageUrl = _selectedApiImageIndex >= 0 && _selectedApiImageIndex < imgs.length
        ? imgs[_selectedApiImageIndex]['url'] ?? ''
        : '';

    // POST /journeys  { journeyName, description, imageUrl }
    final result = await _journeyController.createJourney(
      journeyName: name,
      description: _descController.text.trim(),
      imageUrl: imageUrl,
    );

    if (result['success'] == true) {
      Get.snackbar('Success', 'Journey created!',
          backgroundColor: Colors.green.shade100, colorText: Colors.green.shade900);
      Get.to(() => const SessionOne());
    } else {
      Get.snackbar('Error', result['message'] ?? 'Something went wrong',
          backgroundColor: Colors.red.shade100, colorText: Colors.red.shade800);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.35),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.4)),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Color(0xFF2E3E32), size: 18),
                ),
              ),
            ),
          ),
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

                  // ─── Journey Name TextField ────────────────────────
                  const Text("Journey Name",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        hintText: 'e.g. My Healing Journey',
                        hintStyle: TextStyle(color: Colors.black38, fontSize: 14),
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // ─── Description ───────────────────────────────────
                  const Text("Description (Optional)",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 10),
                  Container(
                    height: 100,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _descController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: "Describe your journey goal...",
                        hintStyle: TextStyle(color: Colors.black38, fontSize: 14),
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // ─── Choose Image Grid ─────────────────────────────
                  const Text("Choose Your Journey Image",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 15),

                  Obx(() {
                    final imgs = _mediaController.mediaByCategory[_imgCat] ?? [];

                    if (imgs.isEmpty) {
                      // Fallback: show placeholder tiles while images load
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: 9,
                        itemBuilder: (context, index) {
                          bool isSelected = _selectedApiImageIndex == index;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedApiImageIndex = index),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: isSelected
                                    ? Border.all(
                                        color: const Color(0xFF5D7E5D),
                                        width: 3)
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
                      );
                    }

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: imgs.length,
                      itemBuilder: (context, index) {
                        final url = imgs[index]['url'] ?? '';
                        bool isSelected = _selectedApiImageIndex == index;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedApiImageIndex = index),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: isSelected
                                  ? Border.all(
                                      color: const Color(0xFF5D7E5D), width: 3)
                                  : null,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  CachedNetworkImage(
                                    imageUrl: url,
                                    fit: BoxFit.cover,
                                    placeholder: (c, u) => const Center(
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2)),
                                    errorWidget: (c, u, e) => Image.asset(
                                        'assets/images/journey_image.jpg',
                                        fit: BoxFit.contain),
                                  ),
                                  if (isSelected)
                                    Container(
                                      color: Colors.black.withOpacity(0.2),
                                      child: const Icon(Icons.check_circle,
                                          color: Colors.white, size: 26),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }),

                  const SizedBox(height: 30),

                  // ─── Start Session Button ──────────────────────────
                  Obx(() => SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed:
                              _journeyController.isSaving.value ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5D7E5D),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _journeyController.isSaving.value
                              ? const CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2)
                              : const Text(
                                  "Start Session",
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.white),
                                ),
                        ),
                      )),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}