import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jonssony/controller/auth_controller.dart';
import 'package:jonssony/services/bilateral_service.dart';

class BilateralController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();

  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxString errorMessage = ''.obs;

  final RxList<dynamic> environments = [].obs;
  final RxList<dynamic> objects = [].obs;
  final RxList<dynamic> sounds = [].obs;
  
  final RxMap<String, dynamic> userSettings = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    if (_authController.isLoggedIn) {
      fetchConfig();
    }
  }

  Future<void> fetchConfig() async {
    final token = _authController.token;
    if (token == null) return;

    isLoading.value = true;
    errorMessage.value = '';
    try {
      final result = await BilateralService.getConfig(token);
      if (result['success'] == true) {
        final data = result['data'] ?? {};
        environments.value = data['environments'] ?? [];
        objects.value = data['objects'] ?? [];
        sounds.value = data['sounds'] ?? [];
        if (data['userSettings'] != null) {
          userSettings.value = data['userSettings'];
        }
      } else {
        errorMessage.value = result['message'] ?? 'Failed to load configuration';
      }
    } catch (e) {
      print('Bilateral fetch config error: $e');
      errorMessage.value = 'Network error. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> saveSettings({
    required String environmentUrl,
    required String iconUrl,
    required String soundUrl,
    required String speed,
    required String direction,
  }) async {
    final token = _authController.token;
    if (token == null) return false;

    isSaving.value = true;
    try {
      final result = await BilateralService.saveSettings(
        token: token,
        environmentUrl: environmentUrl,
        iconUrl: iconUrl,
        soundUrl: soundUrl,
        speed: speed,
        direction: direction,
      );

      if (result['success'] == true) {
        if (result['data'] != null) {
          userSettings.value = result['data'];
        }
        Get.snackbar(
          'Success', 
          'Settings saved successfully',
          backgroundColor: const Color(0xFF4F7957).withOpacity(0.7),
          colorText: Colors.white,
        );
        return true;
      } else {
        Get.snackbar(
          'Error', 
          result['message'] ?? 'Failed to save settings',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      print('Bilateral save settings error: $e');
      Get.snackbar(
        'Error', 
        'Network error. Please try again.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }
}
