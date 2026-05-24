import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:jonssony/controller/auth_controller.dart';
import 'package:jonssony/services/session_progress_service.dart';

class SessionProgressController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isJourneyProgressLoading = false.obs;
  final RxList<dynamic> progresses = [].obs;
  final RxInt progressRevision = 0.obs;
  final RxMap<String, Map<String, dynamic>> journeyProgresses =
      <String, Map<String, dynamic>>{}.obs;
  final Map<String, DateTime> _lastFetchedAtByJourney = {};
  final Set<String> _requestedJourneyProgressIds = {};
  static const Duration _progressRefreshInterval = Duration(seconds: 3);

  String _journeyIdFrom(dynamic journey) {
    if (journey is! Map) return '';

    for (final key in ['_id', 'id', 'journeyId']) {
      final value = _idValue(journey[key]);
      if (value.isNotEmpty) return value;
    }

    return '';
  }

  String _idValue(dynamic value) {
    if (value == null) return '';

    if (value is Map) {
      for (final key in [r'$oid', 'oid', '_id', 'id']) {
        final nested = _idValue(value[key]);
        if (nested.isNotEmpty) return nested;
      }
      return '';
    }

    final text = value.toString();
    if (text.isEmpty || text == 'null') return '';

    return text;
  }

  void upsertJourneyProgress(String journeyId, dynamic data) {
    if (journeyId.isEmpty || data is! Map) return;

    if (kDebugMode) {
      debugPrint('Progress upsert journeyId=$journeyId data=$data');
    }
    journeyProgresses[journeyId] = Map<String, dynamic>.from(data);
    _lastFetchedAtByJourney[journeyId] = DateTime.now();
    _requestedJourneyProgressIds.remove(journeyId);
    progressRevision.value++;
  }

  Future<void> fetchProgresses() async {
    try {
      isLoading.value = true;
      final authController = Get.find<AuthController>();
      final token = authController.token;

      if (token == null) {
        isLoading.value = false;
        return;
      }

      final result = await SessionProgressService.getAllProgress(token);
      if (result['success'] == true) {
        final data = result['data'];
        if (data is List) {
          progresses.value = data;
        } else if (data != null) {
          progresses.value = [data];
        } else {
          Get.snackbar('Debug', 'Progress data is null');
        }
      } else {
        Get.snackbar(
          'API Error',
          result['message'] ?? 'Failed to load progress',
        );
        debugPrint("Failed to fetch progresses: ${result['message']}");
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
      debugPrint("Error fetching progresses: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchProgressForJourneys(List<dynamic> journeys) async {
    final authController = Get.find<AuthController>();
    final token = authController.token;
    if (token == null || journeys.isEmpty) return;

    final journeyIds = journeys
        .map(_journeyIdFrom)
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();
    if (kDebugMode) {
      debugPrint('Progress fetch journeyIds=$journeyIds');
    }

    if (!isJourneyProgressLoading.value) {
      _requestedJourneyProgressIds.removeWhere(
        (id) => !journeyProgresses.containsKey(id),
      );
    }

    final now = DateTime.now();
    final refreshIds = journeyIds
        .where((id) {
          if (_requestedJourneyProgressIds.contains(id)) return false;

          final lastFetchedAt = _lastFetchedAtByJourney[id];
          final shouldRefresh =
              lastFetchedAt == null ||
              now.difference(lastFetchedAt) >= _progressRefreshInterval;

          return !journeyProgresses.containsKey(id) || shouldRefresh;
        })
        .toList();
    if (refreshIds.isEmpty) return;

    _requestedJourneyProgressIds.addAll(refreshIds);
    isJourneyProgressLoading.value = true;
    try {
      final responses = await Future.wait(
        refreshIds.map((journeyId) async {
          final result = await SessionProgressService.getProgressById(
            token,
            journeyId,
          );
          return MapEntry(journeyId, result);
        }),
      );

      for (final response in responses) {
        final journeyId = response.key;
        final result = response.value;
        if (result['success'] == true && result['data'] is Map) {
          upsertJourneyProgress(journeyId, result['data']);
        } else {
          _requestedJourneyProgressIds.remove(journeyId);
        }
      }
    } catch (e) {
      _requestedJourneyProgressIds.removeAll(refreshIds);
      debugPrint("Error fetching journey progress: $e");
    } finally {
      isJourneyProgressLoading.value = false;
    }
  }
}
