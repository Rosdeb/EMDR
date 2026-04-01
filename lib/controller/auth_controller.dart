import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jonssony/healper/route.dart';
import 'package:jonssony/services/auth_service.dart';

class AuthController extends GetxController {
  final _box = GetStorage();

  // ─── Observable state ──────────────────────────────────────
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Shared email across OTP screens (set after signup / forget password)
  final RxString pendingEmail = ''.obs;
  // Shared verified OTP for the password reset screen
  final RxString verifiedOtp = ''.obs;

  // ─── Storage keys ──────────────────────────────────────────
  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';

  // ─── Token helpers ─────────────────────────────────────────
  String? get token => _box.read<String>(_tokenKey);
  bool get isLoggedIn => token != null && token!.isNotEmpty;

  void _saveSession(Map<String, dynamic> data) {
    if (data['token'] != null) {
      _box.write(_tokenKey, data['token']);
    }
    if (data['user'] != null) {
      _box.write(_userKey, data['user']);
    }
  }

  void _clearSession() {
    _box.remove(_tokenKey);
    _box.remove(_userKey);
  }

  // ─── 1. Signup ─────────────────────────────────────────────
  Future<void> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final result = await AuthService.signup(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
      );
      if (result['success'] == true) {
        pendingEmail.value = email;
        Get.toNamed(RouteHelper.singup_verification);
      } else {
        errorMessage.value = result['message'] ?? 'Signup failed';
        _showError(errorMessage.value);
      }
    } catch (e) {
      errorMessage.value = 'Network error. Please try again.';
      _showError(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  // ─── 2. Verify OTP (signup) ────────────────────────────────
  Future<void> verifySignupOtp({required String otp}) async {
    if (pendingEmail.isEmpty) {
      _showError('Email not found. Please sign up again.');
      return;
    }
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final result = await AuthService.verifyOtp(
        email: pendingEmail.value,
        otp: otp,
      );
      if (result['success'] == true) {
        _saveSession(result);
        Get.offAllNamed(RouteHelper.main);
      } else {
        errorMessage.value = result['message'] ?? 'Invalid OTP';
        _showError(errorMessage.value);
      }
    } catch (e) {
      errorMessage.value = 'Network error. Please try again.';
      _showError(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  // ─── 3. Resend OTP ─────────────────────────────────────────
  Future<void> resendOtp() async {
    if (pendingEmail.isEmpty) return;
    isLoading.value = true;
    try {
      final result = await AuthService.resendOtp(email: pendingEmail.value);
      if (result['success'] == true) {
        Get.snackbar('OTP Sent', 'A new code has been sent to your email.');
      } else {
        _showError(result['message'] ?? 'Failed to resend OTP');
      }
    } catch (e) {
      _showError('Network error. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  // ─── 4. Login ──────────────────────────────────────────────
  Future<void> login({
    required String email,
    required String password,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final result = await AuthService.login(email: email, password: password);
      if (result['success'] == true) {
        _saveSession(result);
        Get.offAllNamed(RouteHelper.main);
      } else {
        errorMessage.value = result['message'] ?? 'Login failed';
        _showError(errorMessage.value);
      }
    } catch (e) {
      errorMessage.value = 'Network error. Please try again.';
      _showError(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  // ─── 5. Send verification OTP (forgot password) ────────────
  Future<void> sendVerificationOtp({required String email}) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final result = await AuthService.sendVerificationOtp(email: email);
      if (result['success'] == true) {
        pendingEmail.value = email;
        Get.toNamed(RouteHelper.verify);
      } else {
        errorMessage.value = result['message'] ?? 'Failed to send OTP';
        _showError(errorMessage.value);
      }
    } catch (e) {
      errorMessage.value = 'Network error. Please try again.';
      _showError(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  // ─── 6. Verify OTP for password reset ──────────────────────
  Future<void> verifyPasswordOtp({required String otp}) async {
    if (pendingEmail.isEmpty) {
      _showError('Email not found. Please try again.');
      return;
    }
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final result = await AuthService.verifyOtp(
        email: pendingEmail.value,
        otp: otp,
      );
      if (result['success'] == true) {
        verifiedOtp.value = otp;
        Get.toNamed(RouteHelper.changePassword);
      } else {
        errorMessage.value = result['message'] ?? 'Invalid OTP';
        _showError(errorMessage.value);
      }
    } catch (e) {
      errorMessage.value = 'Network error. Please try again.';
      _showError(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  // ─── 7. Recover account (reset password) ───────────────────
  Future<void> recoverAccount({
    required String otp,
    required String newPassword,
  }) async {
    if (pendingEmail.isEmpty) {
      _showError('Session expired. Please try again.');
      return;
    }
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final result = await AuthService.recoverAccount(
        email: pendingEmail.value,
        otp: otp,
        newPassword: newPassword,
      );
      if (result['success'] == true) {
        pendingEmail.value = '';
        Get.offAllNamed(RouteHelper.login);
        Get.snackbar('Success', 'Password updated! Please sign in.');
      } else {
        errorMessage.value = result['message'] ?? 'Failed to reset password';
        _showError(errorMessage.value);
      }
    } catch (e) {
      errorMessage.value = 'Network error. Please try again.';
      _showError(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  // ─── 8. Logout ─────────────────────────────────────────────
  Future<void> logout() async {
    isLoading.value = true;
    try {
      if (token != null) {
        await AuthService.logout(token: token!);
      }
    } catch (_) {
      // Ignore logout API errors — still clear session locally
    } finally {
      _clearSession();
      isLoading.value = false;
      Get.offAllNamed(RouteHelper.login);
    }
  }

  // ─── Helpers ───────────────────────────────────────────────
  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }
}
