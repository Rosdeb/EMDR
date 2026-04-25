import 'package:get/get.dart';
import 'package:jonssony/services/session_progress_service.dart';
import 'package:jonssony/controller/auth_controller.dart';
import 'package:jonssony/controller/profile_controller.dart';

class SessionProgressController extends GetxController {
  final RxBool isLoading = true.obs;
  final RxList<dynamic> progresses = [].obs;

  @override
  void onInit() {
    super.onInit();
    fetchProgresses();
  }

  Future<void> fetchProgresses() async {
    try {
      isLoading.value = true;
      final authController = Get.find<AuthController>();
      final token = authController.token;
      
      if (token == null) {
        isLoading.value = false;
        return;
      }

      // Try to get user ID from ProfileController, or use a default test ID
      String id = '60d0fe4f5311236168a109ca'; // Default from user request
      try {
        final profileController = Get.find<ProfileController>();
        if (profileController.userProfile.isNotEmpty) {
           id = profileController.userProfile['_id'] ?? profileController.userProfile['id'] ?? id;
        }
      } catch (e) {
        // Ignore if ProfileController is not found or empty
      }

      final result = await SessionProgressService.getProgressById(token, id);
      if (result['success'] == true) {
        final data = result['data'];
        if (data is List) {
          progresses.value = data;
        } else if (data != null) {
          progresses.value = [data];
        } else {
          Get.snackbar('Debug', 'Progress data is null');
        }
      } else {
        Get.snackbar('API Error', result['message'] ?? 'Failed to load progress');
        print("Failed to fetch progresses: ${result['message']}");
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
      print("Error fetching progresses: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
