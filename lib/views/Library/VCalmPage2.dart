import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jonssony/utils/app_colors.dart';
import 'package:jonssony/utils/app_text.dart';

class VCalmPage2 extends StatefulWidget {
  const VCalmPage2({super.key});

  @override
  State<VCalmPage2> createState() => _VCalmPage2State();
}

class _VCalmPage2State extends State<VCalmPage2> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  final box = GetStorage();
  final Set<int> _selectedIndices = {};

  @override
  void initState() {
    super.initState();
    _initializePlayer();
    _loadSavedData();
  }
  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }
  Future<void> _initializePlayer() async {
    _videoPlayerController = VideoPlayerController.asset('assets/video/Light_stream.mp4');
    await _videoPlayerController.initialize();
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: false,
      aspectRatio: _videoPlayerController.value.aspectRatio,
      materialProgressColors: ChewieProgressColors(
        playedColor:AppColors.mainAppColor,
        handleColor: AppColors.mainAppColor,
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
                          image: DecorationImage(image: AssetImage('assets/images/bg_library.jpg'), fit: BoxFit.cover),
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        const SizedBox(height: 30),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _buildVideoCard(),
                        ),
                      ],
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

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20, left: 10, bottom: 10),
      child: Row(children: [
        IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        const AppText("Light Stream", fontSize: 20, fontWeight: FontWeight.bold),
      ]),
    );
  }


}