import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:jonssony/services/app_url.dart';

class NotificationApiService {
  static const String _baseUrl = '${AppUrl.baseUrl}/notifications';

  static Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

  static Future<Map<String, dynamic>> registerFcmToken({
    required String token,
    required String fcmToken,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/token'),
      headers: _headers(token),
      body: jsonEncode({
        'fcmToken': fcmToken,
        'platform': _platformName(),
      }),
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> getMyNotifications({
    required String token,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await http.get(
      Uri.parse('$_baseUrl?page=$page&limit=$limit'),
      headers: _headers(token),
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> markAsRead({
    required String token,
    required String notificationId,
  }) async {
    final response = await http.patch(
      Uri.parse('$_baseUrl/$notificationId/read'),
      headers: _headers(token),
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> markAllAsRead({
    required String token,
  }) async {
    final response = await http.patch(
      Uri.parse('$_baseUrl/read-all'),
      headers: _headers(token),
    );
    return _handleResponse(response);
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      final body = decoded is Map<String, dynamic>
          ? decoded
          : <String, dynamic>{};
      final isSuccess = response.statusCode >= 200 && response.statusCode < 300;
      final status = body['status']?.toString().toLowerCase();

      if (kDebugMode) {
        debugPrint(
          'NotificationApiService ${response.request?.method} '
          '${response.request?.url} -> ${response.statusCode}',
        );
        debugPrint('NotificationApiService response: ${response.body}');
      }

      if (isSuccess && (status == null || status == 'success')) {
        return {'success': true, 'data': body['data']};
      }

      return {
        'success': false,
        'message': _errorMessage(body) ?? 'Server error: ${response.statusCode}',
        ...body,
      };
    } catch (e) {
      debugPrint('NotificationApiService parsing error: $e');
      return {'success': false, 'message': 'Invalid server response'};
    }
  }

  static String? _errorMessage(Map<String, dynamic> body) {
    final message = body['message'];
    if (message != null) return message.toString();

    final data = body['data'];
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }

    final error = body['error'];
    if (error is Map && error['message'] != null) {
      return error['message'].toString();
    }
    if (error != null) return error.toString();

    return null;
  }

  static String _platformName() {
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    if (Platform.isMacOS) return 'macos';
    if (Platform.isWindows) return 'windows';
    if (Platform.isLinux) return 'linux';
    return 'unknown';
  }
}
