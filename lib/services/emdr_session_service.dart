import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:jonssony/services/app_url.dart';

class EmdrSessionService {
  static const String _baseUrl = '${AppUrl.baseUrl}/emdr-session';

  static Map<String, String> _headers(String token) => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };

  static Future<Map<String, dynamic>> startSession(
    String token,
    String sessionType,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/start'),
        headers: _headers(token),
        body: jsonEncode({'sessionType': sessionType}),
      );
      print('EMDR startSession: status ${response.statusCode}, body: ${response.body}');
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final bool isSuccess =
          response.statusCode >= 200 && response.statusCode < 300;
      if (isSuccess) {
        final data = body['data'] ?? body;
        return {'success': true, 'data': data};
      }
      return {
        'success': false,
        'message': body['message'] ?? 'Failed to start session',
      };
    } catch (e) {
      print('EmdrSessionService startSession Error: $e');
      return {'success': false, 'message': 'Network error. Please try again.'};
    }
  }

  static Future<Map<String, dynamic>> saveTarget(
    String token,
    String sessionId, {
    required String targetDescription,
    required String freezeFrame,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/$sessionId/target'),
        headers: _headers(token),
        body: jsonEncode({
          'targetDescription': targetDescription,
          'freezeFrame': freezeFrame,
        }),
      );
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final bool isSuccess =
          response.statusCode >= 200 && response.statusCode < 300;
      if (isSuccess) return {'success': true, 'data': body['data']};
      return {
        'success': false,
        'message': body['message'] ?? 'Failed to save target',
      };
    } catch (e) {
      print('EmdrSessionService saveTarget Error: $e');
      return {'success': false, 'message': 'Network error. Please try again.'};
    }
  }

  /// Save target with optional file uploads (multipart/form-data)
  static Future<Map<String, dynamic>> saveTargetWithFiles(
    String token,
    String sessionId, {
    required String targetDescription,
    required String freezeFrame,
    File? targetFile,
    File? freezeFrameFile,
  }) async {
    // If no files, just use JSON endpoint
    if (targetFile == null && freezeFrameFile == null) {
      return saveTarget(
        token,
        sessionId,
        targetDescription: targetDescription,
        freezeFrame: freezeFrame,
      );
    }

    try {
      final uri = Uri.parse('$_baseUrl/$sessionId/target');
      final request = http.MultipartRequest('PATCH', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..headers['Accept'] = 'application/json'
        ..fields['targetDescription'] = targetDescription
        ..fields['freezeFrame'] = freezeFrame;

      if (targetFile != null) {
        final mimeType = lookupMimeType(targetFile.path) ?? 'application/octet-stream';
        final parts = mimeType.split('/');
        request.files.add(await http.MultipartFile.fromPath(
          'targetFile',
          targetFile.path,
          contentType: MediaType(parts[0], parts[1]),
        ));
      }

      if (freezeFrameFile != null) {
        final mimeType = lookupMimeType(freezeFrameFile.path) ?? 'application/octet-stream';
        final parts = mimeType.split('/');
        request.files.add(await http.MultipartFile.fromPath(
          'freezeFrameFile',
          freezeFrameFile.path,
          contentType: MediaType(parts[0], parts[1]),
        ));
      }

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final bool isSuccess = response.statusCode >= 200 && response.statusCode < 300;
      if (isSuccess) return {'success': true, 'data': body['data']};
      return {
        'success': false,
        'message': body['message'] ?? 'Failed to save target with files',
      };
    } catch (e) {
      print('EmdrSessionService saveTargetWithFiles Error: $e');
      return {'success': false, 'message': 'Network error. Please try again.'};
    }
  }

  static Future<Map<String, dynamic>> saveBeliefs(
    String token,
    String sessionId,
    List<Map<String, dynamic>> beliefPairs,
  ) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/$sessionId/beliefs'),
        headers: _headers(token),
        body: jsonEncode({'beliefPairs': beliefPairs}),
      );
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final bool isSuccess =
          response.statusCode >= 200 && response.statusCode < 300;
      if (isSuccess) return {'success': true, 'data': body['data']};
      return {
        'success': false,
        'message': body['message'] ?? 'Failed to save beliefs',
      };
    } catch (e) {
      print('EmdrSessionService saveBeliefs Error: $e');
      return {'success': false, 'message': 'Network error. Please try again.'};
    }
  }

  static Future<Map<String, dynamic>> saveEmotions(
    String token,
    String sessionId, {
    required String primaryEmotion,
    required String additionalEmotions,
    required String bodyLocation,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/$sessionId/emotions'),
        headers: _headers(token),
        body: jsonEncode({
          'primaryEmotion': primaryEmotion,
          'additionalEmotions': additionalEmotions,
          'bodyLocation': bodyLocation,
        }),
      );
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final bool isSuccess =
          response.statusCode >= 200 && response.statusCode < 300;
      if (isSuccess) return {'success': true, 'data': body['data']};
      return {
        'success': false,
        'message': body['message'] ?? 'Failed to save emotions',
      };
    } catch (e) {
      print('EmdrSessionService saveEmotions Error: $e');
      return {'success': false, 'message': 'Network error. Please try again.'};
    }
  }

  static Future<Map<String, dynamic>> saveSud(
    String token,
    String sessionId,
    int sudRating,
  ) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/$sessionId/sud'),
        headers: _headers(token),
        body: jsonEncode({'sudRating': sudRating}),
      );
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final bool isSuccess =
          response.statusCode >= 200 && response.statusCode < 300;
      if (isSuccess) return {'success': true, 'data': body['data']};
      return {
        'success': false,
        'message': body['message'] ?? 'Failed to save SUD rating',
      };
    } catch (e) {
      print('EmdrSessionService saveSud Error: $e');
      return {'success': false, 'message': 'Network error. Please try again.'};
    }
  }

  static Future<Map<String, dynamic>> saveAddiction(
    String token,
    String sessionId,
    Map<String, dynamic> addictionBody,
  ) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/$sessionId/addiction'),
        headers: _headers(token),
        body: jsonEncode(addictionBody),
      );
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final bool isSuccess =
          response.statusCode >= 200 && response.statusCode < 300;
      if (isSuccess) return {'success': true, 'data': body['data']};
      return {
        'success': false,
        'message': body['message'] ?? 'Failed to save addiction context',
      };
    } catch (e) {
      print('EmdrSessionService saveAddiction Error: $e');
      return {'success': false, 'message': 'Network error. Please try again.'};
    }
  }

  static Future<Map<String, dynamic>> completeSession(
    String token,
    String sessionId,
  ) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/$sessionId/complete'),
        headers: _headers(token),
      );
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final bool isSuccess =
          response.statusCode >= 200 && response.statusCode < 300;
      if (isSuccess) return {'success': true, 'data': body['data']};
      return {
        'success': false,
        'message': body['message'] ?? 'Failed to complete session',
      };
    } catch (e) {
      print('EmdrSessionService completeSession Error: $e');
      return {'success': false, 'message': 'Network error. Please try again.'};
    }
  }

  /// PATCH /emdr-session/:id/abandon
  static Future<Map<String, dynamic>> abandonSession(
    String token,
    String sessionId,
  ) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/$sessionId/abandon'),
        headers: _headers(token),
      );
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final bool isSuccess =
          response.statusCode >= 200 && response.statusCode < 300;
      if (isSuccess) return {'success': true, 'data': body['data']};
      return {
        'success': false,
        'message': body['message'] ?? 'Failed to abandon session',
      };
    } catch (e) {
      print('EmdrSessionService abandonSession Error: $e');
      return {'success': false, 'message': 'Network error. Please try again.'};
    }
  }

  /// GET /emdr-session/:id
  static Future<Map<String, dynamic>> getSession(
    String token,
    String sessionId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$sessionId'),
        headers: _headers(token),
      );
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final bool isSuccess =
          response.statusCode >= 200 && response.statusCode < 300;
      if (isSuccess) return {'success': true, 'data': body['data']};
      return {
        'success': false,
        'message': body['message'] ?? 'Failed to get session',
      };
    } catch (e) {
      print('EmdrSessionService getSession Error: $e');
      return {'success': false, 'message': 'Network error. Please try again.'};
    }
  }

  /// GET /emdr-session/latest
  static Future<Map<String, dynamic>> getLatestSession(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/latest'),
        headers: _headers(token),
      );
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final bool isSuccess =
          response.statusCode >= 200 && response.statusCode < 300;
      if (isSuccess) return {'success': true, 'data': body['data']};
      return {
        'success': false,
        'message': body['message'] ?? 'Failed to get latest session',
      };
    } catch (e) {
      print('EmdrSessionService getLatestSession Error: $e');
      return {'success': false, 'message': 'Network error. Please try again.'};
    }
  }

  /// GET /emdr-session?page=1&limit=20
  /// Returns: { sessions: [...], pagination: { total, page, limit, totalPages, hasNextPage } }
  static Future<Map<String, dynamic>> listSessions(
    String token, {
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    try {
      final params = <String, String>{'page': '$page', 'limit': '$limit'};
      if (status != null) params['status'] = status;
      final response = await http.get(
        Uri.parse(_baseUrl).replace(queryParameters: params),
        headers: _headers(token),
      );
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final bool isSuccess =
          response.statusCode >= 200 && response.statusCode < 300;
      if (isSuccess) {
        // API returns data: { sessions: [...], pagination: {...} }
        final dataMap = body['data'] as Map<String, dynamic>? ?? {};
        return {
          'success': true,
          'sessions': dataMap['sessions'] ?? [],
          'pagination': dataMap['pagination'] ?? {},
        };
      }
      return {
        'success': false,
        'message': body['message'] ?? 'Failed to list sessions',
      };
    } catch (e) {
      print('EmdrSessionService listSessions Error: $e');
      return {'success': false, 'message': 'Network error. Please try again.'};
    }
  }

  /// DELETE /emdr-session/:id
  static Future<Map<String, dynamic>> deleteSession(
    String token,
    String sessionId,
  ) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/$sessionId'),
        headers: _headers(token),
      );
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final bool isSuccess =
          response.statusCode >= 200 && response.statusCode < 300;
      if (isSuccess) return {'success': true, 'data': body['data']};
      return {
        'success': false,
        'message': body['message'] ?? 'Failed to delete session',
      };
    } catch (e) {
      print('EmdrSessionService deleteSession Error: $e');
      return {'success': false, 'message': 'Network error. Please try again.'};
    }
  }
}
