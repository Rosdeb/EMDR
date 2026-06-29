import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:jonssony/services/app_url.dart';

enum VoicePlaybackResult { completed, cancelled, failed }

/// Plays the same authenticated natural-voice audio used by emdr-web.
///
/// Only one narration can be active per service instance. TTS URLs and
/// in-flight requests are deduplicated by `cacheNamespace + exact text`.
class VoiceService extends ChangeNotifier {
  VoiceService({http.Client? httpClient, GetStorage? storage})
    : _httpClient = httpClient ?? http.Client(),
      _storage = storage ?? GetStorage() {
    _completionSubscription = _player.onPlayerComplete.listen((_) {
      _finishActive(VoicePlaybackResult.completed);
    });
  }

  final http.Client _httpClient;
  final GetStorage _storage;
  final AudioPlayer _player = AudioPlayer();
  final Map<String, String> _audioUrlCache = <String, String>{};
  final Map<String, Future<String>> _pendingRequests =
      <String, Future<String>>{};

  late final StreamSubscription<void> _completionSubscription;
  Completer<VoicePlaybackResult>? _activeCompleter;
  VoidCallback? _activeOnDone;
  int _playbackGeneration = 0;
  bool isSpeaking = false;
  bool isPaused = false;

  Future<void> init() async {}

  Future<void> prefetch(
    String text, {
    String cacheNamespace = 'session-prompt',
  }) async {
    final normalizedText = text.trim();
    if (normalizedText.isEmpty) return;
    await _getNaturalVoiceUrl(normalizedText, cacheNamespace);
  }

  Future<VoicePlaybackResult> speak(
    String text, {
    String cacheNamespace = 'session-prompt',
    VoidCallback? onDone,
  }) async {
    final normalizedText = text.trim();
    if (normalizedText.isEmpty) return VoicePlaybackResult.failed;

    final generation = await _beginPlayback(onDone: onDone);
    try {
      final audioUrl = await _getNaturalVoiceUrl(
        normalizedText,
        cacheNamespace,
      );
      if (generation != _playbackGeneration) {
        return VoicePlaybackResult.cancelled;
      }
      return _playUrlForGeneration(audioUrl, generation);
    } catch (error) {
      if (generation != _playbackGeneration) {
        return VoicePlaybackResult.cancelled;
      }
      debugPrint(
        '[Voice API:$cacheNamespace] Natural voice unavailable: $error',
      );
      if (generation == _playbackGeneration) {
        _finishActive(VoicePlaybackResult.failed);
      }
      return VoicePlaybackResult.failed;
    }
  }

  Future<VoicePlaybackResult> playUrl(
    String audioUrl, {
    VoidCallback? onDone,
  }) async {
    final normalizedUrl = audioUrl.trim();
    if (normalizedUrl.isEmpty) return VoicePlaybackResult.failed;

    final generation = await _beginPlayback(onDone: onDone);
    return _playUrlForGeneration(normalizedUrl, generation);
  }

  Future<void> pause() async {
    if (!isSpeaking || isPaused) return;
    await _player.pause();
    isSpeaking = false;
    isPaused = true;
    notifyListeners();
  }

  Future<void> resume() async {
    if (!isPaused || _activeCompleter == null) return;
    await _player.resume();
    isPaused = false;
    isSpeaking = true;
    notifyListeners();
  }

  Future<void> stop() async {
    _playbackGeneration++;
    await _player.stop();
    _finishActive(VoicePlaybackResult.cancelled);
  }

  Future<int> _beginPlayback({VoidCallback? onDone}) async {
    _playbackGeneration++;
    final generation = _playbackGeneration;
    await _player.stop();
    _finishActive(VoicePlaybackResult.cancelled);
    _activeCompleter = Completer<VoicePlaybackResult>();
    _activeOnDone = onDone;
    return generation;
  }

  Future<VoicePlaybackResult> _playUrlForGeneration(
    String audioUrl,
    int generation,
  ) async {
    if (generation != _playbackGeneration) {
      return VoicePlaybackResult.cancelled;
    }

    final completer = _activeCompleter;
    if (completer == null) return VoicePlaybackResult.cancelled;

    try {
      await _player.play(UrlSource(audioUrl));
      if (generation != _playbackGeneration) {
        return VoicePlaybackResult.cancelled;
      }
      isSpeaking = true;
      isPaused = false;
      notifyListeners();
      return completer.future;
    } catch (error) {
      debugPrint('Unable to play natural voice audio: $error');
      if (generation == _playbackGeneration) {
        _finishActive(VoicePlaybackResult.failed);
      }
      return VoicePlaybackResult.failed;
    }
  }

  Future<String> _getNaturalVoiceUrl(String text, String cacheNamespace) async {
    final cacheKey = '$cacheNamespace:$text';
    final cachedUrl = _audioUrlCache[cacheKey];
    if (cachedUrl != null && cachedUrl.isNotEmpty) return cachedUrl;

    final existingRequest = _pendingRequests[cacheKey];
    if (existingRequest != null) return existingRequest;

    final request = _requestNaturalVoiceAudio(text, cacheNamespace);
    _pendingRequests[cacheKey] = request;
    try {
      final audioUrl = await request;
      _audioUrlCache[cacheKey] = audioUrl;
      return audioUrl;
    } finally {
      _pendingRequests.remove(cacheKey);
    }
  }

  Future<String> _requestNaturalVoiceAudio(
    String text,
    String cacheNamespace,
  ) async {
    final token = _storage.read<String>('auth_token')?.trim() ?? '';
    if (token.isEmpty) {
      throw StateError('Natural voice service requires authentication.');
    }

    final response = await _httpClient.post(
      Uri.parse('${AppUrl.baseUrl}/voice/tts'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'text': text, 'cacheNamespace': cacheNamespace}),
    );

    final decoded = jsonDecode(response.body);
    final body = decoded is Map
        ? Map<String, dynamic>.from(decoded)
        : <String, dynamic>{};
    final data = body['data'] is Map
        ? Map<String, dynamic>.from(body['data'] as Map)
        : <String, dynamic>{};
    final audioUrl = data['audioUrl']?.toString().trim() ?? '';

    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        body['success'] != true ||
        audioUrl.isEmpty) {
      final error = body['error'] is Map
          ? Map<String, dynamic>.from(body['error'] as Map)
          : <String, dynamic>{};
      final message =
          body['message']?.toString() ??
          error['message']?.toString() ??
          'Natural voice audio is unavailable.';
      throw StateError('Voice API ${response.statusCode}: $message');
    }

    return audioUrl;
  }

  void _finishActive(VoicePlaybackResult result) {
    final completer = _activeCompleter;
    final onDone = _activeOnDone;
    _activeCompleter = null;
    _activeOnDone = null;
    isSpeaking = false;
    isPaused = false;
    if (completer != null && !completer.isCompleted) {
      completer.complete(result);
    }
    notifyListeners();
    if (result == VoicePlaybackResult.completed) onDone?.call();
  }

  @override
  void dispose() {
    _playbackGeneration++;
    _finishActive(VoicePlaybackResult.cancelled);
    unawaited(_completionSubscription.cancel());
    unawaited(_player.dispose());
    _httpClient.close();
    super.dispose();
  }
}
