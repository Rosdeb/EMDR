import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jonssony/services/app_url.dart';

class CalmPlaceService {
  static const String _baseUrl = '${AppUrl.baseUrl}/calm-place';

  static Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

  // ─── Save Calm Place ──────────────────────────────────────
  static Future<Map<String, dynamic>> saveCalmPlace(
      String token, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: _headers(token),
        body: jsonEncode(data),
      );
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final bool isSuccess =
          response.statusCode >= 200 && response.statusCode < 300;
      if (isSuccess) return {'success': true, 'data': body['data']};
      return {
        'success': false,
        'message': body['message'] ?? 'Failed to save calm place'
      };
    } catch (e) {
      print('CalmPlaceService saveCalmPlace Error: $e');
      return {
        'success': false,
        'message': 'Network error. Please try again.'
      };
    }
  }

  // ─── Get Calm Place ──────────────────────────────────────
  static Future<Map<String, dynamic>> getCalmPlace(String token) async {
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
        'message': body['message'] ?? 'Failed to load calm place'
      };
    } catch (e) {
      print('CalmPlaceService getCalmPlace Error: $e');
      return {
        'success': false,
        'message': 'Network error. Please try again.'
      };
    }
  }
}
