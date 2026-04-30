import 'package:get/get.dart';
import 'package:jonssony/controller/auth_controller.dart';
import 'package:jonssony/services/my_tests_service.dart';

class MyTestsController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxList categories = [].obs;
  final RxList items = [].obs;
  final RxList allItems = [].obs;
  final RxMap categoryStats = {}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
    fetchAllItems();
  }

  String? get _token => Get.find<AuthController>().token;

  Future<void> fetchCategories() async {
    if (_token == null) return;
    isLoading.value = true;
    final result = await MyTestsService.getCategories(_token!);
    if (result['success']) {
      categories.assignAll(result['data']['categories'] ?? []);
    }
    isLoading.value = false;
  }

  Future<void> fetchItemsByCategory(String categoryId) async {
    if (_token == null) return;
    isLoading.value = true;
    final result = await MyTestsService.getItemsByCategory(_token!, categoryId);
    if (result['success']) {
      items.assignAll(result['data']['items'] ?? []);
    }
    isLoading.value = false;
  }

  Future<void> fetchAllItems({int page = 1, int limit = 50}) async {
    if (_token == null) return;
    isLoading.value = true;
    final result = await MyTestsService.getAllItems(
      _token!,
      page: page,
      limit: limit,
    );
    if (result['success']) {
      allItems.assignAll(result['data']['items'] ?? []);
    }
    isLoading.value = false;
  }

  Future<void> fetchCategoryStats(String categoryId) async {
    if (_token == null) return;
    final result = await MyTestsService.getCategoryStats(_token!, categoryId);
    if (result['success']) {
      categoryStats[categoryId] = result['data'];
    }
  }

  Future<bool> createCategory(String name, String description) async {
    if (_token == null) return false;
    isLoading.value = true;
    final result = await MyTestsService.createCategory(
      _token!,
      name,
      description,
    );
    if (result['success']) {
      await fetchCategories();
    }
    isLoading.value = false;
    return result['success'];
  }

  Future<bool> deleteCategory(String id) async {
    if (_token == null) return false;
    isLoading.value = true;
    final result = await MyTestsService.deleteCategory(_token!, id);
    if (result['success']) {
      categories.removeWhere((c) => c['_id'] == id);
    }
    isLoading.value = false;
    return result['success'];
  }

  Future<bool> createItem(
    String categoryId,
    String name,
    String day,
    String desc,
  ) async {
    if (_token == null) return false;
    isLoading.value = true;
    final result = await MyTestsService.createItem(_token!, categoryId, {
      'itemName': name,
      'day': day,
      'description': desc,
      'isActive': true,
    });
    if (result['success']) {
      await fetchItemsByCategory(categoryId);
    }
    isLoading.value = false;
    return result['success'];
  }
}
