import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jonssony/services/app_url.dart';

class SessionProgressService {
  static const String _baseUrl = '${AppUrl.baseUrl}/session-progress';

  static Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

  // ─── Get All Session Progress ──────────────────────────────────────
  static Future<Map<String, dynamic>> getAllProgress(String token) async {
    try {
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: _headers(token),
      );
      return _handleResponse(response, 'Failed to load session progress');
    } catch (e) {
      print('SessionProgressService getAllProgress Error: $e');
      return {
        'success': false,
        'message': 'Network error. Please try again.'
      };
    }
  }

  // ─── Update Session Progress ──────────────────────────────────────
  static Future<Map<String, dynamic>> updateProgress(
      String token, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/update'),
        headers: _headers(token),
        body: jsonEncode(data),
      );
      return _handleResponse(response, 'Failed to update session progress');
    } catch (e) {
      print('SessionProgressService updateProgress Error: $e');
      return {
        'success': false,
        'message': 'Network error. Please try again.'
      };
    }
  }

  // ─── Get Session Progress By ID ───────────────────────────────────
  static Future<Map<String, dynamic>> getProgressById(
      String token, String id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$id'),
        headers: _headers(token),
      );
      return _handleResponse(response, 'Failed to load session progress');
    } catch (e) {
      print('SessionProgressService getProgressById Error: $e');
      return {
        'success': false,
        'message': 'Network error. Please try again.'
      };
    }
  }

  static Map<String, dynamic> _handleResponse(
    http.Response response,
    String fallbackMessage,
  ) {
    try {
      final decoded = jsonDecode(response.body);
      final body = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
      final bool isSuccess =
          response.statusCode >= 200 && response.statusCode < 300;

      if (isSuccess) {
        return {'success': true, 'data': body['data']};
      }

      return {
        'success': false,
        'message': _errorMessage(body) ?? '$fallbackMessage (${response.statusCode})',
      };
    } catch (e) {
      return {
        'success': false,
        'message': '$fallbackMessage (${response.statusCode})',
      };
    }
  }

  static String? _errorMessage(Map<String, dynamic> body) {
    final message = body['message'];
    if (message != null) return message.toString();

    final error = body['error'];
    if (error is Map && error['message'] != null) {
      return error['message'].toString();
    }
    if (error != null) return error.toString();

    return null;
  }
}
