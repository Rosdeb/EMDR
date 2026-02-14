import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'simulation_settings.dart';
import 'simulation_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final Color primaryGreen = const Color(0xFF5A7D63);

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  // Default Selections
  String selectedEnv = "assets/images/mountain.jpg";
  String selectedObj = "assets/images/butterfly.png";
  String selectedSound = "Gentle Tone";
  double selectedSpeed = 4.0;
  AnimationDirection selectedDir = AnimationDirection.horizontal;

  Widget _glassCard({required Widget child, bool isSelected = false, double borderRadius = 12, EdgeInsetsGeometry? padding}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: padding ?? const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white.withOpacity(0.3) : Colors.white.withOpacity(0.15),
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
          // Background Texture
          Positioned.fill(
            child: Opacity(
              opacity: 0.4,
              child: Image.asset("assets/images/bg_library.jpg", fit: BoxFit.cover),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildHeader(),

                  _buildSection(title: "Visual Environments", child: _buildEnvList()),
                  _buildSection(title: "Visual Object", child: _buildObjectGrid()),
                  _buildSection(title: "Sound", child: _buildSoundGrid()),
                  _buildSection(title: "Direction", child: _buildDirectionGrid()),
                  _buildSection(title: "Speed", child: _buildSpeedRow()),

                  const SizedBox(height: 10),
                  _buildActionButtons(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 25),
      child: Column(
        children: [
          Text("Bilateral Stimulation",
              style: TextStyle(fontSize: 28, fontFamily: 'Serif', fontWeight: FontWeight.w500)),
          SizedBox(height: 4),
          Text("Customise your calming experience",
              style: TextStyle(color: Colors.black54, fontSize: 14)),
        ],
      ),
    );
  }

  // 1. Environments Horizontal List
  Widget _buildEnvList() {
    List<Map<String, String>> envs = [
      {"name": "Mountain", "path": "assets/images/mountain.jpg"},
      {"name": "Lake", "path": "assets/images/make_more.jpg"},
      {"name": "Night", "path": "assets/images/night.jpg"},
    ];
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: envs.length,
        itemBuilder: (context, index) {
          bool isSelected = selectedEnv == envs[index]['path'];
          return GestureDetector(
            onTap: () => setState(() => selectedEnv = envs[index]['path']!),
            child: Container(
              width: 120,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isSelected ? primaryGreen : Colors.transparent, width: 2.5),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(envs[index]['path']!, fit: BoxFit.cover),
              ),
            ),
          );
        },
      ),
    );
  }

  // 2. Objects Grid
  Widget _buildObjectGrid() {
    List<Map<String, dynamic>> items = [
      {"name": "Ball", "icon": "assets/images/ball.png"},
      {"name": "Feather", "icon": "assets/images/feather.png"},
      {"name": "Star", "icon": "assets/images/star.png"},
      {"name": "Leaf", "icon": "assets/images/leaf.png"},
      {"name": "Sun", "icon": "assets/images/sun.png"},
      {"name": "Butterfly", "icon": "assets/images/butterfly.png"},
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, childAspectRatio: 3, crossAxisSpacing: 10, mainAxisSpacing: 10),
      itemCount: items.length,
      itemBuilder: (context, index) {
        String path = items[index]['icon'];
        bool isSelected = selectedObj == path;
        return InkWell(
          onTap: () => setState(() => selectedObj = path),
          child: _glassCard(
            isSelected: isSelected,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Image.asset(
                  items[index]['icon'], 
                  width: 20, 
                  height: 20,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 8),
                Text(items[index]['name'], style: TextStyle(fontSize: 13, color: isSelected ? primaryGreen : Colors.black87)),
              ],
            ),
          ),
        );
      },
    );
  }

  // 3. Sound Grid
  Widget _buildSoundGrid() {
    List<Map<String, dynamic>> sounds = [
      {"name": "Gentle Tone", "icon": "assets/images/gentle.png", "audio": "assets/audio/calm place.wav"},
      {"name": "Soft Chime", "icon": "assets/images/Soft.png", "audio": "assets/audio/puppies_v1.mp3"},
      {"name": "Water Drop", "icon": "assets/images/water.png", "audio": "assets/audio/calm place.wav"}, // Placeholder
      {"name": "Soft Breath", "icon": "assets/images/breath.png", "audio": "assets/audio/puppies_v1.mp3"}, // Placeholder
      {"name": "Singing Bowl", "icon": "assets/images/bowl.png", "audio": "assets/audio/calm place.wav"}, // Placeholder
      {"name": "Silent", "icon": "assets/images/silent.png", "audio": ""},
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, childAspectRatio: 3, crossAxisSpacing: 10, mainAxisSpacing: 10),
      itemCount: sounds.length,
      itemBuilder: (context, index) {
        String soundName = sounds[index]['name'];
        bool isSelected = selectedSound == soundName;
        return InkWell(
          onTap: () async {
            setState(() => selectedSound = soundName);
            String audioPath = sounds[index]['audio'];
            if (audioPath.isNotEmpty) {
              await _audioPlayer.stop();
              // Remove "assets/" prefix for DeviceFileSource if needed, or use AssetSource correctly
              // audioplayers 4.x+ uses AssetSource which takes path inside assets/
              // The path in map is full "assets/audio/...", AssetSource needs "audio/..."
              if (audioPath.startsWith("assets/")) {
                 await _audioPlayer.play(AssetSource(audioPath.substring(7)));
              } else {
                 await _audioPlayer.play(AssetSource(audioPath));
              }
            } else {
              await _audioPlayer.stop();
            }
          },
          child: _glassCard(
            isSelected: isSelected,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Image.asset(
                  sounds[index]['icon'], 
                  width: 25, 
                  height: 25,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 8),
                Text(soundName, style: TextStyle(fontSize: 12, color: isSelected ? primaryGreen : Colors.black87)),
              ],
            ),
          ),
        );
      },
    );
  }

  // 4. Direction
  Widget _buildDirectionGrid() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _dirIcon("assets/images/horzental.png", AnimationDirection.horizontal, "Horizontal"),
        _dirIcon("assets/images/vertical.png", AnimationDirection.vertical, "Vertical"),
        _dirIcon("assets/images/digonal.png", AnimationDirection.diagonal, "Diagonal"),
      ],
    );
  }

  Widget _dirIcon(String iconPath, AnimationDirection dir, String label) {
    bool isSelected = selectedDir == dir;
    return GestureDetector(
      onTap: () => setState(() => selectedDir = dir),
      child: SizedBox(
        width: 90,
        child: _glassCard(
          isSelected: isSelected,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              Image.asset(
                iconPath, 
                width: 25, 
                height: 25,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(fontSize: 10, color: isSelected ? primaryGreen : Colors.black54)),
            ],
          ),
        ),
      ),
    );
  }

  // 5. Speed
  Widget _buildSpeedRow() {
    return Row(
      children: [
        _speedBox("Slow", 8.0, "assets/images/slow.png"),
        const SizedBox(width: 10),
        _speedBox("Medium", 4.0, "assets/images/medium.png"),
        const SizedBox(width: 10),
        _speedBox("Fast", 2.0, "assets/images/fast.png"),
      ],
    );
  }

  Widget _speedBox(String label, double speed, String iconPath) {
    bool isSelected = selectedSpeed == speed;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedSpeed = speed),
        child: _glassCard(
          isSelected: isSelected,
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            children: [
              Image.asset(
                iconPath,
                width: 25, 
                height: 25,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 8),
              Text(label, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
              Text("${speed.toInt()}s", style: const TextStyle(fontSize: 9, color: Colors.black54)),
            ],
          ),
        ),
      ),
    );
  }

  // Action Buttons
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.black12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.all(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("assets/images/save.png", width: 20, height: 20, fit: BoxFit.contain),
                const SizedBox(width: 8),
                const Text("Save & Setting", style: TextStyle(color: Colors.black87)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => SimulationScreen(
                settings: SimulationSettings(
                  environmentImage: selectedEnv,
                  visualObject: selectedObj,
                  speed: selectedSpeed,
                  audioAsset: "assets/audio/calm_place.wav",
                  direction: selectedDir,
                ),
              )));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.all(16),
            ),
            child: const Text("Begin Session", style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ),
      ],
    );
  }
}