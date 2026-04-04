import 'dart:convert';
import 'package:http/http.dart' as http;

class StaticContentService {
  static const String _baseUrl = 'https://people-exception-cod-plug.trycloudflare.com/api';

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // 1. Get Privacy Policy
  static Future<Map<String, dynamic>> getPrivacyPolicy() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/privacy'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  // 2. Get Terms of Service
  static Future<Map<String, dynamic>> getTermsOfService() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/terms'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  // 3. Get FAQs
  static Future<Map<String, dynamic>> getFaqs() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/faq'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  // Response handler (copied from AuthService logic)
  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final bool isSuccess =
          response.statusCode >= 200 && response.statusCode < 300;

      print('Static API Response (${response.statusCode}): ${response.body}');

      if (isSuccess) {
        return {'success': true, ...body};
      }

      String? errorMessage;
      if (body['message'] != null) {
        errorMessage = body['message'].toString();
      } else if (body['error'] != null && body['error'] is Map) {
        errorMessage = body['error']['message']?.toString();
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
