import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jonssony/views/sessions/session_two.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:jonssony/controller/media_controller.dart';
import 'package:jonssony/utils/app_colors.dart';
import 'package:jonssony/views/profile/subcription/assignment.dart';
import 'package:jonssony/views/progress/progress_page.dart';
import 'package:get_storage/get_storage.dart';


class SessionOne extends StatefulWidget {
  const SessionOne({super.key});

  @override
  State<SessionOne> createState() => _SessionOneState();
}

class _SessionOneState extends State<SessionOne> {
  final MediaController _mediaController = Get.find<MediaController>();
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  final box = GetStorage();

  final List<Map<String, dynamic>> _childhoodFeelings = [
    {"title": "I don't deserve love", "value": false},
    {"title": "I am a bad person", "value": false},
    {"title": "I am terrible", "value": false},
    {"title": "I am worthless/inadequate", "value": false},
    {"title": "I am shameful", "value": false},
    {"title": "I am not lovable", "value": false},
    {"title": "I am not good enough", "value": false},
  ];

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  Future<void> _initializePlayer() async {
    // Wait briefly if media is still loading
    if (_mediaController.isLoading.value) {
      await Future.delayed(const Duration(milliseconds: 500));
    }

    // Get video for Session 1 intro
    final videoObj = _mediaController.getFirstMedia('EMDR Therapy Sessions', 'video');
    
    if (videoObj != null && videoObj['url'] != null) {
      _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(videoObj['url']));
    } else {
      // Fallback
      _videoPlayerController = VideoPlayerController.asset('assets/video/spiral_technique.mp4');
    }

    try {
      await _videoPlayerController!.initialize();
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: false,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        materialProgressColors: ChewieProgressColors(
          playedColor: AppColors.mainAppColor,
          handleColor: AppColors.mainAppColor,
        ),
      );
      if (mounted) setState(() {});
    } catch (e) {
      print("Error initializing video: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          // ব্যাকগ্রাউন্ড ইমেজ (শেলফ এর ছবিটির জন্য)
          image: DecorationImage(
            image: AssetImage('assets/images/chatbot_bg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildCustomAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: _buildJourneyCard(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // কাস্টম অ্যাপ বার
  Widget _buildCustomAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Get.back(),
          ),
          const Text(
            "Session 1",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // মেইন হোয়াইট কার্ড
  Widget _buildJourneyCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          const BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ভিডিও সেকশন - API থেকে ভিডিও আসবে
          _buildVideoSection(),

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Your Journey Guide", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const Text("When I was little (Childhood)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(
                  "This may or may not be relevant to what you would like to work on so skip it if not.\n\nFloat back in time and see if you remember feeling this way (from your situation) as a child or any other time?",
                  style: TextStyle(fontSize: 14, color: Colors.black.withOpacity(0.7)),
                ),
                const SizedBox(height: 20),


                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF9F2),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.orange.withOpacity(0.1)),
                  ),
                  child: Column(
                    children: _childhoodFeelings.map((option) {
                      return CheckboxListTile(
                        title: Text(option['title'], style: const TextStyle(fontSize: 15)),
                        value: option['value'],
                        activeColor: const Color(0xFF537E5D),
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (bool? val) {
                          setState(() {
                            option['value'] = val;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 20),

                // Optional Questionnaires Link
                _buildQuestionnairesLink(),

                const SizedBox(height: 20),

                // বাটন সেকশন
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Save progress if needed and navigate to SessionTwo
                          Get.to(() => const SessionTwo());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF537E5D),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text("Save & Continue", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Get.to(() => const SessionTwo());
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text("Skip for now", style: TextStyle(color: Colors.black54)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoSection() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Container(
        height: 250,
        width: double.infinity,
        color: Colors.black,
        child: _chewieController != null
            ? Chewie(controller: _chewieController!)
            : const Center(
                child: CircularProgressIndicator(color: Color(0xFF537E5D)),
              ),
      ),
    );
  }

  Widget _buildQuestionnairesLink() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF537E5D).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Optional Questionnaires",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2E3E32)),
          ),
          const SizedBox(height: 5),
          const Text(
            "Track your progress weekly with specific questionnaires (PHQ, GAD, etc.). Results will be shown in your dashboard.",
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to Questionnaires/Assessment
              Get.to(() => const FullAssessmentFlow());
            },
            icon: const Icon(Icons.assignment_outlined, size: 18),
            label: const Text("Go to Questionnaires"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF537E5D),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              Get.to(() => const ProgressPage());
            },
            child: const Text(
              "View My Progress Dashboard",
              style: TextStyle(color: Color(0xFF537E5D), decoration: TextDecoration.underline),
            ),
          ),
        ],
      ),
    );
  }
}