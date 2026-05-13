import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../controller/bilateral_controller.dart';
import '../../controller/media_controller.dart';
import 'simulation_settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final BilateralController _bilateralController =
      Get.find<BilateralController>();
  final MediaController _mediaController = Get.find<MediaController>();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final Color primaryGreen = const Color(0xFF5A7D63);

  String? selectedEnvUrl;
  String? selectedObjUrl;
  String? selectedSoundUrl;
  String selectedSoundName = "Silent";
  double selectedSpeed = 3.0;
  AnimationDirection selectedDir = AnimationDirection.horizontal;

  static const List<Map<String, String>> _fallbackEnvironmentOptions = [
    {'name': 'Mountain', 'url': 'assets/images/mountain.jpg'},
    {'name': 'Water', 'url': 'assets/images/water.png'},
    {'name': 'Soft Light', 'url': 'assets/images/emdr_sun.jpg'},
  ];

  static const List<Map<String, String>> _fallbackObjectOptions = [
    {
      'name': 'Butterfly',
      'url': 'assets/images/Butterfly Lottie Animation.gif',
    },
    {'name': 'Ball', 'url': 'assets/images/ball.png'},
    {'name': 'Star', 'url': 'assets/images/star.png'},
    {'name': 'Leaf', 'url': 'assets/images/leaf.png'},
    {'name': 'Feather', 'url': 'assets/images/feather.png'},
    {'name': 'Sun', 'url': 'assets/images/sun.png'},
  ];

  @override
  void initState() {
    super.initState();
    _initSettings();
  }

  void _initSettings() {
    final envs = _envOptions;
    if (envs.isNotEmpty) {
      selectedEnvUrl = envs.first['url'];
    }

    final objs = _objectOptions;
    if (objs.isNotEmpty) {
      selectedObjUrl = objs.first['url'];
    }

    if (_bilateralController.userSettings.isNotEmpty) {
      final userSettings = _bilateralController.userSettings;
      final savedEnvUrl = userSettings['environmentId']?.toString() ?? '';
      if (_isSupportedImageSource(savedEnvUrl)) {
        selectedEnvUrl = savedEnvUrl;
      }
      final savedObjUrl = userSettings['iconUrl']?.toString() ?? '';
      if (_isSupportedImageSource(savedObjUrl)) {
        selectedObjUrl = savedObjUrl;
      }
      selectedSoundUrl = userSettings['soundId'];

      final speedStr = userSettings['speed'];
      if (speedStr == 'slow') {
        selectedSpeed = 5.0;
      } else if (speedStr == 'medium')
        selectedSpeed = 3.0;
      else if (speedStr == 'fast')
        selectedSpeed = 1.2;

      final dirStr = userSettings['direction'];
      if (dirStr == 'left-right') {
        selectedDir = AnimationDirection.horizontal;
      } else if (dirStr == 'top-bottom') {
        selectedDir = AnimationDirection.vertical;
      } else if (dirStr == 'diagonal-down')
        selectedDir = AnimationDirection.diagonal;
      else if (dirStr == 'diagonal-up')
        selectedDir = AnimationDirection.diagonalReverse;

      if (selectedSoundUrl != null && selectedSoundUrl!.isNotEmpty) {
        final sounds =
            _mediaController.mediaByCategory['Bilateral Stimulation Sound'] ??
            [];
        final soundObj = sounds.firstWhere(
          (s) => s['url'] == selectedSoundUrl,
          orElse: () => null,
        );
        if (soundObj != null) {
          selectedSoundName = soundObj['name'] ?? "Custom Sound";
        } else {
          selectedSoundName = "Selected Sound";
        }
      } else {
        selectedSoundName = "Silent";
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Widget _glassCard({
    required Widget child,
    bool isSelected = false,
    double borderRadius = 12,
    EdgeInsetsGeometry? padding,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: padding ?? const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.white.withOpacity(0.3)
                : Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: isSelected ? primaryGreen : Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: _glassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Color(0xFF333333),
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F1EC),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.4,
              child: Image.asset(
                "assets/images/bg_library.jpg",
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Obx(() {
              if (_bilateralController.isLoading.value ||
                  _mediaController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  15,
                  0,
                  15,
                  MediaQuery.of(context).padding.bottom + 30,
                ),
                child: Column(
                  children: [
                    _buildHeader(),
                    _buildSection(
                      title: "Visual Environments",
                      child: _buildEnvList(),
                    ),
                    _buildSection(
                      title: "Visual Object",
                      child: _buildObjectGrid(),
                    ),
                    _buildSection(title: "Sound", child: _buildSoundGrid()),
                    _buildSection(
                      title: "Direction",
                      child: _buildDirectionGrid(),
                    ),
                    _buildSection(title: "Speed", child: _buildSpeedRow()),
                    const SizedBox(height: 10),
                    _buildActionButtons(),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 25),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(20),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFF333333),
                  size: 22,
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Bilateral Stimulation",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontFamily: 'Serif',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Customise your calming experience",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Visual Environment (horizontal scroll) ──────────────────────────────────
  Widget _buildEnvList() {
    final envs = _envOptions;
    if (envs.isEmpty) return const Text("No environments available");

    if (!_isSupportedImageSource(selectedEnvUrl) && envs.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => selectedEnvUrl = envs.first['url']);
      });
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: envs.map((env) {
          final String fileUrl = env['url'] ?? '';
          bool isSelected = selectedEnvUrl == fileUrl;
          return GestureDetector(
            onTap: () => setState(() => selectedEnvUrl = fileUrl),
            child: Container(
              width: 120,
              height: 90,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? primaryGreen : Colors.transparent,
                  width: 2.5,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _isNetworkUrl(fileUrl)
                    ? CachedNetworkImage(
                        imageUrl: fileUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      )
                    : Image.asset(
                        fileUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image),
                      ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Visual Object (3-column icon grid) ─────────────────────────────────────
  Widget _buildObjectGrid() {
    final objects = _objectOptions;
    if (objects.isEmpty) return const Text("No objects available");

    if (!_isSupportedImageSource(selectedObjUrl)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => selectedObjUrl = objects.first['url']);
      });
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisExtent: 85,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: objects.length,
      itemBuilder: (context, index) {
        final String path = objects[index]['url'] ?? '';
        final String name = objects[index]['name'] ?? 'Object';
        final bool isSelected = selectedObjUrl == path;
        return GestureDetector(
          onTap: () => setState(() => selectedObjUrl = path),
          child: _glassCard(
            isSelected: isSelected,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildObjectThumbnail(path),
                const SizedBox(height: 6),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    color: isSelected ? primaryGreen : Colors.black54,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Object thumbnails
  List<Map<String, String>> get _envOptions {
    final mediaEnvs = List<dynamic>.from(
      _mediaController.mediaByCategory['Bilateral Stimulation img'] ?? [],
    );

    final apiOptions = _mediaImageOptions(mediaEnvs);
    return apiOptions.isNotEmpty ? apiOptions : _fallbackEnvironmentOptions;
  }

  List<Map<String, String>> get _objectOptions {
    final mediaObjects = List<dynamic>.from(
      _mediaController.mediaByCategory['Bilateral Stimulation Visual icon'] ??
          [],
    );

    final apiOptions = mediaObjects
        .map(
          (object) => {
            'name': (object['name'] ?? 'Object').toString(),
            'url': (object['url'] ?? '').toString(),
          },
        )
        .where((object) => _isSupportedImageSource(object['url']))
        .toList();

    return apiOptions.isNotEmpty ? apiOptions : _fallbackObjectOptions;
  }

  List<Map<String, String>> _mediaImageOptions(List<dynamic> mediaItems) {
    return mediaItems
        .map(
          (item) => {
            'name': (item['name'] ?? 'Image').toString(),
            'url': (item['url'] ?? '').toString(),
          },
        )
        .where((item) => _isSupportedImageSource(item['url']))
        .toList();
  }

  bool _isNetworkUrl(String? value) {
    if (value == null || value.trim().isEmpty) return false;
    final uri = Uri.tryParse(value.trim());
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  bool _isSupportedImageSource(String? value) {
    if (value == null || value.trim().isEmpty) return false;
    return _isNetworkUrl(value) || value.trim().startsWith('assets/');
  }

  Widget _buildObjectThumbnail(String path) {
    if (path.isEmpty) {
      return const Icon(Icons.broken_image, size: 32);
    }

    if (path.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: path,
        width: 32,
        height: 32,
        fit: BoxFit.contain,
        placeholder: (context, url) => const SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(strokeWidth: 1.5),
        ),
        errorWidget: (context, url, error) =>
            const Icon(Icons.broken_image, size: 32),
      );
    }

    return Image.asset(
      path,
      width: 32,
      height: 32,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.broken_image, size: 32),
    );
  }

  // Sound (3-column icon grid)
  Widget _buildSoundGrid() {
    final sounds = List<dynamic>.from(
      _mediaController.mediaByCategory['Bilateral Stimulation Sound'] ?? [],
    );
    sounds.add({"name": "Silent", "url": ""});

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisExtent: 85,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: sounds.length,
      itemBuilder: (context, index) {
        final String soundName = sounds[index]['name'] ?? "Sound";
        final String audioPath = sounds[index]['url'] ?? "";
        final bool isSelected = selectedSoundName == soundName;
        return GestureDetector(
          onTap: () async {
            setState(() {
              selectedSoundName = soundName;
              selectedSoundUrl = audioPath.isEmpty ? null : audioPath;
            });
            if (audioPath.isNotEmpty) {
              await _audioPlayer.stop();
              await _audioPlayer.play(UrlSource(audioPath));
            } else {
              await _audioPlayer.stop();
            }
          },
          child: _glassCard(
            isSelected: isSelected,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  audioPath.isEmpty ? Icons.volume_off : Icons.audiotrack,
                  color: isSelected ? primaryGreen : Colors.black54,
                  size: 28,
                ),
                const SizedBox(height: 6),
                Text(
                  soundName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    color: isSelected ? primaryGreen : Colors.black54,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Direction (3-column row grid) ───────────────────────────────────────────
  Widget _buildDirectionGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.8,
      children: [
        _dirIcon(
          "assets/images/horzental.png",
          AnimationDirection.horizontal,
          "Horizontal",
        ),
        _dirIcon(
          "assets/images/vertical.png",
          AnimationDirection.vertical,
          "Vertical",
        ),
        _dirIcon(
          "assets/images/digonal.png",
          AnimationDirection.diagonal,
          "Diagonal Down",
        ),
        _dirIcon(
          "assets/images/arrow.png",
          AnimationDirection.diagonalReverse,
          "Diagonal Up",
        ),
      ],
    );
  }

  Widget _dirIcon(String iconPath, AnimationDirection dir, String label) {
    bool isSelected = selectedDir == dir;
    return GestureDetector(
      onTap: () => setState(() => selectedDir = dir),
      child: _glassCard(
        isSelected: isSelected,
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(iconPath, width: 26, height: 26, fit: BoxFit.contain),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? primaryGreen : Colors.black54,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ── Speed (3-column row grid) ───────────────────────────────────────────────
  Widget _buildSpeedRow() {
    return Row(
      children: [
        Expanded(child: _speedBox("Slow", 5.0, "assets/images/slow.png")),
        const SizedBox(width: 10),
        Expanded(child: _speedBox("Medium", 3.0, "assets/images/medium.png")),
        const SizedBox(width: 10),
        Expanded(child: _speedBox("Fast", 1.2, "assets/images/fast.png")),
      ],
    );
  }

  Widget _speedBox(String label, double speed, String iconPath) {
    bool isSelected = selectedSpeed == speed;
    return GestureDetector(
      onTap: () => setState(() => selectedSpeed = speed),
      child: _glassCard(
        isSelected: isSelected,
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(iconPath, width: 26, height: 26, fit: BoxFit.contain),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            Text(
              "${speed == speed.roundToDouble() ? speed.toInt() : speed.toStringAsFixed(1)}s",
              style: const TextStyle(fontSize: 9, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  // ── Save Button ─────────────────────────────────────────────────────────────
  Widget _buildActionButtons() {
    return Obx(() {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _bilateralController.isSaving.value
              ? null
              : () async {
                  final environmentUrl = selectedEnvUrl?.trim() ?? '';
                  final objectUrl = selectedObjUrl?.trim() ?? '';

                  if (environmentUrl.isEmpty) {
                    Get.snackbar(
                      'Error',
                      'Please select an environment',
                      backgroundColor: Colors.redAccent,
                      colorText: Colors.white,
                    );
                    return;
                  }
                  if (objectUrl.isEmpty) {
                    Get.snackbar(
                      'Error',
                      'Please select a visual object',
                      backgroundColor: Colors.redAccent,
                      colorText: Colors.white,
                    );
                    return;
                  }
                  if (!_isSupportedImageSource(environmentUrl)) {
                    Get.snackbar(
                      'Error',
                      'Selected environment is invalid',
                      backgroundColor: Colors.redAccent,
                      colorText: Colors.white,
                    );
                    return;
                  }
                  if (!_isSupportedImageSource(objectUrl)) {
                    Get.snackbar(
                      'Error',
                      'Selected object is invalid',
                      backgroundColor: Colors.redAccent,
                      colorText: Colors.white,
                    );
                    return;
                  }

                  String speedStr = 'medium';
                  if (selectedSpeed == 5.0) speedStr = 'slow';
                  if (selectedSpeed == 1.2) speedStr = 'fast';

                  String dirStr = 'left-right';
                  if (selectedDir == AnimationDirection.vertical) {
                    dirStr = 'top-bottom';
                  }
                  if (selectedDir == AnimationDirection.diagonal) {
                    dirStr = 'diagonal-down';
                  }
                  if (selectedDir == AnimationDirection.diagonalReverse) {
                    dirStr = 'diagonal-up';
                  }

                  await _bilateralController.saveSettings(
                    environmentUrl: environmentUrl,
                    iconUrl: objectUrl,
                    soundUrl: selectedSoundUrl ?? '',
                    speed: speedStr,
                    direction: dirStr,
                  );
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryGreen,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(16),
          ),
          child: _bilateralController.isSaving.value
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/save.png",
                      width: 20,
                      height: 20,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 8),
                    const Flexible(
                      child: Text(
                        "Save Settings",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                ),
        ),
      );
    });
  }
}
