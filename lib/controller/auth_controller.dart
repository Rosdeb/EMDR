import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jonssony/healper/route.dart';
import 'package:jonssony/services/auth_service.dart';
import 'package:jonssony/services/gogle_sign.dart';
import 'package:jonssony/services/notificationService.dart';

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
  static const _refreshTokenKey = 'auth_refresh_token';
  static const _userKey = 'auth_user';

  // ─── Token helpers ─────────────────────────────────────────
  String? get token => _box.read<String>(_tokenKey);
  String? get refreshToken => _box.read<String>(_refreshTokenKey);
  bool get isLoggedIn => token != null && token!.isNotEmpty;

  void _saveSession(Map<String, dynamic> data) {
    if (data['session'] != null && data['session']['accessToken'] != null) {
      _box.write(_tokenKey, data['session']['accessToken']);
    } else if (data['token'] != null) {
      _box.write(_tokenKey, data['token']);
    } else if (data['accessToken'] != null) {
      _box.write(_tokenKey, data['accessToken']);
    }

    if (data['session'] != null && data['session']['refreshToken'] != null) {
      _box.write(_refreshTokenKey, data['session']['refreshToken']);
    } else if (data['refreshToken'] != null) {
      _box.write(_refreshTokenKey, data['refreshToken']);
    }

    if (data['user'] != null) {
      _box.write(_userKey, data['user']);
    }
  }

  void _clearSession() {
    _box.remove(_tokenKey);
    _box.remove(_refreshTokenKey);
    _box.remove(_userKey);
    _box.remove('registered_fcm_token');
  }

  // ─── 1. Signup ─────────────────────────────────────────────
  Future<void> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String confirmPassword,
    required bool isAcceptPrivacyStatement,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final result = await AuthService.signup(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        isAcceptPrivacyStatement: isAcceptPrivacyStatement,
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
        Get.offAllNamed(RouteHelper.login);
        Get.snackbar('Success', 'Verification successful! Please login.');
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
        await NotificationService.registerCurrentDeviceToken();
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

  // ─── 4.1. Google Login ─────────────────────────────────────
  Future<void> signInWithGoogle() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final user = await GoogleSignInService.signInWithGoogle();
      if (user != null) {
        final userData = {
          'user': {
            'uid': user.uid,
            'email': user.email,
            'firstName': user.displayName?.split(' ').first ?? '',
            'lastName': user.displayName?.split(' ').last ?? '',
          },
          'token': await user.getIdToken(),
        };
        _saveSession(userData);
        await NotificationService.registerCurrentDeviceToken();
        Get.offAllNamed(RouteHelper.main);
      } else {
        errorMessage.value = 'Sign-in canceled or failed quietly.';
        _showError(errorMessage.value);
      }
    } catch (e, stack) {
      print("Google Sign In Error: $e\n$stack");
      errorMessage.value = 'Failed: ${e.toString().split('\n').first}';
      _showError(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  // ─── 5. Forgot Password (sends reset OTP to email) ───────
  Future<void> sendVerificationOtp({required String email}) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final result = await AuthService.forgotPassword(email: email);
      // DEBUG: Print full response to see what backend returns
      print('🔑 forgot-password response: $result');
      if (result['success'] == true) {
        pendingEmail.value = email;
        // Try multiple possible token key names from backend
        final accessToken = (result['accessToken'] ?? result['token'] ?? result['sessionToken'] ?? result['resetToken']) as String?;
        if (accessToken != null && accessToken.isNotEmpty) {
          _box.write(_tokenKey, accessToken);
          print('🔑 Token saved: $accessToken');
        } else {
          print('⚠️ No token in forgot-password response. Keys: ${result.keys.toList()}');
        }
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

  // ─── 5.1. Resend OTP on forgot password screen (no re-navigate) ───
  Future<void> resendForgotPasswordOtp() async {
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

  // ─── 6. Verify OTP for password reset ──────────────
  // Uses /api/auth/send-verification-otp with {email, otp}
  // Returns accessToken used for recover-account
  Future<void> verifyPasswordOtp({required String otp}) async {
    if (pendingEmail.isEmpty) {
      _showError('Email not found. Please try again.');
      return;
    }
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final result = await AuthService.sendVerificationOtp(
        email: pendingEmail.value,
        otp: otp,
      );
      if (result['success'] == true) {
        verifiedOtp.value = otp;
        // Save accessToken for recover-account Bearer header
        final accessToken = result['accessToken'] as String?;
        if (accessToken != null && accessToken.isNotEmpty) {
          _box.write(_tokenKey, accessToken);
        }
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
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (token == null) {
      _showError('Session expired. Please verify OTP again.');
      return;
    }
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final result = await AuthService.recoverAccount(
        token: token!,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      if (result['success'] == true) {
        pendingEmail.value = '';
        _clearSession();
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
      if (token != null && refreshToken != null) {
        await AuthService.logout(token: token!, refreshToken: refreshToken!);
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
      snackPosition: SnackPosition.TOP,
      // backgroundColor: Colors.red,
      // colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );
  }
}
