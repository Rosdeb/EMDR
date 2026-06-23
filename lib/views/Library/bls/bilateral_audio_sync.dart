import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:jonssony/data/bls_tone_profiles.dart';
import 'package:jonssony/data/bls_built_in_sounds.dart';

class BilateralAudioSync {
  AudioPlayer _continuousPlayer = AudioPlayer();
  AudioPlayer _leftPulsePlayer = AudioPlayer();
  AudioPlayer _rightPulsePlayer = AudioPlayer();
  
  String _cachedNetworkAudioPath = '';
  final Map<String, Uint8List> _toneCache = {};

  bool _isContinuous = false;

  Future<void> initPlayers({
    required String soundKey,
    required String audioAsset,
  }) async {
    try {
      await _leftPulsePlayer.dispose();
      await _rightPulsePlayer.dispose();
      await _continuousPlayer.dispose();
    } catch (_) {}

    _leftPulsePlayer = AudioPlayer();
    _rightPulsePlayer = AudioPlayer();
    _continuousPlayer = AudioPlayer();

    await _leftPulsePlayer.setVolume(1);
    await _rightPulsePlayer.setVolume(1);
    await _leftPulsePlayer.setBalance(-1);
    await _rightPulsePlayer.setBalance(1);
    await _leftPulsePlayer.setReleaseMode(ReleaseMode.stop);
    await _rightPulsePlayer.setReleaseMode(ReleaseMode.stop);

    final profile = _resolveToneProfile(soundKey, audioAsset);
    if (profile != null) {
      _isContinuous = false;
      await _leftPulsePlayer.setPlayerMode(PlayerMode.lowLatency);
      await _rightPulsePlayer.setPlayerMode(PlayerMode.lowLatency);
      
      final leftBytes = _toneBytes(profile: profile, isRight: false, key: soundKey);
      final rightBytes = _toneBytes(profile: profile, isRight: true, key: soundKey);
      await _leftPulsePlayer.setSourceBytes(leftBytes, mimeType: 'audio/wav');
      await _rightPulsePlayer.setSourceBytes(rightBytes, mimeType: 'audio/wav');
    } else if (audioAsset.isNotEmpty) {
      _isContinuous = true;
      await _leftPulsePlayer.setPlayerMode(PlayerMode.mediaPlayer);
      await _rightPulsePlayer.setPlayerMode(PlayerMode.mediaPlayer);
      if (_isNetworkUrl(audioAsset)) {
        try {
          final response = await http.get(Uri.parse(audioAsset));
          if (response.statusCode == 200) {
            final tempDir = await getTemporaryDirectory();
            final file = File('${tempDir.path}/cached_bls_audio.mp3');
            await file.writeAsBytes(response.bodyBytes);
            _cachedNetworkAudioPath = file.path;
            
            await _leftPulsePlayer.setSource(DeviceFileSource(_cachedNetworkAudioPath));
            await _rightPulsePlayer.setSource(DeviceFileSource(_cachedNetworkAudioPath));
            
            await _continuousPlayer.setSource(DeviceFileSource(_cachedNetworkAudioPath));
          } else {
            await _leftPulsePlayer.setSource(UrlSource(audioAsset));
            await _rightPulsePlayer.setSource(UrlSource(audioAsset));
            await _continuousPlayer.setSource(UrlSource(audioAsset));
          }
        } catch (_) {
          await _leftPulsePlayer.setSource(UrlSource(audioAsset));
          await _rightPulsePlayer.setSource(UrlSource(audioAsset));
          await _continuousPlayer.setSource(UrlSource(audioAsset));
        }
      } else {
        var assetPath = audioAsset.startsWith('assets/') ? audioAsset.substring(7) : audioAsset;
        await _leftPulsePlayer.setSource(AssetSource(assetPath));
        await _rightPulsePlayer.setSource(AssetSource(assetPath));
        await _continuousPlayer.setSource(AssetSource(assetPath));
      }
      await _continuousPlayer.setReleaseMode(ReleaseMode.loop);
    }
  }

  Future<void> playEndpoint({required bool isRight, required double speedSeconds}) async {
    final player = isRight ? _rightPulsePlayer : _leftPulsePlayer;
    try {
      await player.stop();
      
      double rate;
      if (speedSeconds <= 0.3) {
        rate = 1.5;
      } else if (speedSeconds <= 0.5) {
        rate = 0.85;
      } else {
        rate = 0.65;
      }
      await player.setPlaybackRate(rate);

      if (_isContinuous) {
        await player.setVolume(1);
        await player.setBalance(isRight ? 1 : -1);
        int offsetMs = isRight ? 500 : 0;
        await player.seek(Duration(milliseconds: offsetMs));
        await player.resume();
        
        int waitMs = (450 / rate).round();
        Future.delayed(Duration(milliseconds: waitMs), () async {
          if (player.state == PlayerState.playing) {
            await player.stop();
          }
        });
      } else {
        await player.resume();
      }
    } catch (e) {
      debugPrint('Endpoint audio error: $e');
    }
  }

  Future<void> startContinuous() async {
    if (_isContinuous) {
      try {
        await _continuousPlayer.resume();
      } catch (e) {
        debugPrint("Continuous Audio Error: $e");
      }
    }
  }

  void updateContinuousBalance(double balance) {
    if (_isContinuous) {
      _continuousPlayer.setBalance(balance);
    }
  }

  void pause() {
    _continuousPlayer.pause();
    _leftPulsePlayer.stop();
    _rightPulsePlayer.stop();
  }

  void resume() {
    if (_isContinuous) {
      _continuousPlayer.resume();
    }
  }

  void stop() {
    _continuousPlayer.stop();
    _leftPulsePlayer.stop();
    _rightPulsePlayer.stop();
  }

  void dispose() {
    _continuousPlayer.dispose();
    _leftPulsePlayer.dispose();
    _rightPulsePlayer.dispose();
  }

  BlsToneProfile? _resolveToneProfile(String soundKey, String audioAsset) {
    if (soundKey.isEmpty || soundKey == 'none') return null;
    final normalized = BlsBuiltInSounds.normalizeKey(soundKey);
    
    if (audioAsset.isNotEmpty && !kBlsToneProfiles.containsKey(normalized)) {
      return null;
    }
    return kBlsToneProfiles[normalized] ?? kBlsToneProfiles[BlsBuiltInSounds.defaultKey];
  }

  Uint8List _toneBytes({required BlsToneProfile profile, required bool isRight, required String key}) {
    final cacheKey = '$key-${isRight ? 'right' : 'left'}';
    return _toneCache.putIfAbsent(cacheKey, () => buildBlsToneWav(profile: profile, isRight: isRight));
  }

  bool _isNetworkUrl(String value) {
    final uri = Uri.tryParse(value.trim());
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https') && uri.host.isNotEmpty;
  }
}
