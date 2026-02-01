import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:jonssony/utils/AppIcons/app_icons.dart';
import 'package:jonssony/utils/app_colors.dart';

class VideoCalmPage extends StatefulWidget {
  const VideoCalmPage({super.key});

  @override
  State<VideoCalmPage> createState() => _VideoCalmPageState();
}

class _VideoCalmPageState extends State<VideoCalmPage> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;


  final List<String> _options = [
    "I don't deserve love",
    "I am a bad person",
    "I am terrible",
    "I am worthless/inadequate",
    "I am shameful",
    "I am not lovable",
    "I am not good enough",
  ];
  final Set<int> _selectedIndices = {};

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    _videoPlayerController = VideoPlayerController.asset('assets/video/calm_exercise.mp4');
    await _videoPlayerController.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: false,
      aspectRatio: _videoPlayerController.value.aspectRatio,
      materialProgressColors: ChewieProgressColors(
        playedColor: const Color(0xFF537E5D),
        handleColor: const Color(0xFF537E5D),
      ),
    );
    setState(() {});
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // টপ ইমেজ
          Positioned(top: 0, left: 0, right: 0, height: 180,
            child: Image.asset('assets/images/my_emdr.png', fit: BoxFit.fill),
          ),

          Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: Stack(
                  children: [

                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(35), topRight: Radius.circular(35)),
                          image: DecorationImage(image: AssetImage('assets/images/home_bg1.jpg'), fit: BoxFit.cover),
                        ),
                      ),
                    ),

                    SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          const SizedBox(height: 50),


                          _buildMainGlassCard(),

                          const SizedBox(height: 150),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          _buildFloatingBottomNav(AppColors.mainAppColor),
        ],
      ),
    );
  }

  Widget _buildMainGlassCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.4),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              AspectRatio(
                aspectRatio: 16 / 9,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: _chewieController != null ? Chewie(controller: _chewieController!) : const Center(child: CircularProgressIndicator()),
                ),
              ),
              const SizedBox(height: 20),


              const Text("Your Journey Guide", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Serif')),
              const Text("When I was little (Childhood)", style: TextStyle(fontSize: 15, color: Colors.black87)),
              const SizedBox(height: 10),
              const Text(
                "Float back in time and see if you remember feeling this way from your situation as a child?",
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 15),


              Container(
                decoration: BoxDecoration(color: const Color(0xFFFDF9F3), borderRadius: BorderRadius.circular(15)),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _options.length,
                  itemBuilder: (context, index) {
                    bool isSelected = _selectedIndices.contains(index);
                    return CheckboxListTile(
                      value: isSelected,
                      title: Text(_options[index], style: const TextStyle(fontSize: 14)),
                      activeColor: const Color(0xFF537E5D),
                      onChanged: (val) => setState(() => val! ? _selectedIndices.add(index) : _selectedIndices.remove(index)),
                      controlAffinity: ListTileControlAffinity.leading,
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF537E5D), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      child: const Text("Save & Continue", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      child: const Text("Skip for now", style: TextStyle(color: Colors.black54)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // AppBar and Nav remains the same as your previous structure
  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20, left: 10, bottom: 10),
      child: Row(children: [
        IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        const Text("Session 1", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Serif')),
      ]),
    );
  }

  Widget _buildFloatingBottomNav(Color primaryColor) {
    return Positioned(bottom: 25, left: 15, right: 15,
      child: Row(children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(height: 75, decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), borderRadius: BorderRadius.circular(40)),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [_navItem(AppIcons.home, "Home", true, const Color(0xFF537E5D)), _navItem(AppIcons.progress_nav, "", false, primaryColor), _navItem(AppIcons.library, "", false, primaryColor), _navItem(AppIcons.profile, "", false, primaryColor)],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(height: 70, width: 70, decoration: const BoxDecoration(color: Color(0xFF537E5D), shape: BoxShape.circle), child: const Icon(Icons.add, color: Colors.white, size: 35)),
      ]),
    );
  }

  Widget _navItem(String iconPath, String label, bool isActive, Color activeColor) {
    return Row(children: [
      SvgPicture.asset(iconPath, height: 24, colorFilter: ColorFilter.mode(isActive ? activeColor : Colors.black45, BlendMode.srcIn)),
      if (isActive) Padding(padding: const EdgeInsets.only(left: 6), child: Text(label, style: TextStyle(color: activeColor, fontWeight: FontWeight.bold))),
    ]);
  }
}