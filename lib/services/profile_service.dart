import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:io';

class ProfileService {
  static const String _baseUrl = 'https://people-exception-cod-plug.trycloudflare.com/api/profile';

  static Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

  // 1. Get Profile
  static Future<Map<String, dynamic>> getProfile(String token) async {
    final response = await http.get(
      Uri.parse(_baseUrl),
      headers: _headers(token),
    );
    return _handleResponse(response);
  }

  // 2. Update Profile
  static Future<Map<String, dynamic>> updateProfile({
    required String token,
    String? fullName,
    String? phoneNumber,
    File? profilePic,
  }) async {
    final uri = Uri.parse(_baseUrl);
    final request = http.MultipartRequest('PATCH', uri);
    
    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    if (fullName != null) request.fields['fullName'] = fullName;
    if (phoneNumber != null) request.fields['phoneNumber'] = phoneNumber;
    
    if (profilePic != null) {
      final ext = profilePic.path.split('.').last.toLowerCase();
      String mimeType = 'image/jpeg'; // default
      if (ext == 'png') {
        mimeType = 'image/png';
      } else if (ext == 'webp') {
        mimeType = 'image/webp';
      }

      request.files.add(await http.MultipartFile.fromPath(
        'profilePic',
        profilePic.path,
        contentType: MediaType.parse(mimeType),
      ));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return _handleResponse(response);
  }

  // 3. Delete Account
  static Future<Map<String, dynamic>> deleteAccount(String token) async {
    final response = await http.delete(
      Uri.parse(_baseUrl),
      headers: _headers(token),
    );
    return _handleResponse(response);
  }

  // 4. Change Password
  static Future<Map<String, dynamic>> changePassword({
    required String token,
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final response = await http.patch(
      Uri.parse('$_baseUrl/change-password'),
      headers: _headers(token),
      body: jsonEncode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      }),
    );
    return _handleResponse(response);
  }

  // Response handler (copied from AuthService logic)
  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final bool isSuccess =
          response.statusCode >= 200 && response.statusCode < 300;

      print('Profile API Response (${response.statusCode}): ${response.body}');

      if (isSuccess) {
        return {'success': true, ...body};
      }

      String? errorMessage;
      if (body['message'] != null) {
        errorMessage = body['message'].toString();
      } else if (body['error'] != null && body['error'] is Map) {
        errorMessage = body['error']['message']?.toString();
      } else if (body['error'] != null) {
        errorMessage = body['error'].toString();
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
