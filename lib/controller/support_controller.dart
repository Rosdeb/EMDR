import 'package:get/get.dart';
import 'package:jonssony/controller/auth_controller.dart';
import 'package:jonssony/services/support_service.dart';

class SupportController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();

  // Observable state
  final RxBool isSubmitting = false.obs;
  final RxBool isLoadingTickets = false.obs;
  final RxList userTickets = [].obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Automatically fetch tickets when the controller is initialized
    fetchMyTickets();
  }

  // 1. Submit Ticket
  Future<bool> submitTicket({
    required String category,
    required String message,
    required String priority,
  }) async {
    final token = _authController.token;
    if (token == null) {
      _showError('Session expired. Please log in again.');
      return false;
    }

    isSubmitting.value = true;
    errorMessage.value = '';
    try {
      final result = await SupportService.submitTicket(
        token: token,
        category: category,
        message: message,
        priority: priority,
      );

      if (result['success'] == true) {
        // Refresh the ticket list after successful submission
        fetchMyTickets();
        Get.snackbar('Success', 'Your support ticket has been submitted.');
        return true;
      } else {
        errorMessage.value = result['message'] ?? 'Failed to submit ticket';
        _showError(errorMessage.value);
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Network error. Please try again.';
      _showError(errorMessage.value);
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  // 2. Fetch My Tickets
  Future<void> fetchMyTickets() async {
    final token = _authController.token;
    if (token == null) return;

    isLoadingTickets.value = true;
    errorMessage.value = '';
    try {
      final result = await SupportService.getMyTickets(token);
      if (result['success'] == true) {
        userTickets.value = result['data'] ?? [];
      } else {
        // We don't necessarily show an error dialog for background fetch
        errorMessage.value = result['message'] ?? 'Failed to load tickets';
      }
    } catch (e) {
      errorMessage.value = 'Failed to load ticket history.';
    } finally {
      isLoadingTickets.value = false;
    }
  }

  // Helper
  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 4),
    );
  }
}
