// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:audioplayers/audioplayers.dart';
//
// class BilateralSimulationPage extends StatefulWidget {
//   final String environmentImage;
//   final String visualObject;
//   final double initialSpeed; // Seconds
//   final String audioAsset;
//
//   const BilateralSimulationPage({
//     super.key,
//     required this.environmentImage,
//     required this.visualObject,
//     required this.initialSpeed,
//     required this.audioAsset,
//   });
//
//   @override
//   State<BilateralSimulationPage> createState() => _BilateralSimulationPageState();
// }
//
// class _BilateralSimulationPageState extends State<BilateralSimulationPage>
//     with SingleTickerProviderStateMixin {
//
//   late AnimationController _controller;
//   late Animation<double> _animation;
//   final AudioPlayer _audioPlayer = AudioPlayer();
//
//   double _currentSpeed = 2.0; // Default speed
//   bool _isInitialized = false;
//   bool _isPlaying = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _currentSpeed = widget.initialSpeed > 0 ? widget.initialSpeed : 2.0;
//
//     _initAnimation();
//     _initAudio();
//   }
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     // Precache images to prevent flickering
//     if (widget.environmentImage.isNotEmpty) {
//       precacheImage(AssetImage(widget.environmentImage), context);
//     }
//     if (widget.visualObject.isNotEmpty) {
//       precacheImage(AssetImage(widget.visualObject), context);
//     }
//   }
//
//   void _initAnimation() {
//     _controller = AnimationController(
//       duration: Duration(milliseconds: (_currentSpeed * 1000).toInt()),
//       vsync: this,
//     );
//
//     _animation = Tween<double>(begin: -1.0, end: 1.0).animate(
//       CurvedAnimation(parent: _controller, curve: Curves.easeInOut), // Smoother movement
//     );
//
//     _controller.repeat(reverse: true);
//
//     // Audio Panning Link
//     _controller.addListener(() {
//       if (mounted && _isPlaying) {
//         // -1.0 (Left) se 1.0 (Right) tak sound shift hogi object ke saath
//         _audioPlayer.setBalance(_animation.value);
//       }
//     });
//   }
//
//   Future<void> _initAudio() async {
//     try {
//       // Remove 'assets/' prefix if present, as AssetSource adds it automatically
//       String assetPath = widget.audioAsset;
//       if (assetPath.startsWith('assets/')) {
//         assetPath = assetPath.substring(7);
//       }
//
//       await _audioPlayer.setSource(AssetSource(assetPath));
//       await _audioPlayer.setReleaseMode(ReleaseMode.loop);
//       await _audioPlayer.resume();
//
//       setState(() {
//         _isInitialized = true;
//         _isPlaying = true;
//       });
//     } catch (e) {
//       debugPrint("Audio Error: $e");
//     }
//   }
//
//   void _updateSpeed(double newSpeed) {
//     setState(() {
//       _currentSpeed = newSpeed;
//       _controller.duration = Duration(milliseconds: (newSpeed * 1000).toInt());
//       if (_controller.isAnimating) {
//         _controller.repeat(reverse: true);
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     _audioPlayer.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: AnnotatedRegion<SystemUiOverlayStyle>(
//         value: SystemUiOverlayStyle.light,
//         child: Stack(
//           children: [
//             // 1. Background
//             Positioned.fill(
//               child: widget.environmentImage.isNotEmpty
//                 ? Image.asset(
//                     widget.environmentImage,
//                     fit: BoxFit.cover,
//                     errorBuilder: (context, error, stackTrace) =>
//                         Container(color: Colors.black45),
//                   )
//                 : Container(color: Colors.black45),
//             ),
//
//             // 2. Bilateral Moving Object
//             AnimatedBuilder(
//               animation: _animation,
//               builder: (context, child) {
//                 return Align(
//                   alignment: Alignment(_animation.value, 0.0), // Center height
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 40),
//                     child: widget.visualObject.isNotEmpty
//                       ? Image.asset(
//                           widget.visualObject,
//                           width: 70,
//                           height: 70,
//                         )
//                       : Container(
//                           width: 70,
//                           height: 70,
//                           decoration: const BoxDecoration(
//                             color: Colors.white,
//                             shape: BoxShape.circle
//                           ),
//                         ),
//                   ),
//                 );
//               },
//             ),
//
//             // 3. UI Controls (Top & Bottom)
//             _buildTopOverlay(),
//             _buildBottomControls(),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTopOverlay() {
//     return SafeArea(
//       child: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             IconButton(
//               icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
//               onPressed: () => Navigator.pop(context),
//             ),
//             const Text(
//               "Deep Relaxation",
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 20,
//                 letterSpacing: 1.2,
//                 fontWeight: FontWeight.w300,
//               ),
//             ),
//             const SizedBox(width: 48), // Balance for back button
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildBottomControls() {
//     return Positioned(
//       bottom: 40,
//       left: 20,
//       right: 20,
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(20),
//         child: BackdropFilter(
//           filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
//           child: Container(
//             padding: const EdgeInsets.all(20),
//             color: Colors.white.withOpacity(0.1),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Row(
//                   children: [
//                     IconButton(
//                       icon: Icon(
//                         _isPlaying ? Icons.pause_circle : Icons.play_circle,
//                         color: Colors.white,
//                         size: 40,
//                       ),
//                       onPressed: () {
//                         setState(() {
//                           if (_isPlaying) {
//                             _controller.stop();
//                             _audioPlayer.pause();
//                             _isPlaying = false;
//                           } else {
//                             _controller.repeat(reverse: true);
//                             _audioPlayer.resume();
//                             _isPlaying = true;
//                           }
//                         });
//                       },
//                     ),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(" Speed Control",
//                               style: TextStyle(color: Colors.white70, fontSize: 12)),
//                           Slider(
//                             value: _currentSpeed,
//                             min: 0.5,
//                             max: 5.0,
//                             activeColor: Colors.white,
//                             inactiveColor: Colors.white24,
//                             onChanged: (val) => _updateSpeed(val),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }