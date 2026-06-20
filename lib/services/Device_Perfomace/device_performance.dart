import 'dart:ffi';

import 'package:flutter/material.dart';
import 'dart:io';

enum DevicePerformanceTier { high, medium, low }

class DevicePerformance {
  static DevicePerformanceTier? _cachedTier;

  /// ডিভাইসের পারফরম্যান্স টিয়ার ডিটেক্ট করে
  static DevicePerformanceTier get tier {
    if (_cachedTier != null) return _cachedTier!;

    final processorCount = Platform.numberOfProcessors;
    final totalMemoryMB = _getTotalMemoryMB();
    final is64Bit = _is64BitDevice();

    // হার্ডওয়্যার ক্যাপাবিলিটি অনুযায়ী স্কোরিং
    int score = 0;

    // প্রসেসর কোর
    if (processorCount >= 8) {
      score += 3;
    } else if (processorCount >= 6) {
      score += 2;
    } else if (processorCount >= 4) {
      score += 1;
    }

    // RAM
    if (totalMemoryMB >= 8192) {
      score += 3;
    } else if (totalMemoryMB >= 6144) {
      score += 2;
    } else if (totalMemoryMB >= 4096) {
      score += 1;
    }

    // 64-bit ডিভাইস
    if (is64Bit) {
      score += 1;
    }

    // স্কোর অনুযায়ী টিয়ার নির্ধারণ
    if (score >= 5) {
      _cachedTier = DevicePerformanceTier.high;
    } else if (score >= 3) {
      _cachedTier = DevicePerformanceTier.medium;
    } else {
      _cachedTier = DevicePerformanceTier.low;
    }

    debugPrint('🎮 Device Performance Analysis:');
    debugPrint('  - Processors: $processorCount');
    debugPrint('  - RAM: ${totalMemoryMB}MB');
    debugPrint('  - 64-bit: $is64Bit');
    debugPrint('  - Score: $score');
    debugPrint('  - Tier: ${_cachedTier!}');

    return _cachedTier!;
  }

  static int _getTotalMemoryMB() {
    try {
      if (Platform.isAndroid) {
        final file = File('/proc/meminfo');
        if (file.existsSync()) {
          final content = file.readAsStringSync();
          final match = RegExp(r'MemTotal:\s+(\d+)').firstMatch(content);
          if (match != null) {
            return int.parse(match.group(1)!) ~/ 1024;
          }
        }
      }
    } catch (_) {}
    return 4096; // ডিফল্ট 4GB
  }

  static bool _is64BitDevice() {
    try {
      return sizeOf<IntPtr>() == 8;
    } catch (_) {
      return true;
    }
  }

  /// ব্লার/রিফ্লেকশন ইফেক্ট ব্যবহার করবে কিনা
  static bool get shouldUseBlurEffects => tier != DevicePerformanceTier.low;

  /// ব্যাকড্রপ ফিল্টার ব্যবহার করবে কিনা
  static bool get shouldUseBackdropFilter => tier != DevicePerformanceTier.low;

  /// অবজেক্ট রিফ্লেকশন দেখাবে কিনা
  static bool get shouldShowReflection => tier != DevicePerformanceTier.low;
}