import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jonssony/services/app_url.dart';

class CategoryService {
  static const String _baseUrl = '${AppUrl.baseUrl}/categories';

  static Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

  // ─── Get All Categories ──────────────────────────────────────
  static Future<Map<String, dynamic>> getCategories(String token) async {
    try {
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: _headers(token),
      );

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final bool isSuccess = response.statusCode >= 200 && response.statusCode < 300;

      if (isSuccess) {
        return {'success': true, 'data': body['data']};
      }

      return {
        'success': false,
        'message': body['message'] ?? 'Failed to load categories',
      };
    } catch (e) {
      print('CategoryService getCategories Error: $e');
      return {
        'success': false,
        'message': 'Network error. Please try again.',
      };
    }
  }
}
