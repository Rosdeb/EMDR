import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jonssony/services/app_url.dart';

class MyTestsService {
  static const String _categoriesUrl = '${AppUrl.baseUrl}/my-tests/categories';
  static const String _itemsUrl = '${AppUrl.baseUrl}/my-tests/items';

  static Map<String, String> _headers(String token) => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };

  static List<Map<String, dynamic>> _normalizeItems(List<dynamic> rawItems) {
    return rawItems.map((item) {
      if (item is Map<String, dynamic>) {
        final normalized = Map<String, dynamic>.from(item);
        if (normalized['_id'] == null && normalized['id'] != null) {
          normalized['_id'] = normalized['id'];
        }
        if (normalized['categoryId'] == null && normalized['category'] is Map) {
          final category = normalized['category'] as Map<String, dynamic>;
          normalized['categoryId'] = {
            '_id': category['id'] ?? category['_id'],
            'categoryName': category['name'] ?? category['categoryName'],
          };
        }
        return normalized;
      }
      return Map<String, dynamic>.from(item as Map);
    }).toList();
  }

  // Categories API
  static Future<Map<String, dynamic>> createCategory(
    String token,
    String name,
    String description,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(_categoriesUrl),
        headers: _headers(token),
        body: jsonEncode({'categoryName': name, 'description': description}),
      );
      final body = jsonDecode(response.body);
      return {
        'success': response.statusCode == 201 || response.statusCode == 200,
        'data': body['data'],
        'message': body['message'],
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getCategories(
    String token, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_categoriesUrl?page=$page&limit=$limit'),
        headers: _headers(token),
      );
      final body = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200,
        'data': body['data'],
        'message': body['message'],
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getCategoryById(
    String token,
    String id,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$_categoriesUrl/$id'),
        headers: _headers(token),
      );
      final body = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200,
        'data': body['data'],
        'message': body['message'],
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> updateCategory(
    String token,
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await http.patch(
        Uri.parse('$_categoriesUrl/$id'),
        headers: _headers(token),
        body: jsonEncode(data),
      );
      final body = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200,
        'data': body['data'],
        'message': body['message'],
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getCategoryStats(
    String token,
    String id,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$_categoriesUrl/$id/stats'),
        headers: _headers(token),
      );
      final body = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200,
        'data': body['data'],
        'message': body['message'],
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> deleteCategory(
    String token,
    String id,
  ) async {
    try {
      final response = await http.delete(
        Uri.parse('$_categoriesUrl/$id'),
        headers: _headers(token),
      );
      return {'success': response.statusCode == 200};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Items API
  static Future<Map<String, dynamic>> createItem(
    String token,
    String categoryId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_categoriesUrl/$categoryId/items'),
        headers: _headers(token),
        body: jsonEncode(data),
      );
      final body = jsonDecode(response.body);
      return {
        'success': response.statusCode == 201 || response.statusCode == 200,
        'data': body['data'],
        'message': body['message'],
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getItemsByCategory(
    String token,
    String categoryId, {
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_categoriesUrl/$categoryId/items?page=$page&limit=$limit'),
        headers: _headers(token),
      );
      final body = jsonDecode(response.body);
      final data = body['data'] as Map<String, dynamic>?;
      final rawItems = data?['items'] as List<dynamic>? ?? [];
      return {
        'success': response.statusCode == 200,
        'data': {
          'items': _normalizeItems(rawItems),
          'pagination': data?['pagination'],
        },
        'message': body['message'],
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getAllItems(
    String token, {
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_itemsUrl?page=$page&limit=$limit'),
        headers: _headers(token),
      );
      final body = jsonDecode(response.body);
      final data = body['data'] as Map<String, dynamic>?;
      final rawItems = data?['items'] as List<dynamic>? ?? [];
      return {
        'success': response.statusCode == 200,
        'data': {
          'items': _normalizeItems(rawItems),
          'pagination': data?['pagination'],
        },
        'message': body['message'],
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getItemById(
    String token,
    String id,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$_itemsUrl/$id'),
        headers: _headers(token),
      );
      final body = jsonDecode(response.body);
      final data = body['data'] as Map<String, dynamic>?;
      if (data != null) {
        if (data['_id'] == null && data['id'] != null) {
          data['_id'] = data['id'];
        }
        if (data['categoryId'] == null && data['category'] is Map) {
          final category = data['category'] as Map<String, dynamic>;
          data['categoryId'] = {
            '_id': category['id'] ?? category['_id'],
            'categoryName': category['name'] ?? category['categoryName'],
          };
        }
      }
      return {
        'success': response.statusCode == 200,
        'data': data,
        'message': body['message'],
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> updateItem(
    String token,
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await http.patch(
        Uri.parse('$_itemsUrl/$id'),
        headers: _headers(token),
        body: jsonEncode(data),
      );
      final body = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200,
        'data': body['data'],
        'message': body['message'],
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
