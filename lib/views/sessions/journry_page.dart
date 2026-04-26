import 'dart:io';
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

  final _descController = TextEditingController();

  String? _selectedJourneyName;
  int _selectedApiImageIndex = -1;

  static const _imgCat = 'Create Your Journey img';
  final Color _green = const Color(0xFF5D7E5D);

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final imgs = _mediaController.mediaByCategory[_imgCat] ?? [];
    final name = _selectedJourneyName ?? '';

    if (name.isEmpty) {
      Get.snackbar('Error', 'Please select a journey name',
          backgroundColor: Colors.red.shade100, colorText: Colors.red.shade800);
      return;
    }
    if (_selectedApiImageIndex < 0) {
      Get.snackbar('Error', 'Please choose an image',
          backgroundColor: Colors.red.shade100, colorText: Colors.red.shade800);
      return;
    }

    final imageUrl = _selectedApiImageIndex >= 0 && _selectedApiImageIndex < imgs.length
        ? imgs[_selectedApiImageIndex]['url'] ?? ''
        : '';

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

                  // ─── Journey Name Dropdown ─────────────────────────
                  const Text("Journey Name",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 10),
                  Obx(() {
                    final journeys = _journeyController.journeys;

                    // Deduplicate by _id to avoid DropdownButton assertion error
                    final seen = <String>{};
                    final uniqueJourneys = journeys.where((j) {
                      final id = j['_id']?.toString() ?? '';
                      return seen.add(id);
                    }).toList();

                    return Container(
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
                          value: _selectedJourneyName,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded,
                              color: Color(0xFF5D7E5D)),
                          items: uniqueJourneys.isEmpty
                              ? [
                                  const DropdownMenuItem(
                                    value: 'Anxiety Management Journey',
                                    child: Text('Anxiety Management Journey'),
                                  ),
                                  const DropdownMenuItem(
                                    value: 'Childhood Trauma Processing',
                                    child: Text('Childhood Trauma Processing'),
                                  ),
                                  const DropdownMenuItem(
                                    value: 'Grief and Loss Support',
                                    child: Text('Grief and Loss Support'),
                                  ),
                                ]
                              : uniqueJourneys.map<DropdownMenuItem<String>>((j) {
                                  final id   = j['_id']?.toString() ?? '';
                                  final name = j['journeyName'] ?? '';
                                  return DropdownMenuItem(
                                    value: id,
                                    child: Text(name,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 14)),
                                  );
                                }).toList(),
                          onChanged: (value) =>
                              setState(() => _selectedJourneyName = value),
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 15),

                  // ─── Description ───────────────────────────────────
                  Container(
                    height: 120,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _descController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: "Description (Optional)",
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