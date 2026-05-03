import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jonssony/services/app_url.dart';

class BilateralService {
  static const String _baseUrl = '${AppUrl.baseUrl}/bilateral';

  static Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

  // ─── 1. Get Bilateral Config ─────────────────────────────────
  static Future<Map<String, dynamic>> getConfig(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/config'),
      headers: _headers(token),
    );
    return _handleResponse(response);
  }

  // ─── 2. Save Bilateral Settings ──────────────────────────────
  static Future<Map<String, dynamic>> saveSettings({
    required String token,
    required String environmentUrl,
    required String iconUrl,
    required String soundUrl,
    required String speed, // 'slow', 'medium', 'fast'
    required String direction, // 'left-right', 'diagonal-down', 'diagonal-up'
  }) async {
    final body = <String, dynamic>{
      'environmentId': environmentUrl.trim(),
      'iconUrl': iconUrl.trim(),
      'speed': speed,
      'direction': direction,
    };

    final trimmedSoundUrl = soundUrl.trim();
    if (trimmedSoundUrl.isNotEmpty) {
      body['soundId'] = trimmedSoundUrl;
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/settings'),
      headers: _headers(token),
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  // ─── Response Handler ──────────────────────────────────────
  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final bool isSuccess =
          response.statusCode >= 200 && response.statusCode < 300;

      if (isSuccess) {
        return {'success': true, 'data': body['data']};
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
      print('BilateralService Parsing Error: $e');
      return {
        'success': false,
        'message': 'Invalid server response',
      };
    }
  }
}
