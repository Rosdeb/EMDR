import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class VoiceService extends ChangeNotifier {
  final FlutterTts _tts = FlutterTts();
  bool isSpeaking = false;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.42);
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);
    await _selectCalmVoice();

    _tts.setStartHandler(() {
      isSpeaking = true;
      notifyListeners();
    });
    _tts.setCompletionHandler(_markStopped);
    _tts.setCancelHandler(_markStopped);
    _tts.setErrorHandler((message) {
      _markStopped();
      debugPrint('TTS Error: $message');
    });
  }

  Future<void> speak(String text, {VoidCallback? onDone}) async {
    await init();
    await _tts.stop();

    if (onDone == null) {
      _tts.setCompletionHandler(_markStopped);
    } else {
      _tts.setCompletionHandler(() {
        _markStopped();
        onDone();
        _tts.setCompletionHandler(_markStopped);
      });
    }

    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
    _markStopped();
  }

  Future<void> _selectCalmVoice() async {
    try {
      final result = await _tts.getVoices;
      if (result is! List || result.isEmpty) return;

      final voices = result.whereType<Map>().toList();
      if (voices.isEmpty) return;

      final preferred = voices.firstWhere((voice) {
        final name = (voice['name'] ?? '').toString().toLowerCase();
        return name.contains('samantha') ||
            name.contains('karen') ||
            name.contains('moira') ||
            name.contains('fiona') ||
            name.contains('zira') ||
            name.contains('female');
      }, orElse: () => voices.first);

      final name = preferred['name']?.toString();
      if (name == null || name.isEmpty) return;
      await _tts.setVoice({
        'name': name,
        'locale': preferred['locale']?.toString() ?? 'en-US',
      });
    } catch (error) {
      debugPrint('TTS voice selection skipped: $error');
    }
  }

  void _markStopped() {
    isSpeaking = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }
}
