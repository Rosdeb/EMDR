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
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final bool isSuccess =
          response.statusCode >= 200 && response.statusCode < 300;
      if (isSuccess) return {'success': true, 'data': body['data']};
      return {
        'success': false,
        'message': body['message'] ?? 'Failed to load session progress'
      };
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
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final bool isSuccess =
          response.statusCode >= 200 && response.statusCode < 300;
      if (isSuccess) return {'success': true, 'data': body['data']};
      return {
        'success': false,
        'message': body['message'] ?? 'Failed to update session progress'
      };
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
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final bool isSuccess =
          response.statusCode >= 200 && response.statusCode < 300;
      if (isSuccess) return {'success': true, 'data': body['data']};
      return {
        'success': false,
        'message': body['message'] ?? 'Failed to load session progress'
      };
    } catch (e) {
      print('SessionProgressService getProgressById Error: $e');
      return {
        'success': false,
        'message': 'Network error. Please try again.'
      };
    }
  }
}
