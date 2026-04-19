import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jonssony/services/app_url.dart';

class JourneyService {
  static const String _baseUrl = '${AppUrl.baseUrl}/journeys';

  static Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

  // ─── Get All Journeys ──────────────────────────────────────
  static Future<Map<String, dynamic>> getAllJourneys(String token) async {
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
        'message': body['message'] ?? 'Failed to load journeys',
      };
    } catch (e) {
      print('JourneyService getAllJourneys Error: $e');
      return {
        'success': false,
        'message': 'Network error. Please try again.',
      };
    }
  }

  // ─── Get Journey By ID ──────────────────────────────────────
  static Future<Map<String, dynamic>> getJourneyById(String token, String journeyId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$journeyId'),
        headers: _headers(token),
      );

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final bool isSuccess = response.statusCode >= 200 && response.statusCode < 300;

      if (isSuccess) {
        return {'success': true, 'data': body['data']};
      }

      return {
        'success': false,
        'message': body['message'] ?? 'Failed to load journey details',
      };
    } catch (e) {
      print('JourneyService getJourneyById Error: $e');
      return {
        'success': false,
        'message': 'Network error. Please try again.',
      };
    }
  }

  // ─── Create Journey ──────────────────────────────────────
  static Future<Map<String, dynamic>> createJourney(
      String token, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: _headers(token),
        body: jsonEncode(data),
      );
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final bool isSuccess = response.statusCode >= 200 && response.statusCode < 300;
      if (isSuccess) return {'success': true, 'data': body['data']};
      return {'success': false, 'message': body['message'] ?? 'Failed to create journey'};
    } catch (e) {
      print('JourneyService createJourney Error: $e');
      return {'success': false, 'message': 'Network error. Please try again.'};
    }
  }

  // ─── Update Journey ──────────────────────────────────────
  static Future<Map<String, dynamic>> updateJourney(
      String token, String journeyId, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/$journeyId'),
        headers: _headers(token),
        body: jsonEncode(data),
      );
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final bool isSuccess = response.statusCode >= 200 && response.statusCode < 300;
      if (isSuccess) return {'success': true, 'data': body['data']};
      return {'success': false, 'message': body['message'] ?? 'Failed to update journey'};
    } catch (e) {
      print('JourneyService updateJourney Error: $e');
      return {'success': false, 'message': 'Network error. Please try again.'};
    }
  }
}
