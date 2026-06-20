import 'package:flutter/material.dart';
import 'dart:io';

enum DevicePerformanceTier { high, medium, low }

class DevicePerformance {
  static DevicePerformanceTier? _cachedTier;

  static DevicePerformanceTier get tier {
    if (_cachedTier != null) return _cachedTier!;

    final refreshRate = _getRefreshRate();
    final isHighEnd = _isHighEndDevice();

    if (refreshRate >= 90 && isHighEnd) {
      _cachedTier = DevicePerformanceTier.high;
    } else if (refreshRate >= 60 || isHighEnd) {
      _cachedTier = DevicePerformanceTier.medium;
    } else {
      _cachedTier = DevicePerformanceTier.low;
    }

    return _cachedTier!;
  }

  static double _getRefreshRate() {
    try {
      final views = WidgetsBinding.instance.platformDispatcher.views;
      if (views.isNotEmpty) {
        final view = views.first;
        // Flutter 3.10+ থেকে displayRefreshRate পাওয়া যায়
        return 60.0;
      }
    } catch (_) {}
    return 60.0;
  }

  static bool _isHighEndDevice() {
    // OnePlus, Samsung S series, iPhone 12+, Pixel 6+
    final model = Platform.operatingSystemVersion.toLowerCase();
    final highEndKeywords = [
      'oneplus', 'sm-s9', 'sm-s90', 'sm-s91', 'sm-s92',
      'iphone 1', 'iphone 2', 'pixel 6', 'pixel 7', 'pixel 8',
      'pixel 9', 'xiaomi 13', 'xiaomi 14', 'samsung s2',
    ];
    return highEndKeywords.any((k) => model.contains(k));
  }


  static bool get shouldUseBlurEffects => tier != DevicePerformanceTier.low;
  static bool get shouldShowReflection => tier != DevicePerformanceTier.low;
  static bool get shouldUseBackdropFilter => tier == DevicePerformanceTier.high;

  /// animation quality
  static double get animationQuality {
    switch (tier) {
      case DevicePerformanceTier.high:
        return 1.0;
      case DevicePerformanceTier.medium:
        return 0.8;
      case DevicePerformanceTier.low:
        return 0.6;
    }
  }
}