import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jonssony/controller/auth_controller.dart';
import 'package:jonssony/controller/session_progress_controller.dart';
import 'package:jonssony/services/session_progress_service.dart';

class SessionCompletionService {
  static const int totalSessions = 10;
  static const String _key = 'completed_emdr_sessions';
  static const String _activeJourneyIdKey = 'active_emdr_journey_id';

  static final GetStorage _box = GetStorage();
  static final RxList<int> completedSessionNumbers = <int>[].obs;

  static String _storageKeyForJourney(String journeyId) {
    if (journeyId.isEmpty) return _key;

    return '${_key}_$journeyId';
  }

  static List<int> _readCompletedSessions([String? journeyId]) {
    final raw =
        _box.read<List<dynamic>>(_storageKeyForJourney(journeyId ?? '')) ?? [];
    return raw
        .map((item) => int.tryParse(item.toString()) ?? 0)
        .where((session) => session >= 1 && session <= totalSessions)
        .toSet()
        .toList()
      ..sort();
  }

  static void syncFromStorage() {
    final sessions = _readCompletedSessions(activeJourneyId());
    if (completedSessionNumbers.length == sessions.length &&
        completedSessionNumbers.every(
          (session) => sessions.contains(session),
        )) {
      return;
    }
    completedSessionNumbers.assignAll(sessions);
  }

  static List<int> completedSessions({String? journeyId}) =>
      _readCompletedSessions(journeyId ?? activeJourneyId());

  static int completedCount({String? journeyId}) =>
      completedSessions(journeyId: journeyId).length;

  static String activeJourneyId() =>
      _box.read<String>(_activeJourneyIdKey) ?? '';

  static Future<void> markCompleted(
    int sessionNumber, {
    String? journeyId,
  }) async {
    if (sessionNumber < 1 || sessionNumber > totalSessions) return;

    final resolvedJourneyId = _resolveJourneyId(journeyId);
    final sessions = completedSessions(journeyId: resolvedJourneyId).toSet();
    for (var session = 1; session <= sessionNumber; session++) {
      sessions.add(session);
    }

    final sorted = sessions.toList()..sort();
    await _box.write(_storageKeyForJourney(resolvedJourneyId), sorted);
    completedSessionNumbers.assignAll(sorted);

    await _syncRemoteProgress(
      journeyId: resolvedJourneyId,
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

    if (result['success'] == true) {
      if (Get.isRegistered<SessionProgressController>()) {
        Get.find<SessionProgressController>().upsertJourneyProgress(
          journeyId,
          result['data'],
        );
      }
      return;
    }

    if (result['success'] != true) {
      debugPrint(
        'Session progress sync failed: ${result['message'] ?? 'Unknown error'}',
      );
    }
  }
}
