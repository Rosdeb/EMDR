import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jonssony/views/Library/ACalmPage.dart';
import 'package:jonssony/utils/app_text.dart';
import 'package:jonssony/controller/auth_controller.dart';
import 'package:jonssony/controller/journey_controller.dart';
import 'package:jonssony/services/calm_place_service.dart';

class MyCalmSpace extends StatefulWidget {
  const MyCalmSpace({super.key});

  @override
  State<MyCalmSpace> createState() => _MyCalmSpaceState();
}

class _MyCalmSpaceState extends State<MyCalmSpace> {
  bool _isLoading = true;
  List<dynamic> _calmPlaces = [];
  String _errorMessage = "";

  @override
  void initState() {
    super.initState();
    _fetchCalmPlaces();
  }

  Future<void> _fetchCalmPlaces() async {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    List<dynamic> loadedPlaces = [];

    try {
      final authController = Get.find<AuthController>();
      final token = authController.token;
      if (token != null) {
        final result = await CalmPlaceService.getCalmPlace(token);
        if (result['success'] == true && result['data'] != null) {
          final data = result['data'];
          if (data is List) {
            loadedPlaces = List.from(data);
          } else if (data is Map) {
            loadedPlaces = [data];
          }
        } else {
          _errorMessage = result['message'] ?? "Failed to load calm spaces.";
        }
      }
    } catch (e) {
      print("Error fetching calm spaces: $e");
      _errorMessage = "An error occurred while loading calm spaces.";
    }

    // Load from local storage and merge with server data to ensure
    // we show every single session 3 calm space saved across all journeys
    final box = GetStorage();
    final saved = box.read<bool>('calm_place_saved') ?? false;
    if (saved) {
      final rawList = box.read('calm_places_list');
      List<dynamic> localList = [];
      if (rawList is List && rawList.isNotEmpty) {
        localList = List.from(rawList);
      } else {
        // Fallback for older single-item local storage
        final description = box.read<String>('calm_place_description') ?? '';
        final audioName = box.read<String>('calm_place_audio_name') ?? '';
        final audioUrl = box.read<String>('calm_place_audio_url') ?? '';
        final imageUrl = box.read<String>('calm_place_image_url') ?? '';
        if (description.isNotEmpty || audioName.isNotEmpty || imageUrl.isNotEmpty) {
          localList = [
            {
              'description': description,
              'audioName': audioName,
              'audioUrl': audioUrl,
              'imageUrl': imageUrl,
            }
          ];
        }
      }

      loadedPlaces.addAll(localList);
    }

    // Deduplicate the combined list
    final List<dynamic> uniquePlaces = [];
    final Set<String> seenIdentifiers = {};
    for (final place in loadedPlaces) {
      final desc = place['description']?.toString() ?? '';
      final img = place['imageUrl']?.toString() ?? '';
      // Create a unique key based on description and imageUrl
      final key = '${desc}_$img';
      // We only skip if both desc and img are exactly identical and the key has been seen
      if (!seenIdentifiers.contains(key)) {
        seenIdentifiers.add(key);
        uniquePlaces.add(place);
      }
    }

    setState(() {
      _calmPlaces = uniquePlaces.reversed.toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    const double appBarImageHeight = 180;
    const double overlapAmount = 5;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: appBarImageHeight,
            child: Image.asset('assets/images/my_emdr.png', fit: BoxFit.fill),
          ),

          Column(
            children: [
              _buildCalmAppBar(context),

              Expanded(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      top: -overlapAmount,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(35),
                            topRight: Radius.circular(35),
                          ),
                          image: DecorationImage(
                            image: AssetImage('assets/images/home_bg1.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),

                    Positioned.fill(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 40),
                            _buildThoughtsCard(
                              child: _isLoading
                                  ? const Center(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(vertical: 30),
                                        child: CircularProgressIndicator(
                                          color: Color(0xFF5A7D63),
                                        ),
                                      ),
                                    )
                                  : _calmPlaces.isEmpty
                                      ? Center(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 30),
                                            child: AppText(
                                              _errorMessage.isNotEmpty
                                                  ? _errorMessage
                                                  : "No saved Calm Space found.",
                                              fontSize: 14,
                                              color: Colors.black54,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        )
                                      : Column(
                                          children: List.generate(
                                            _calmPlaces.length,
                                            (index) {
                                              final place = _calmPlaces[index];
                                              final dataMap = place is Map
                                                  ? Map<String, dynamic>.from(place)
                                                  : <String, dynamic>{};
                                              return _buildCalmSpaceItem(dataMap, index);
                                            },
                                          ),
                                        ),
                            ),

                            const SizedBox(height: 150),
                          ],
                        ),
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

  Widget _buildCalmAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        left: 10,
        right: 20,
        bottom: 10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF2E3E32)),
                onPressed: () => Navigator.pop(context),
              ),
              const AppText(
                "My Calm Space",
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E3E32),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThoughtsCard({Widget? child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.4),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 12,
                    backgroundImage: AssetImage('assets/images/emdr_sun.jpg'),
                  ),
                  const SizedBox(width: 8),
                  AppText(
                    "Saved Calm Spaces",
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black.withOpacity(0.7),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const AppText(
                "Access your personalized safe spaces designed during your EMDR therapeutic journey.",
                fontSize: 13,
                color: Colors.black54,
              ),
              if (child != null) ...[const SizedBox(height: 20), child],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalmSpaceItem(Map<String, dynamic> data, int index) {
    final description = data['description']?.toString() ?? '';
    final audioName = data['audioName']?.toString() ?? 'calm place.wav';
    final audioUrl = data['audioUrl']?.toString() ?? '';
    final imageUrl = data['imageUrl']?.toString() ?? '';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ACalmPage(
              mediaName: audioName,
              mediaUrl: audioUrl,
              description: description,
              imageUrl: imageUrl,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.35),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.5)),
                    ),
                    child: ClipOval(
                      child: _buildThumbImage(imageUrl),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          "Calm Space ${index + 1}",
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        AppText(
                          description.isNotEmpty ? description : "My safe place",
                          fontSize: 12,
                          color: Colors.black54,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.black54,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbImage(String path) {
    final imagePath = path.trim();
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            Image.asset('assets/images/emdr_sun.jpg', fit: BoxFit.cover),
      );
    }

    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            Image.asset('assets/images/emdr_sun.jpg', fit: BoxFit.cover),
      );
    }

    if (imagePath.isNotEmpty) {
      final file = File(imagePath);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              Image.asset('assets/images/emdr_sun.jpg', fit: BoxFit.cover),
        );
      }
    }

    return Image.asset('assets/images/emdr_sun.jpg', fit: BoxFit.cover);
  }
}
