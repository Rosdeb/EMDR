import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jonssony/controller/bilateral_controller.dart';
import 'package:jonssony/controller/media_controller.dart';
import 'package:jonssony/utils/app_colors.dart';
import 'package:jonssony/utils/app_text.dart';
import 'package:jonssony/views/Library/simulation_screen.dart';
import 'package:jonssony/views/Library/simulation_settings.dart';
import 'package:jonssony/views/sessions/session_six.dart';

class SessionBilateralSimulation extends StatefulWidget {
  const SessionBilateralSimulation({super.key});

  @override
  State<SessionBilateralSimulation> createState() =>
      _SessionBilateralSimulationState();
}

class _SessionBilateralSimulationState
    extends State<SessionBilateralSimulation> {
  final BilateralController _bilateralController =
      Get.find<BilateralController>();
  final MediaController _mediaController = Get.find<MediaController>();
  static const String _defaultVisualObject =
      'assets/images/Butterfly Lottie Animation.gif';

  @override
  void initState() {
    super.initState();
    _loadMissingData();
  }

  Future<void> _loadMissingData() async {
    if (_bilateralController.userSettings.isEmpty &&
        !_bilateralController.isLoading.value) {
      await _bilateralController.fetchConfig();
    }
    if (_mediaController.mediaByCategory.isEmpty &&
        !_mediaController.isLoading.value) {
      await _mediaController.fetchAllMedia();
    }
  }

  SimulationSettings _buildSimulationSettings() {
    final settings = _bilateralController.userSettings;

    final environments =
        _mediaController.mediaByCategory['Bilateral Stimulation img'] ?? [];
    final sounds =
        _mediaController.mediaByCategory['Bilateral Stimulation Sound'] ?? [];

    final speedStr = settings['speed']?.toString() ?? 'medium';
    double speed = 4.0;
    if (speedStr == 'slow') speed = 8.0;
    if (speedStr == 'fast') speed = 2.0;

    final dirStr = settings['direction']?.toString() ?? 'left-right';
    AnimationDirection direction = AnimationDirection.horizontal;
    if (dirStr == 'top-bottom') direction = AnimationDirection.vertical;
    if (dirStr == 'diagonal-down') direction = AnimationDirection.diagonal;
    if (dirStr == 'diagonal-up') {
      direction = AnimationDirection.diagonalReverse;
    }

    return SimulationSettings(
      environmentImage: settings['environmentId']?.toString().isNotEmpty == true
          ? settings['environmentId'].toString()
          : environments.isNotEmpty
          ? (environments.first['url'] ?? 'assets/images/mountain.jpg')
                .toString()
          : 'assets/images/mountain.jpg',
      visualObject: settings['iconUrl']?.toString().isNotEmpty == true
          ? settings['iconUrl'].toString()
          : _defaultVisualObject,
      speed: speed,
      audioAsset: settings['soundId']?.toString().isNotEmpty == true
          ? settings['soundId'].toString()
          : sounds.isNotEmpty
          ? (sounds.first['url'] ?? '').toString()
          : '',
      direction: direction,
      isNetworkImage: settings.isNotEmpty || environments.isNotEmpty,
    );
  }

  void _startSimulation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SimulationScreen(settings: _buildSimulationSettings()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg_library.jpg',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: Obx(() {
                    if (_bilateralController.isLoading.value ||
                        _mediaController.isLoading.value) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.mainAppColor,
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _buildContentCard(),
                          const SizedBox(height: 20),
                          _buildPrimaryButton(
                            "Begin Bilateral Simulation",
                            _startSimulation,
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: () => Get.to(
                              () => const SessionSix(),
                              arguments: Get.arguments,
                            ),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 54),
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: Colors.white.withOpacity(0.8),
                            ),
                            child: const Text(
                              "Continue to Next Session",
                              style: TextStyle(color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Get.back(),
          ),
          const Text(
            "Bilateral Simulation",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            spreadRadius: 4,
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.blur_on_rounded, color: AppColors.mainAppColor, size: 42),
          SizedBox(height: 16),
          AppText(
            "Follow the moving object",
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E3E32),
          ),
          SizedBox(height: 12),
          AppText(
            "Your saved bilateral stimulation settings from the Library will be used here. You can watch the movement and listen to the selected sound in this session step.",
            fontSize: 14,
            color: Colors.black87,
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.mainAppColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
