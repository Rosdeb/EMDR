import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jonssony/services/app_url.dart';

class SubscriptionService {
  static const String _baseUrl = '${AppUrl.baseUrl}/subscriptions';

  static Map<String, String> _headers(String? token) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  // 1. Get all active pricing plans
  static Future<Map<String, dynamic>> getPlans(String? token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/plans'),
      headers: _headers(token),
    );
    return _handleResponse(response);
  }

  // 2. Get my current subscription
  static Future<Map<String, dynamic>> getMySubscription(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/my'),
      headers: _headers(token),
    );
    return _handleResponse(response);
  }

  // 3. Subscribe to a plan (Standard/Premium)
  static Future<Map<String, dynamic>> subscribe(String token, String planId, {String? paymentId}) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/subscribe'),
      headers: _headers(token),
      body: jsonEncode({
        'planId': planId,
        if (paymentId != null) 'transactionId': paymentId, // Assuming backend uses transactionId
      }),
    );
    return _handleResponse(response);
  }

  // 4. Apply for Community Access (Free Plan)
  static Future<Map<String, dynamic>> applyForCommunityAccess(String token, String planId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/apply'),
      headers: _headers(token),
      body: jsonEncode({'planId': planId}),
    );
    return _handleResponse(response);
  }

  // Response handler
  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final bool isSuccess = response.statusCode >= 200 && response.statusCode < 300;

      print('Subscription API Response (${response.statusCode}): ${response.body}');

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
