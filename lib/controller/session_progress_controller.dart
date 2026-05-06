import 'package:get/get.dart';
import 'package:jonssony/services/session_progress_service.dart';
import 'package:jonssony/controller/auth_controller.dart';

class SessionProgressController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isJourneyProgressLoading = false.obs;
  final RxList<dynamic> progresses = [].obs;
  final RxMap<String, Map<String, dynamic>> journeyProgresses =
      <String, Map<String, dynamic>>{}.obs;
  final Set<String> _requestedJourneyProgressIds = {};

  Future<void> fetchProgresses() async {
    try {
      isLoading.value = true;
      final authController = Get.find<AuthController>();
      final token = authController.token;
      
      if (token == null) {
        isLoading.value = false;
        return;
      }

      final result = await SessionProgressService.getAllProgress(token);
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

  Future<void> fetchProgressForJourneys(List<dynamic> journeys) async {
    final authController = Get.find<AuthController>();
    final token = authController.token;
    if (token == null || journeys.isEmpty) return;

    final journeyIds = journeys
        .map((journey) => journey is Map ? journey['_id']?.toString() ?? '' : '')
        .where((id) => id.isNotEmpty)
        .toList();

    final missingIds = journeyIds
        .where((id) =>
            !journeyProgresses.containsKey(id) &&
            !_requestedJourneyProgressIds.contains(id))
        .toList();
    if (missingIds.isEmpty) return;

    _requestedJourneyProgressIds.addAll(missingIds);
    isJourneyProgressLoading.value = true;
    try {
      for (final journeyId in missingIds) {
        final result =
            await SessionProgressService.getProgressById(token, journeyId);
        if (result['success'] == true && result['data'] is Map) {
          journeyProgresses[journeyId] =
              Map<String, dynamic>.from(result['data'] as Map);
        }
      }
    } catch (e) {
      print("Error fetching journey progress: $e");
    } finally {
      isJourneyProgressLoading.value = false;
    }
  }
}
