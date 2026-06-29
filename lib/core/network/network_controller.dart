import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:jonssony/healper/route.dart';

class NetworkController extends GetxService {
  NetworkController({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;
  final RxBool isOffline = false.obs;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  Completer<void>? _onlineCompleter;
  bool _offlineRouteScheduled = false;

  @override
  void onInit() {
    super.onInit();
    _subscription = _connectivity.onConnectivityChanged.listen(
      _handleConnectivity,
    );
    unawaited(checkNow());
  }

  Future<bool> checkNow() async {
    try {
      final results = await _connectivity.checkConnectivity();
      final online = _hasConnection(results);
      if (online) {
        markOnline();
      } else {
        markOffline();
      }
      return online;
    } catch (error) {
      debugPrint('Connectivity check failed: $error');
      return !isOffline.value;
    }
  }

  void _handleConnectivity(List<ConnectivityResult> results) {
    if (_hasConnection(results)) {
      markOnline();
    } else {
      markOffline();
    }
  }

  bool _hasConnection(List<ConnectivityResult> results) {
    return results.isNotEmpty &&
        results.any((result) => result != ConnectivityResult.none);
  }

  void markOffline() {
    if (!isOffline.value) {
      isOffline.value = true;
      _onlineCompleter ??= Completer<void>();
    }
    _showOfflineRoute();
  }

  void markOnline() {
    final wasOffline = isOffline.value;
    isOffline.value = false;
    final completer = _onlineCompleter;
    _onlineCompleter = null;
    if (completer != null && !completer.isCompleted) completer.complete();

    if (wasOffline && Get.currentRoute == RouteHelper.offline) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Get.currentRoute == RouteHelper.offline &&
            Get.key.currentState != null) {
          Get.back(result: true);
        }
      });
    }
  }

  Future<void> waitUntilOnline() {
    if (!isOffline.value) return Future<void>.value();
    _onlineCompleter ??= Completer<void>();
    return _onlineCompleter!.future;
  }

  void _showOfflineRoute() {
    if (_offlineRouteScheduled || Get.currentRoute == RouteHelper.offline) {
      return;
    }
    _offlineRouteScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _offlineRouteScheduled = false;
      if (!isOffline.value ||
          Get.currentRoute == RouteHelper.offline ||
          Get.key.currentState == null) {
        return;
      }
      Get.toNamed(RouteHelper.offline);
    });
  }

  @override
  void onClose() {
    unawaited(_subscription?.cancel());
    super.onClose();
  }
}
