import 'dart:math' as math;
import 'dart:typed_data';

import 'package:jonssony/data/bls_built_in_sounds.dart';

class BlsToneProfile {
  const BlsToneProfile(
    this.leftFrequency,
    this.rightFrequency,
    this.attackSeconds,
    this.decaySeconds,
    this.volume,
  );

  final double leftFrequency;
  final double rightFrequency;
  final double attackSeconds;
  final double decaySeconds;
  final double volume;
}

const Map<String, BlsToneProfile> kBlsToneProfiles = {
  'gentle-tone': BlsToneProfile(432, 528, 0.04, 0.25, 0.06),
  'soft-chime': BlsToneProfile(660, 880, 0.01, 0.45, 0.05),
  'water': BlsToneProfile(340, 400, 0.02, 0.2, 0.055),
  'breath': BlsToneProfile(180, 180, 0.15, 0.45, 0.06),
  'bowl': BlsToneProfile(396, 528, 0.05, 0.8, 0.05),
  'warm-tap': BlsToneProfile(220, 275, 0.008, 0.16, 0.07),
  'deep-pulse': BlsToneProfile(120, 136, 0.02, 0.22, 0.07),
  'rain-bell': BlsToneProfile(520, 620, 0.012, 0.26, 0.055),
};

BlsToneProfile? resolveBlsToneProfile(String soundKey) {
  final key = BlsBuiltInSounds.normalizeKey(soundKey);
  if (key.isEmpty || key == 'none') return null;
  return kBlsToneProfiles[key] ?? kBlsToneProfiles[BlsBuiltInSounds.defaultKey];
}

Uint8List buildBlsToneWav({
  required BlsToneProfile profile,
  required bool isRight,
}) {
  final frequency = isRight ? profile.rightFrequency : profile.leftFrequency;
  return _buildToneWav(
    frequency: frequency,
    attackSeconds: profile.attackSeconds,
    decaySeconds: profile.decaySeconds,
    volume: profile.volume,
    isRight: isRight,
  );
}

Uint8List _buildToneWav({
  required double frequency,
  required double attackSeconds,
  required double decaySeconds,
  required double volume,
  required bool isRight,
}) {
  const sampleRate = 44100;
  const channels = 2;
  const bitsPerSample = 16;
  final durationSeconds = math.max(decaySeconds, attackSeconds + 0.05) + 0.05;
  final sampleCount = (sampleRate * durationSeconds).ceil();
  final dataSize = sampleCount * channels * (bitsPerSample ~/ 8);
  final bytes = ByteData(44 + dataSize);

  void writeAscii(int offset, String value) {
    for (var i = 0; i < value.length; i++) {
      bytes.setUint8(offset + i, value.codeUnitAt(i));
    }
  }

  writeAscii(0, 'RIFF');
  bytes.setUint32(4, 36 + dataSize, Endian.little);
  writeAscii(8, 'WAVE');
  writeAscii(12, 'fmt ');
  bytes.setUint32(16, 16, Endian.little);
  bytes.setUint16(20, 1, Endian.little);
  bytes.setUint16(22, channels, Endian.little);
  bytes.setUint32(24, sampleRate, Endian.little);
  bytes.setUint32(
    28,
    sampleRate * channels * (bitsPerSample ~/ 8),
    Endian.little,
  );
  bytes.setUint16(32, channels * (bitsPerSample ~/ 8), Endian.little);
  bytes.setUint16(34, bitsPerSample, Endian.little);
  writeAscii(36, 'data');
  bytes.setUint32(40, dataSize, Endian.little);

  final decayWindow = math.max(decaySeconds - attackSeconds, 0.001);
  for (var i = 0; i < sampleCount; i++) {
    final t = i / sampleRate;
    final envelope = t < attackSeconds
        ? (attackSeconds <= 0 ? 1.0 : t / attackSeconds)
        : t < decaySeconds
        ? 1.0 - ((t - attackSeconds) / decayWindow)
        : 0.0;
    final value = math.sin(2 * math.pi * frequency * t) * volume * envelope;
    final sample = (value * 32767).clamp(-32768, 32767).round();
    final oppositeSample = (sample * 0.12).round();
    final frameOffset = 44 + (i * channels * 2);
    bytes.setInt16(
      frameOffset,
      isRight ? oppositeSample : sample,
      Endian.little,
    );
    bytes.setInt16(
      frameOffset + 2,
      isRight ? sample : oppositeSample,
      Endian.little,
    );
  }

  return bytes.buffer.asUint8List();
}
