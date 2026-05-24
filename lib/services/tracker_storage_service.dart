import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TrackerResult {
  final String trackerKey;
  final String trackerName;
  final String weekLabel;
  final int score;
  final int maxScore;
  final String band;
  final DateTime savedAt;

  TrackerResult({
    required this.trackerKey,
    required this.trackerName,
    required this.weekLabel,
    required this.score,
    required this.maxScore,
    required this.band,
    required this.savedAt,
  });

  factory TrackerResult.fromJson(Map<String, dynamic> json) {
    return TrackerResult(
      trackerKey: json['trackerKey'],
      trackerName: json['trackerName'],
      weekLabel: json['weekLabel'],
      score: json['score'],
      maxScore: json['maxScore'],
      band: json['band'],
      savedAt: DateTime.parse(json['savedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trackerKey': trackerKey,
      'trackerName': trackerName,
      'weekLabel': weekLabel,
      'score': score,
      'maxScore': maxScore,
      'band': band,
      'savedAt': savedAt.toIso8601String(),
    };
  }
}

class TrackerStorageService {
  static final TrackerStorageService instance = TrackerStorageService._internal();
  TrackerStorageService._internal();

  static const String _prefix = 'tracker_result_';

  Future<SharedPreferences> _prefs() => SharedPreferences.getInstance();

  String _getKey(String trackerKey, String weekLabel) {
    return '$_prefix${trackerKey}_$weekLabel';
  }

  String _getWeekLabel(DateTime date) {
    // ISO week calculation
    int dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays + 1;
    int weekNumber = ((dayOfYear - date.weekday + 10) ~/ 7);
    if (weekNumber == 0) {
      weekNumber = 52; // Previous year
    } else if (weekNumber == 53 && date.month == 1) {
      weekNumber = 1; // Next year
    }
    return '${date.year}-W${weekNumber.toString().padLeft(2, '0')}';
  }

  Future<void> saveResult({
    required String trackerKey,
    required String trackerName,
    required int score,
    required int maxScore,
    required String band,
  }) async {
    final prefs = await _prefs();
    final now = DateTime.now();
    final weekLabel = _getWeekLabel(now);
    final key = _getKey(trackerKey, weekLabel);

    final result = TrackerResult(
      trackerKey: trackerKey,
      trackerName: trackerName,
      weekLabel: weekLabel,
      score: score,
      maxScore: maxScore,
      band: band,
      savedAt: now,
    );

    await prefs.setString(key, jsonEncode(result.toJson()));
  }

  Future<List<TrackerResult>> getResultsForTracker(String trackerKey) async {
    final prefs = await _prefs();
    final keys = prefs.getKeys().where((key) => key.startsWith('$_prefix$trackerKey'));
    final results = <TrackerResult>[];

    for (final key in keys) {
      final jsonString = prefs.getString(key);
      if (jsonString != null) {
        try {
          final json = jsonDecode(jsonString);
          results.add(TrackerResult.fromJson(json));
        } catch (e) {
          // Skip invalid entries
        }
      }
    }

    results.sort((a, b) => a.savedAt.compareTo(b.savedAt));
    return results;
  }

  Future<Map<String, List<TrackerResult>>> getAllResults() async {
    final prefs = await _prefs();
    final keys = prefs.getKeys().where((key) => key.startsWith(_prefix));
    final results = <String, List<TrackerResult>>{};

    for (final key in keys) {
      final jsonString = prefs.getString(key);
      if (jsonString != null) {
        try {
          final json = jsonDecode(jsonString);
          final result = TrackerResult.fromJson(json);
          if (!results.containsKey(result.trackerKey)) {
            results[result.trackerKey] = [];
          }
          results[result.trackerKey]!.add(result);
        } catch (e) {
          // Skip invalid entries
        }
      }
    }

    for (final list in results.values) {
      list.sort((a, b) => a.savedAt.compareTo(b.savedAt));
    }

    return results;
  }

  Future<void> clearAll() async {
    final prefs = await _prefs();
    final keys = prefs.getKeys().where((key) => key.startsWith(_prefix));
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
}