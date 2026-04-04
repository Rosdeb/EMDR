import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String _baseUrl = 'https://people-exception-cod-plug.trycloudflare.com/api/auth';

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  static Map<String, String> _headersWithToken(String token) => {
        ..._headers,
        'Authorization': 'Bearer $token',
      };

  // ─── 1. Signup ────────────────────────────────────────────
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

  // ─── 2. Verify OTP (signup verification) ─────────────────
  // POST /api/auth/verify-otp
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

  // ─── 3. Resend OTP ────────────────────────────────────────
  // POST /api/auth/resend-otp
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

  // ─── 4. Login ─────────────────────────────────────────────
  // POST /api/auth/login
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

  // ─── 5. Send Verification OTP (password recovery) ────────
  // POST /api/auth/send-verification-otp
  static Future<Map<String, dynamic>> sendVerificationOtp({
    required String email,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/send-verification-otp'),
      headers: _headers,
      body: jsonEncode({'email': email}),
    );
    return _handleResponse(response);
  }

  // ─── 5.1. Verify Reset OTP (Postman Step 6) ───────────────
  // POST /api/auth/send-verification-otp
  static Future<Map<String, dynamic>> verifyResetOtp({
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

  // ─── 6. Recover Account (reset password) ─────────────────
  // POST /api/auth/recover-account
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

  // ─── 7. Logout ────────────────────────────────────────────
  // POST /api/auth/logout
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

  // ─── Response handler ─────────────────────────────────────
  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final bool isSuccess =
          response.statusCode >= 200 && response.statusCode < 300;

      // Debugging: Print response for troubleshooting
      print('API Response (${response.statusCode}): ${response.body}');

      if (isSuccess) {
        if (body.containsKey('data')) {
          return {'success': true, ...body['data']};
        }
        return {'success': true, ...body};
      }

      // Improved error message extraction
      String? errorMessage;
      if (body['message'] != null) {
        errorMessage = body['message'].toString();
      } else if (body['data'] != null &&
          body['data'] is Map &&
          body['data']['message'] != null) {
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
