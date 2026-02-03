import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:get_storage/get_storage.dart';
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
  final box = GetStorage();

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
    _loadSavedData();
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

  void _loadSavedData() {
    List<dynamic>? saved = box.read('selected_thoughts');
    if (saved != null) setState(() => _selectedIndices.addAll(saved.cast<int>()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // টপ সাইনবোবোর্ড ইমেজ
          Positioned(top: 0, left: 0, right: 0, height: 180,
            child: Image.asset('assets/images/my_emdr.png', fit: BoxFit.fill),
          ),
          Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: Stack(
                  children: [
                    // মেইন ল্যান্ডস্কেপ ব্যাকগ্রাউন্ড
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

                          // ১. ভিডিও কার্ড (আলাদা কন্টেইনার)
                          _buildVideoCard(),

                          const SizedBox(height: 20),

                          // ২. জার্নি গাইড কার্ড (আলাদা হোয়াইট কার্ড)
                          _buildJourneyGuideCard(),

                          const SizedBox(height: 150),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

        ],
      ),
    );
  }


  Widget _buildVideoCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: _chewieController != null
                  ? Chewie(controller: _chewieController!)
                  : const Center(child: CircularProgressIndicator(color: Color(0xFF537E5D))),
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildJourneyGuideCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Your Journey Guide", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Serif')),
          const SizedBox(height: 10),
          const Text("When I was little (Childhood)", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const Text(
            "This may or may not be relevant to what you would like to work on so skip it if not.",
            style: TextStyle(fontSize: 12, color: Colors.black45),
          ),
          const SizedBox(height: 15),
          const Text(
            "Float back in time and see if you remember feeling this way from your situation as a child or any other time?",
            style: TextStyle(fontSize: 13, color: Colors.black87),
          ),
          const SizedBox(height: 15),

          // চেকলিস্ট সেকশন
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFDF9F3),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0xFFE8E1D5).withOpacity(0.5)),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          // বাটন সেকশন
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    box.write('selected_thoughts', _selectedIndices.toList());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF537E5D),
                    minimumSize: const Size(0, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Save & Continue", style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Skip for now", style: TextStyle(color: Colors.black54)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20, left: 10, bottom: 10),
      child: Row(children: [
        IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        const Text("Session 1", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Serif')),
      ]),
    );
  }


}