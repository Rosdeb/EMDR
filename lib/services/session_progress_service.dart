import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:jonssony/services/app_url.dart';

class SessionProgressService {
  static const String _baseUrl = '${AppUrl.baseUrl}/session-progress';

  static Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

  static void _logResponse(String method, Uri url, http.Response response) {
    if (!kDebugMode) return;

    debugPrint(
      'SessionProgressService $method $url -> ${response.statusCode}',
    );
    debugPrint('SessionProgressService response: ${response.body}');
  }

  // ─── Get All Session Progress ──────────────────────────────────────
  static Future<Map<String, dynamic>> getAllProgress(String token) async {
    try {
      final url = Uri.parse(_baseUrl);
      final response = await http.get(
        url,
        headers: _headers(token),
      );
      _logResponse('GET', url, response);
      return _handleResponse(response, 'Failed to load session progress');
    } catch (e) {
      debugPrint('SessionProgressService getAllProgress Error: $e');
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
      final url = Uri.parse('$_baseUrl/update');
      final response = await http.post(
        url,
        headers: _headers(token),
        body: jsonEncode(data),
      );
      if (kDebugMode) {
        debugPrint('SessionProgressService POST body: ${jsonEncode(data)}');
      }
      _logResponse('POST', url, response);
      return _handleResponse(response, 'Failed to update session progress');
    } catch (e) {
      debugPrint('SessionProgressService updateProgress Error: $e');
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
      final url = Uri.parse('$_baseUrl/$id');
      final response = await http.get(
        url,
        headers: _headers(token),
      );
      _logResponse('GET', url, response);
      return _handleResponse(response, 'Failed to load session progress');
    } catch (e) {
      debugPrint('SessionProgressService getProgressById Error: $e');
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
