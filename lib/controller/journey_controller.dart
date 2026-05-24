import 'package:get/get.dart';
import 'package:jonssony/controller/auth_controller.dart';
import 'package:jonssony/services/journey_service.dart';

class JourneyController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // List of all journeys
  final RxList<dynamic> journeys = [].obs;

  @override
  void onInit() {
    super.onInit();
    if (_authController.isLoggedIn) {
      fetchAllJourneys();
    }
  }

  Future<void> fetchAllJourneys() async {
    final token = _authController.token;
    if (token == null) return;

    isLoading.value = true;
    errorMessage.value = '';
    try {
      final result = await JourneyService.getAllJourneys(token);
      if (result['success'] == true) {
        final dataList = result['data'] as List<dynamic>? ?? [];
        journeys.assignAll(dataList);
      } else {
        errorMessage.value = result['message'] ?? 'Failed to load journeys';
      }
    } catch (e) {
      print('Journey fetch error: $e');
      errorMessage.value = 'Network error. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<dynamic> getJourneyById(String journeyId) async {
    final token = _authController.token;
    if (token == null) return null;

    try {
      final result = await JourneyService.getJourneyById(token, journeyId);
      if (result['success'] == true) {
        return result['data'];
      }
    } catch (e) {
      print('Journey by ID fetch error: $e');
    }
    return null;
  }

  final RxBool isSaving = false.obs;

  Future<Map<String, dynamic>> createJourney({
    required String journeyName,
    required String description,
    required String imageUrl,
  }) async {
    final token = _authController.token;
    if (token == null) return {'success': false, 'message': 'Not authenticated'};

    isSaving.value = true;
    try {
      final result = await JourneyService.createJourney(token, {
        'journeyName': journeyName,
        'description': description,
        'imageUrl': imageUrl,
      });
      if (result['success'] == true) {
        // Refresh the list
        await fetchAllJourneys();
      }
      return result;
    } catch (e) {
      return {'success': false, 'message': 'Network error'};
    } finally {
      isSaving.value = false;
    }
  }

  Future<Map<String, dynamic>> updateJourney({
    required String journeyId,
    required String journeyName,
    required String description,
    required String imageUrl,
  }) async {
    final token = _authController.token;
    if (token == null) return {'success': false, 'message': 'Not authenticated'};

    isSaving.value = true;
    try {
      final result = await JourneyService.updateJourney(token, journeyId, {
        'journeyName': journeyName,
        'description': description,
        'imageUrl': imageUrl,
      });
      if (result['success'] == true) {
        await fetchAllJourneys();
      }
      return result;
    } catch (e) {
      return {'success': false, 'message': 'Network error'};
    } finally {
      isSaving.value = false;
    }
  }

  Future<Map<String, dynamic>> deleteJourney(String journeyId) async {
    final token = _authController.token;
    if (token == null) return {'success': false, 'message': 'Not authenticated'};

    isSaving.value = true;
    try {
      final result = await JourneyService.deleteJourney(token, journeyId);
      if (result['success'] == true) {
        await fetchAllJourneys();
      }
      return result;
    } catch (e) {
      return {'success': false, 'message': 'Network error'};
    } finally {
      isSaving.value = false;
    }
  }
}
