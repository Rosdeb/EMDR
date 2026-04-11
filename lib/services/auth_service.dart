import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jonssony/services/app_url.dart';

class AuthService {
  static const String _baseUrl = '${AppUrl.baseUrl}/auth';

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  static Map<String, String> _headersWithToken(String token) => {
        ..._headers,
        'Authorization': 'Bearer $token',
      };

  // ─── 1. Signup ─────────────────────────────────────────────
  // POST /api/auth/signup
  static Future<Map<String, dynamic>> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String confirmPassword,
    required bool isAcceptPrivacyStatement,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/signup'),
      headers: _headers,
      body: jsonEncode({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
        'isAcceptPrivacyStatement': isAcceptPrivacyStatement,
      }),
    );
    return _handleResponse(response);
  }

  // ─── 2. Verify OTP ─────────────────────────────────────────
  // POST /api/auth/verify-otp
  // Used for: Signup verification AND Forgot Password OTP verification
  // Body: {email, otp}
  // Returns: {success: true, data: {accessToken: "eyJ..."}}
  static Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/verify-otp'),
      headers: _headers,
      body: jsonEncode({'email': email, 'otp': otp}),
    );
    return _handleResponse(response);
  }

  // ─── 3. Resend OTP ─────────────────────────────────────────
  // POST /api/auth/resend-otp
  // Body: {email}
  static Future<Map<String, dynamic>> resendOtp({
    required String email,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/resend-otp'),
      headers: _headers,
      body: jsonEncode({'email': email}),
    );
    return _handleResponse(response);
  }

  // ─── 4. Login ──────────────────────────────────────────────
  // POST /api/auth/login
  // Body: {email, password}
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: _headers,
      body: jsonEncode({'email': email, 'password': password}),
    );
    return _handleResponse(response);
  }

  // ─── 5. Forgot Password ────────────────────────────────────
  // POST /api/auth/forgot-password
  // Body: {email} — sends OTP to email (no token returned)
  static Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/forgot-password'),
      headers: _headers,
      body: jsonEncode({'email': email}),
    );
    return _handleResponse(response);
  }

  // ─── 6. Send Verification OTP (Forgot Password Step 2) ───
  // POST /api/auth/send-verification-otp
  // Body: {email, otp}
  // Returns: {success: true, data: {accessToken: "eyJ..."}}
  static Future<Map<String, dynamic>> sendVerificationOtp({
    required String email,
    required String otp,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/send-verification-otp'),
      headers: _headers,
      body: jsonEncode({'email': email, 'otp': otp}),
    );
    return _handleResponse(response);
  }

  // ─── 7. Recover Account ────────────────────────────────────
  // POST /api/auth/recover-account
  // Body: {newPassword, confirmPassword}
  // Requires: Bearer token from send-verification-otp response
  static Future<Map<String, dynamic>> recoverAccount({
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/recover-account'),
      headers: _headersWithToken(token),
      body: jsonEncode({
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      }),
    );
    return _handleResponse(response);
  }

  // ─── 7. Verify Email With Token ────────────────────────────
  // POST /api/auth/verify-email-with-token
  // Body: {otp} — Requires: Bearer token
  // Used for: Email verification when user already has a session
  static Future<Map<String, dynamic>> verifyEmailWithToken({
    required String otp,
    required String token,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/verify-email-with-token'),
      headers: _headersWithToken(token),
      body: jsonEncode({'otp': otp}),
    );
    return _handleResponse(response);
  }

  // ─── 8. Logout ─────────────────────────────────────────────
  // POST /api/auth/logout
  // Body: {refreshToken}
  // Requires: Bearer token
  static Future<Map<String, dynamic>> logout({
    required String token,
    required String refreshToken,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/logout'),
      headers: _headersWithToken(token),
      body: jsonEncode({'refreshToken': refreshToken}),
    );
    return _handleResponse(response);
  }

  // ─── 9. Refresh Token ──────────────────────────────────────
  // POST /api/auth/refresh-token
  // Body: {refreshToken}
  // Returns: {success: true, data: {accessToken: "eyJ..."}}
  static Future<Map<String, dynamic>> refreshToken({
    required String refreshToken,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/refresh-token'),
      headers: _headers,
      body: jsonEncode({'refreshToken': refreshToken}),
    );
    return _handleResponse(response);
  }

  // ─── Response Handler ──────────────────────────────────────
  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final bool isSuccess =
          response.statusCode >= 200 && response.statusCode < 300;

      print('API Response (${response.statusCode}): ${response.body}');

      if (isSuccess) {
        if (body.containsKey('data')) {
          return {'success': true, ...body['data'] as Map<String, dynamic>};
        }
        return {'success': true, ...body};
      }

      String? errorMessage;
      if (body['message'] != null) {
        errorMessage = body['message'].toString();
      } else if (body['data'] is Map && body['data']['message'] != null) {
        errorMessage = body['data']['message'].toString();
      } else if (body['error'] != null) {
        errorMessage = body['error'].toString();
      } else if (body['errors'] != null) {
        errorMessage = body['errors'].toString();
      }

      return {
        'success': false,
        'message': errorMessage ?? 'Server error: ${response.statusCode}',
        ...body,
      };
    } catch (e) {
      print('Parsing Error: $e');
      return {
        'success': false,
        'message': 'Invalid server response',
      };
    }
  }
}
