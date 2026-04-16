import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jonssony/services/app_url.dart';

class OnboardingService {
  static const String _onboardingUrl = '${AppUrl.baseUrl}/onboarding';
  static const String _assessmentUrl = '${AppUrl.baseUrl}/assessment';

  static Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

  // 1. Get Onboarding Status
  static Future<Map<String, dynamic>> getOnboardingStatus(String token) async {
    final response = await http.get(
      Uri.parse('$_onboardingUrl/status'),
      headers: _headers(token),
    );
    return _handleResponse(response);
  }

  // 2. Step 1 - Save Profile
  static Future<Map<String, dynamic>> saveProfile({
    required String token,
    required String dateOfBirth,
    required String sex,
  }) async {
    final response = await http.post(
      Uri.parse('$_onboardingUrl/profile'),
      headers: _headers(token),
      body: jsonEncode({
        'dateOfBirth': dateOfBirth,
        'sex': sex.toLowerCase(),
      }),
    );
    return _handleResponse(response);
  }

  // 3. Step 2 - Safety Check
  static Future<Map<String, dynamic>> submitSafetyCheck({
    required String token,
    required bool activeSuicidalThoughts,
    required bool historyOfSeizures,
    required bool pregnancy,
    required bool severeDissociativeDisorders,
    required bool activePsychosis,
  }) async {
    final response = await http.post(
      Uri.parse('$_onboardingUrl/safety-check'),
      headers: _headers(token),
      body: jsonEncode({
        'activeSuicidalThoughts': activeSuicidalThoughts,
        'historyOfSeizures': historyOfSeizures,
        'pregnancy': pregnancy,
        'severeDissociativeDisorders': severeDissociativeDisorders,
        'activePsychosis': activePsychosis,
      }),
    );
    return _handleResponse(response);
  }

  // 4. Step 3 - Save Consent
  static Future<Map<String, dynamic>> saveConsent({
    required String token,
    required bool understoodEMDRNatureAndRisks,
    required bool agreedToGDPR,
    required bool participatingVoluntarily,
    required bool savedCrisisSupportNumbers,
    required bool optionalResearchParticipation,
    required String electronicSignature,
  }) async {
    final response = await http.post(
      Uri.parse('$_onboardingUrl/consent'),
      headers: _headers(token),
      body: jsonEncode({
        'understoodEMDRNatureAndRisks': understoodEMDRNatureAndRisks,
        'agreedToGDPR': agreedToGDPR,
        'participatingVoluntarily': participatingVoluntarily,
        'savedCrisisSupportNumbers': savedCrisisSupportNumbers,
        'optionalResearchParticipation': optionalResearchParticipation,
        'electronicSignature': electronicSignature,
      }),
    );
    return _handleResponse(response);
  }

  // 5. Submit Assessment
  static Future<Map<String, dynamic>> submitAssessment({
    required String token,
    required List<int> phq9Answers,
    required List<int> gad7Answers,
    required List<double> des11Answers,
  }) async {
    final response = await http.post(
      Uri.parse('$_assessmentUrl/submit'),
      headers: _headers(token),
      body: jsonEncode({
        'phq9Answers': phq9Answers,
        'gad7Answers': gad7Answers,
        'des11Answers': des11Answers,
      }),
    );
    return _handleResponse(response);
  }

  // 6. Get Latest Assessment Result
  static Future<Map<String, dynamic>> getLatestResult(String token) async {
    final response = await http.get(
      Uri.parse('$_assessmentUrl/result'),
      headers: _headers(token),
    );
    return _handleResponse(response);
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final bool isSuccess = response.statusCode >= 200 && response.statusCode < 300;

      print('API Response (${response.statusCode}): ${response.body}');

      if (isSuccess) {
        return {'success': true, 'data': body};
      }

      String? errorMessage;
      if (body['message'] != null) {
        errorMessage = body['message'].toString();
      } else if (body['error'] != null) {
        errorMessage = body['error'].toString();
      }

      return {
        'success': false,
        'message': errorMessage ?? 'Server error: ${response.statusCode}',
        'data': body,
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
