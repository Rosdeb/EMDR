import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jonssony/services/app_url.dart';

class SupportService {
  static const String _baseUrl = '${AppUrl.baseUrl}/support/tickets';

  static Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

  // 1. Submit a support ticket/complaint
  // POST /api/support/tickets
  static Future<Map<String, dynamic>> submitTicket({
    required String token,
    required String category,
    required String message,
    required String priority,
  }) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: _headers(token),
      body: jsonEncode({
        'category': category,
        'message': message,
        'priority': priority,
      }),
    );
    return _handleResponse(response);
  }

  // 2. Get my support tickets
  // GET /api/support/tickets/my
  static Future<Map<String, dynamic>> getMyTickets(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/my'),
      headers: _headers(token),
    );
    return _handleResponse(response);
  }

  // 3. Get ticket details by ID
  // GET /api/support/tickets/{id}
  static Future<Map<String, dynamic>> getTicketDetails(String token, String id) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/$id'),
      headers: _headers(token),
    );
    return _handleResponse(response);
  }

  // Response handler (consistent with other services)
  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final bool isSuccess =
          response.statusCode >= 200 && response.statusCode < 300;

      print('Support API Response (${response.statusCode}): ${response.body}');

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
