import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jonssony/services/app_url.dart';

class CbtService {
  static const String _baseUrl = '${AppUrl.baseUrl}/cbt-formulation';

  static Future<Map<String, dynamic>> getOptions(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/options'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> saveCbt({
    required String token,
    String? childhood,
    List<String>? deepBeliefs,
    String? rules,
    String? triggers,
    String? recentHappening,
    String? thoughts,
    List<String>? feelings,
    String? behaviors,
    List<String>? consequences,
    String? consequencesOther,
    String? superpowers,
  }) async {
    try {
      final body = {
        if (childhood != null) 'childhood': childhood,
        if (deepBeliefs != null) 'deepBeliefs': deepBeliefs,
        if (rules != null) 'rules': rules,
        if (triggers != null) 'triggers': triggers,
        if (recentHappening != null) 'recentHappening': recentHappening,
        if (thoughts != null) 'thoughts': thoughts,
        if (feelings != null) 'feelings': feelings,
        if (behaviors != null) 'behaviors': behaviors,
        if (consequences != null) 'consequences': consequences,
        if (consequencesOther != null) 'consequencesOther': consequencesOther,
        if (superpowers != null) 'superpowers': superpowers,
      };

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getAllFormulations(String token) async {
    try {
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getFormulationById(String token, String id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> patchSection(String token, String id, String section, dynamic value) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/$id/section'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({section: value}),
      );
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> fullUpdate(String token, String id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(data),
      );
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> deleteFormulation(String token, String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
