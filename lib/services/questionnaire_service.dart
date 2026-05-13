import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:jonssony/services/app_url.dart';

class QuestionnaireService {
  static const String _baseUrl = '${AppUrl.baseUrl}/questionnaire';

  static Map<String, String> _headers(String token) => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };

  static Future<Map<String, dynamic>> submit({
    required String token,
    required String type,
    required List<num> answers,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/$type'),
        headers: _headers(token),
        body: jsonEncode({'answers': answers}),
      );
      return _handleResponse(response, 'Failed to submit questionnaire');
    } catch (_) {
      return {'success': false, 'message': 'Network error. Please try again.'};
    }
  }

  static Future<Map<String, dynamic>> getAll({
    required String token,
    required String type,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$type'),
        headers: _headers(token),
      );
      return _handleResponse(response, 'Failed to load questionnaire results');
    } catch (_) {
      return {'success': false, 'message': 'Network error. Please try again.'};
    }
  }

  static Map<String, dynamic> _handleResponse(
    http.Response response,
    String fallbackMessage,
  ) {
    try {
      final decoded = jsonDecode(response.body);
      final body = decoded is Map<String, dynamic>
          ? decoded
          : <String, dynamic>{};
      final isSuccess = response.statusCode >= 200 && response.statusCode < 300;

      if (isSuccess) {
        return {'success': true, 'data': body['data'], 'meta': body['meta']};
      }

      return {
        'success': false,
        'message':
            body['message']?.toString() ??
            '$fallbackMessage (${response.statusCode})',
      };
    } catch (_) {
      return {
        'success': false,
        'message': '$fallbackMessage (${response.statusCode})',
      };
    }
  }
}
