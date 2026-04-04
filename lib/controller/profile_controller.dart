import 'dart:io';
import 'package:get/get.dart';
import 'package:jonssony/controller/auth_controller.dart';
import 'package:jonssony/services/profile_service.dart';

class ProfileController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();

  final RxBool isLoading = false.obs;
  final RxMap userProfile = {}.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    if (_authController.isLoggedIn) {
      fetchProfile();
    }
  }

  // 1. Get Profile
  Future<void> fetchProfile() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final token = _authController.token;
      if (token == null) return;

      final result = await ProfileService.getProfile(token);
      if (result['success'] == true) {
        userProfile.value = result['data'] ?? {};
      } else {
        errorMessage.value = result['message'] ?? 'Failed to fetch profile';
      }
    } catch (e) {
      errorMessage.value = 'Network error. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  // 2. Update Profile
  Future<bool> updateProfile({
    String? fullName,
    String? phoneNumber,
    File? profilePic,
  }) async {
    isLoading.value = true;
    try {
      final token = _authController.token;
      if (token == null) return false;

      final result = await ProfileService.updateProfile(
        token: token,
        fullName: fullName,
        phoneNumber: phoneNumber,
        profilePic: profilePic,
      );

      if (result['success'] == true) {
        // Update local profile data
        fetchProfile();
        Get.snackbar('Success', 'Profile updated successfully');
        return true;
      } else {
        Get.snackbar('Error', result['message'] ?? 'Update failed');
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Network error. Please try again.');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // 3. Delete Account
  Future<void> deleteAccount() async {
    isLoading.value = true;
    try {
      final token = _authController.token;
      if (token == null) return;

      final result = await ProfileService.deleteAccount(token);
      if (result['success'] == true) {
        _authController.logout(); // Reuse logout to clear session
        Get.snackbar('Success', 'Account deleted successfully');
      } else {
        Get.snackbar('Error', result['message'] ?? 'Failed to delete account');
      }
    } catch (e) {
      Get.snackbar('Error', 'Network error. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  // 4. Change Password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (newPassword != confirmPassword) {
      Get.snackbar('Error', 'Passwords do not match');
      return false;
    }

    isLoading.value = true;
    try {
      final token = _authController.token;
      if (token == null) return false;

      final result = await ProfileService.changePassword(
        token: token,
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      if (result['success'] == true) {
        Get.snackbar('Success', 'Password updated successfully');
        return true;
      } else {
        Get.snackbar('Error', result['message'] ?? 'Failed to update password');
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Network error. Please try again.');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
