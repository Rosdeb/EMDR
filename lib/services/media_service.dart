import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jonssony/services/app_url.dart';

class MediaService {
  static const String _baseUrl = '${AppUrl.baseUrl}/media';

  static Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

  // ─── 1. Get All Media ──────────────────────────────────────
  static Future<Map<String, dynamic>> getAllMedia({
    required String token,
    int page = 1,
    int limit = 100, // Fetch more to cover all categories easily
  }) async {
    final response = await http.get(
      Uri.parse('$_baseUrl?page=$page&limit=$limit'),
      headers: _headers(token),
    );
    return _handleResponse(response);
  }

  // ─── 2. Get Media By ID ────────────────────────────────────
  static Future<Map<String, dynamic>> getMediaById({
    required String token,
    required String mediaId,
  }) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/$mediaId'),
      headers: _headers(token),
    );
    return _handleResponse(response);
  }

  // ─── 3. Get Media By Category ──────────────────────────────
  static Future<Map<String, dynamic>> getMediaByCategoryId({
    required String token,
    required String categoryId,
  }) async {
    final response = await http.get(
      Uri.parse('${AppUrl.baseUrl}/categories/$categoryId/media'),
      headers: _headers(token),
    );
    return _handleResponse(response);
  }

  // ─── 4. Upload Media (Multipart) ───────────────────────────
  static Future<Map<String, dynamic>> uploadMedia({
    required String token,
    required String categoryId,
    required String filePath,
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(_baseUrl));
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });
      request.fields['categoryId'] = categoryId;
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } catch (e) {
      print('MediaService Upload Error: $e');
      return {'success': false, 'message': 'Failed to upload file'};
    }
  }

  // ─── 4. Update Media ───────────────────────────────────────
  static Future<Map<String, dynamic>> updateMedia({
    required String token,
    required String mediaId,
    required Map<String, dynamic> data,
  }) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/$mediaId'),
      headers: _headers(token),
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  // ─── 5. Delete Media ───────────────────────────────────────
  static Future<Map<String, dynamic>> deleteMedia({
    required String token,
    required String mediaId,
  }) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/$mediaId'),
      headers: _headers(token),
    );
    return _handleResponse(response);
  }

  // ─── Response Handler ──────────────────────────────────────
  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final bool isSuccess = response.statusCode >= 200 && response.statusCode < 300;

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
      print('MediaService Parsing Error: $e');
      return {
        'success': false,
        'message': 'Invalid server response',
      };
    }
  }
}
