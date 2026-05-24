import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:jonssony/services/app_url.dart';

class SymptomTrackerService {
  static const String _baseUrl = '${AppUrl.baseUrl}/symptom-tracker';

  static Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

  static Future<Map<String, dynamic>> getConfigs(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/configs'),
        headers: _headers(token),
      );
      return _handleResponse(response, 'Failed to load trackers');
    } catch (e) {
      return {'success': false, 'message': 'Network error. Please try again.'};
    }
  }

  static Future<Map<String, dynamic>> getConfig(
    String token,
    String trackerType,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/configs/$trackerType'),
        headers: _headers(token),
      );
      return _handleResponse(response, 'Failed to load tracker');
    } catch (e) {
      return {'success': false, 'message': 'Network error. Please try again.'};
    }
  }

  static Future<Map<String, dynamic>> submit({
    required String token,
    required String trackerType,
    required List<int> answers,
    String? stemValue,
  }) async {
    try {
      final body = <String, dynamic>{
        'trackerType': trackerType,
        'answers': answers,
      };
      if (stemValue != null && stemValue.trim().isNotEmpty) {
        body['stemValue'] = stemValue.trim();
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/submit'),
        headers: _headers(token),
        body: jsonEncode(body),
      );
      return _handleResponse(response, 'Failed to submit tracker');
    } catch (e) {
      return {'success': false, 'message': 'Network error. Please try again.'};
    }
  }

  static Future<Map<String, dynamic>> getHistory(
    String token, {
    String? trackerType,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final params = {
        if (trackerType != null && trackerType.isNotEmpty)
          'trackerType': trackerType,
        'page': page.toString(),
        'limit': limit.toString(),
      };
      final uri = Uri.parse('$_baseUrl/history').replace(
        queryParameters: params,
      );
      final response = await http.get(uri, headers: _headers(token));
      return _handleResponse(response, 'Failed to load tracker history');
    } catch (e) {
      return {'success': false, 'message': 'Network error. Please try again.'};
    }
  }

  static Future<Map<String, dynamic>> getSubmission(
    String token,
    String submissionId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/history/$submissionId'),
        headers: _headers(token),
      );
      return _handleResponse(response, 'Failed to load tracker result');
    } catch (e) {
      return {'success': false, 'message': 'Network error. Please try again.'};
    }
  }

  static Future<Map<String, dynamic>> getTrend(
    String token, {
    required String trackerType,
    int limit = 10,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/trend').replace(
        queryParameters: {
          'trackerType': trackerType,
          'limit': limit.toString(),
        },
      );
      final response = await http.get(uri, headers: _headers(token));
      return _handleResponse(response, 'Failed to load tracker trend');
    } catch (e) {
      return {'success': false, 'message': 'Network error. Please try again.'};
    }
  }

  static Future<Map<String, dynamic>> getLatest(
    String token, {
    String? trackerType,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/latest').replace(
        queryParameters: trackerType != null && trackerType.isNotEmpty
            ? {'trackerType': trackerType}
            : null,
      );
      final response = await http.get(uri, headers: _headers(token));
      return _handleResponse(response, 'Failed to load latest tracker result');
    } catch (e) {
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
