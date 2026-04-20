import 'package:get/get.dart';
import 'package:jonssony/controller/auth_controller.dart';
import 'package:jonssony/services/category_service.dart';

class CategoryController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // List of all categories
  final RxList<dynamic> categories = [].obs;

  @override
  void onInit() {
    super.onInit();
    if (_authController.isLoggedIn) {
      fetchCategories();
    }
  }

  Future<void> fetchCategories() async {
    final token = _authController.token;
    if (token == null) return;

    isLoading.value = true;
    errorMessage.value = '';
    try {
      final result = await CategoryService.getCategories(token);
      if (result['success'] == true) {
        final dataList = result['data'] as List<dynamic>? ?? [];
        categories.assignAll(dataList);
      } else {
        errorMessage.value = result['message'] ?? 'Failed to load categories';
      }
    } catch (e) {
      print('Category fetch error: $e');
      errorMessage.value = 'Network error. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }
}
