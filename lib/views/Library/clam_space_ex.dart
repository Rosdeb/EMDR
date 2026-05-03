import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jonssony/controller/auth_controller.dart';
import 'package:jonssony/services/category_service.dart';
import 'package:jonssony/services/media_service.dart';
import 'package:jonssony/views/Library/ACalmPage.dart';
import 'package:jonssony/views/Library/VCalmPage1.dart';
import 'package:jonssony/views/Library/VCalmPage2.dart';

class MyCalmSpaceExercise extends StatefulWidget {
  const MyCalmSpaceExercise({super.key});

  @override
  State<MyCalmSpaceExercise> createState() => _MyCalmSpaceExerciseState();
}

class _MyCalmSpaceExerciseState extends State<MyCalmSpaceExercise> {
  static const _spiralCategorySlug = 'spiral-technique';
  static const _spiralCategoryName = 'spiral technique';
  static const _fallbackSpiralCategoryId = '69f93ebe5eb8013d325bab3b';

  final AuthController _authController = Get.find<AuthController>();

  bool _isLoading = true;
  String _errorMessage = '';
  List<_CalmExerciseMedia> _exerciseMedia = [];

  @override
  void initState() {
    super.initState();
    _loadExerciseMedia();
  }

  Future<void> _loadExerciseMedia() async {
    final token = _authController.token;
    if (token == null || token.isEmpty) {
      setState(() {
        _isLoading = false;
        _exerciseMedia = _fallbackItems;
        _errorMessage = 'Please sign in again to load latest media.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final categoryId = await _resolveSpiralCategoryId(token);
      final categoryResult = await MediaService.getMediaByCategoryId(
        token: token,
        categoryId: categoryId,
      );

      final items = <_CalmExerciseMedia>[];
      if (categoryResult['success'] == true) {
        items.addAll(_parseCategoryMedia(categoryResult['data']));
      } else {
        _errorMessage =
            categoryResult['message']?.toString() ?? 'Failed to load media.';
      }

      await _addCalmAudioFromAllMedia(token, items);
      final uniqueItems = _dedupeAndSort(items);

      setState(() {
        _exerciseMedia = uniqueItems.isNotEmpty ? uniqueItems : _fallbackItems;
        _isLoading = false;
        if (uniqueItems.isEmpty && _errorMessage.isEmpty) {
          _errorMessage = 'No media found from API. Showing local fallback.';
        }
      });
    } catch (e) {
      setState(() {
        _exerciseMedia = _fallbackItems;
        _isLoading = false;
        _errorMessage = 'Could not load latest media. Showing local fallback.';
      });
    }
  }

  Future<String> _resolveSpiralCategoryId(String token) async {
    try {
      final result = await CategoryService.getCategories(token);
      if (result['success'] != true) return _fallbackSpiralCategoryId;

      final category = _findSpiralCategory(result['data']);
      final id = category?['_id']?.toString() ?? category?['id']?.toString();
      return id != null && id.isNotEmpty ? id : _fallbackSpiralCategoryId;
    } catch (_) {
      return _fallbackSpiralCategoryId;
    }
  }

  Map<dynamic, dynamic>? _findSpiralCategory(dynamic data) {
    final categories = _extractList(data);
    for (final item in categories) {
      if (item is! Map) continue;
      final slug = item['slug']?.toString().trim().toLowerCase();
      final name =
          item['categoryName']?.toString().trim().toLowerCase() ??
          item['name']?.toString().trim().toLowerCase();
      if (slug == _spiralCategorySlug || name == _spiralCategoryName) {
        return item;
      }
    }

    if (data is Map) {
      final slug = data['slug']?.toString().trim().toLowerCase();
      final name =
          data['categoryName']?.toString().trim().toLowerCase() ??
          data['name']?.toString().trim().toLowerCase();
      if (slug == _spiralCategorySlug || name == _spiralCategoryName) {
        return data;
      }
    }

    return null;
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      for (final key in const ['categories', 'docs', 'items', 'results']) {
        final value = data[key];
        if (value is List) return value;
      }
    }
    return const [];
  }

  List<_CalmExerciseMedia> _parseCategoryMedia(dynamic data) {
    if (data is! Map) return const [];

    final media = data['media'];
    if (media is! Map) return const [];

    final items = <_CalmExerciseMedia>[];
    items.addAll(_mapMediaList(media['videos'], _CalmExerciseType.video));
    items.addAll(_mapMediaList(media['musics'], _CalmExerciseType.audio));
    items.addAll(_mapMediaList(media['others'], _CalmExerciseType.audio));
    return items;
  }

  List<_CalmExerciseMedia> _mapMediaList(
    dynamic mediaList,
    _CalmExerciseType fallbackType,
  ) {
    if (mediaList is! List) return const [];

    return mediaList
        .whereType<Map>()
        .map((item) {
          final mediaType = item['mediaType']?.toString().toLowerCase();
          final resolvedType = mediaType == 'audio'
              ? _CalmExerciseType.audio
              : mediaType == 'video'
              ? _CalmExerciseType.video
              : fallbackType;

          return _CalmExerciseMedia(
            id: item['_id']?.toString() ?? '',
            name:
                item['name']?.toString() ??
                item['originalName']?.toString() ??
                'Untitled media',
            url: item['url']?.toString() ?? '',
            type: resolvedType,
            createdAt: item['createdAt']?.toString() ?? '',
          );
        })
        .where((item) => item.url.isNotEmpty)
        .toList();
  }

  Future<void> _addCalmAudioFromAllMedia(
    String token,
    List<_CalmExerciseMedia> items,
  ) async {
    try {
      final result = await MediaService.getAllMedia(token: token, limit: 100);
      if (result['success'] != true || result['data'] is! Map) return;

      final allMedia = result['data']['media'];
      if (allMedia is! List) return;

      Map<dynamic, dynamic>? audio;
      for (final item in allMedia.whereType<Map>()) {
        final type = item['mediaType']?.toString().toLowerCase();
        final status = item['status']?.toString().toLowerCase() ?? 'active';
        final name = item['name']?.toString().toLowerCase() ?? '';
        final originalName =
            item['originalName']?.toString().toLowerCase() ?? '';
        final isCalmAudio =
            name.contains('calm') ||
            originalName.contains('calm place') ||
            originalName.contains('calm space');

        if (type == 'audio' && status == 'active' && isCalmAudio) {
          audio = item;
          break;
        }
      }

      if (audio != null) {
        items.addAll(_mapMediaList([audio], _CalmExerciseType.audio));
      }
    } catch (_) {
      // The main category media can still render without this optional audio.
    }
  }

  List<_CalmExerciseMedia> _dedupeAndSort(List<_CalmExerciseMedia> items) {
    final byNameAndType = <String, _CalmExerciseMedia>{};
    for (final item in items) {
      final key = '${item.name.trim().toLowerCase()}-${item.type.name}';
      byNameAndType.putIfAbsent(key, () => item);
    }

    final sorted = byNameAndType.values.toList();
    sorted.sort((a, b) {
      final priority = _sortPriority(a).compareTo(_sortPriority(b));
      if (priority != 0) return priority;
      return b.createdAt.compareTo(a.createdAt);
    });
    return sorted;
  }

  int _sortPriority(_CalmExerciseMedia item) {
    final name = item.name.toLowerCase();
    if (item.type == _CalmExerciseType.video && name.contains('spiral')) {
      return 0;
    }
    if (item.type == _CalmExerciseType.video && name.contains('light')) {
      return 1;
    }
    if (item.type == _CalmExerciseType.audio && name.contains('calm')) {
      return 2;
    }
    return item.type == _CalmExerciseType.video ? 3 : 4;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 180,
            child: Image.asset('assets/images/my_emdr.png', fit: BoxFit.fill),
          ),

          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.only(top: 100),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(35),
                  topRight: Radius.circular(35),
                ),
                image: DecorationImage(
                  image: AssetImage('assets/images/bg_library.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.only(top: 150),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(35),
                  topRight: Radius.circular(35),
                ),
              ),
            ),
          ),

          // 3. Main Content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAppBar(context),
                const SizedBox(height: 70),
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF537E5D),
                          ),
                        )
                      : RefreshIndicator(
                          color: const Color(0xFF537E5D),
                          onRefresh: _loadExerciseMedia,
                          child: ListView(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            children: [
                              if (_errorMessage.isNotEmpty)
                                _buildErrorMessage(_errorMessage),
                              ..._exerciseMedia.map(
                                (item) => _buildExerciseItem(
                                  icon: item.icon,
                                  title: item.displayName,
                                  type: item.typeLabel,
                                  onTap: () => _openExercise(item),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openExercise(_CalmExerciseMedia item) {
    if (item.type == _CalmExerciseType.audio) {
      Get.to(() => ACalmPage(mediaName: item.displayName, mediaUrl: item.url));
      return;
    }

    final name = item.name.toLowerCase();
    if (name.contains('light')) {
      Get.to(() => VCalmPage2(title: item.displayName, videoUrl: item.url));
    } else {
      Get.to(() => VCalmPage1(title: item.displayName, videoUrl: item.url));
    }
  }

  Widget _buildErrorMessage(String message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.72),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.35)),
        ),
        child: Text(
          message,
          style: TextStyle(color: Colors.black.withOpacity(0.62), fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF4A4A4A)),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            "Calm Place Exercise",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Color(0xFF4A4A4A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseItem({
    required IconData icon,
    required String title,
    required String type,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                // Image ke mutabiq light grey/greenish tint
                color: const Color(0xFFE6E7D9).withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  // Circular Icon Container
                  Container(
                    height: 48,
                    width: 48,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: Colors.black87, size: 26),
                  ),
                  const SizedBox(width: 16),
                  // Text Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF3E433E),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          type,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _CalmExerciseType { video, audio }

class _CalmExerciseMedia {
  const _CalmExerciseMedia({
    required this.id,
    required this.name,
    required this.url,
    required this.type,
    this.createdAt = '',
  });

  final String id;
  final String name;
  final String url;
  final _CalmExerciseType type;
  final String createdAt;

  String get displayName {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return typeLabel;
    return trimmed;
  }

  String get typeLabel => type == _CalmExerciseType.video ? 'Video' : 'Audio';

  IconData get icon => type == _CalmExerciseType.video
      ? Icons.play_arrow_rounded
      : Icons.music_note_rounded;
}

const _fallbackItems = [
  _CalmExerciseMedia(
    id: 'local-spiral',
    name: 'spiral_technique.mp4',
    url: 'assets/video/spiral_technique.mp4',
    type: _CalmExerciseType.video,
  ),
  _CalmExerciseMedia(
    id: 'local-lightstream',
    name: 'Light_stream.mp4',
    url: 'assets/video/Lightstream.mp4',
    type: _CalmExerciseType.video,
  ),
  _CalmExerciseMedia(
    id: 'local-calm-audio',
    name: 'Calm place.wav',
    url: 'assets/audio/calm place.wav',
    type: _CalmExerciseType.audio,
  ),
];
