import 'package:get/get.dart';
import 'package:jonssony/controller/auth_controller.dart';
import 'package:jonssony/services/media_service.dart';

class MediaController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Store all fetched media
  final RxList<dynamic> allMedia = [].obs;

  // Helper map to quickly get media by their category name
  final RxMap<String, List<dynamic>> mediaByCategory =
      <String, List<dynamic>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    if (_authController.isLoggedIn) {
      fetchAllMedia();
    }
  }

  Future<void> fetchAllMedia() async {
    final token = _authController.token;
    if (token == null) return;

    isLoading.value = true;
    errorMessage.value = '';
    try {
      final result = await MediaService.getAllMedia(token: token, limit: 100);
      if (result['success'] == true) {
        final data = result['data'] ?? {};
        final mediaList = data['media'] as List<dynamic>? ?? [];
        allMedia.value = mediaList;

        // Group by category name
        final Map<String, List<dynamic>> grouped = {};
        for (var media in mediaList) {
          if (media['categoryId'] != null) {
            final catName = media['categoryId']['categoryName']
                ?.toString()
                .trim();
            if (catName != null) {
              if (!grouped.containsKey(catName)) {
                grouped[catName] = [];
              }
              grouped[catName]!.add(media);
            }
          }
        }
        mediaByCategory.assignAll(grouped);
      } else {
        errorMessage.value = result['message'] ?? 'Failed to load media';
      }
    } catch (e) {
      print('Media fetch error: $e');
      errorMessage.value = 'Network error. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  // Get a specific media by type from a category (e.g., getting the first video for "EMDR Therapy Sessions")
  dynamic getFirstMedia(String categoryName, String mediaType) {
    final normalizedCategory = categoryName.trim().toLowerCase();
    final normalizedMediaType = mediaType.trim().toLowerCase();

    for (final entry in mediaByCategory.entries) {
      if (entry.key.trim().toLowerCase() != normalizedCategory) continue;

      for (final media in entry.value) {
        if (media is Map &&
            media['mediaType']?.toString().trim().toLowerCase() ==
                normalizedMediaType) {
          return media;
        }
      }
    }

    return null;
  }
}
