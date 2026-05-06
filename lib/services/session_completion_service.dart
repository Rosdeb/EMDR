import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jonssony/controller/auth_controller.dart';
import 'package:jonssony/services/session_progress_service.dart';

class SessionCompletionService {
  static const int totalSessions = 10;
  static const String _key = 'completed_emdr_sessions';
  static const String _activeJourneyIdKey = 'active_emdr_journey_id';

  static final GetStorage _box = GetStorage();
  static final RxList<int> completedSessionNumbers = <int>[].obs;

  static List<int> _readCompletedSessions() {
    final raw = _box.read<List<dynamic>>(_key) ?? [];
    return raw
        .map((item) => int.tryParse(item.toString()) ?? 0)
        .where((session) => session >= 1 && session <= totalSessions)
        .toSet()
        .toList()
      ..sort();
  }

  static void syncFromStorage() {
    final sessions = _readCompletedSessions();
    if (completedSessionNumbers.length == sessions.length &&
        completedSessionNumbers.every(
          (session) => sessions.contains(session),
        )) {
      return;
    }
    completedSessionNumbers.assignAll(sessions);
  }

  static List<int> completedSessions() => _readCompletedSessions();

  static int completedCount() => completedSessions().length;

  static Future<void> markCompleted(
    int sessionNumber, {
    String? journeyId,
  }) async {
    if (sessionNumber < 1 || sessionNumber > totalSessions) return;

    final sessions = completedSessions().toSet();
    sessions.add(sessionNumber);
    final sorted = sessions.toList()..sort();
    await _box.write(_key, sorted);
    completedSessionNumbers.assignAll(sorted);

    await _syncRemoteProgress(
      journeyId: _resolveJourneyId(journeyId),
      completedSessions: sorted.length,
    );
  }

  static String _resolveJourneyId(String? journeyId) {
    if (journeyId != null && journeyId.isNotEmpty) {
      _box.write(_activeJourneyIdKey, journeyId);
      return journeyId;
    }

    final args = Get.arguments;
    if (args is Map && args['journeyId'] != null) {
      final routeJourneyId = args['journeyId'].toString();
      if (routeJourneyId.isNotEmpty) {
        _box.write(_activeJourneyIdKey, routeJourneyId);
        return routeJourneyId;
      }
    }

    return _box.read<String>(_activeJourneyIdKey) ?? '';
  }

  static Future<void> _syncRemoteProgress({
    required String journeyId,
    required int completedSessions,
  }) async {
    if (journeyId.isEmpty || !Get.isRegistered<AuthController>()) return;

    final token = Get.find<AuthController>().token;
    if (token == null || token.isEmpty) return;

    final result = await SessionProgressService.updateProgress(token, {
      'journeyId': journeyId,
      'totalSession': totalSessions,
      'compledSession': completedSessions,
    });

    if (result['success'] != true) {
      debugPrint(
        'Session progress sync failed: ${result['message'] ?? 'Unknown error'}',
      );
    }
  }
}
