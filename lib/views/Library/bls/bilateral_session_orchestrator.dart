import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:jonssony/views/Library/bls/bilateral_animation_controller.dart';

class BilateralSessionOrchestrator extends ChangeNotifier {
  final int totalSets;
  final Duration sessionLimit;
  final Duration setDuration;
  final BilateralAnimationController animationController;
  
  Timer? _sessionTimer;
  Timer? _setTimer;
  
  int moveCount = 0;
  bool visitedRightThisSet = false;
  Duration processingElapsed = Duration.zero;
  Duration remainingSetTime;
  
  bool setComplete = false;
  bool sessionComplete = false;
  bool isPaused = false;
  bool motionStarted = false;

  final VoidCallback onSetComplete;
  final VoidCallback onSessionComplete;

  BilateralSessionOrchestrator({
    required this.totalSets,
    required this.sessionLimit,
    required this.setDuration,
    required this.animationController,
    required this.onSetComplete,
    required this.onSessionComplete,
  }) : remainingSetTime = setDuration {
    animationController.endpointStream.listen(_onEndpointReached);
  }

  void _onEndpointReached(EndpointEvent event) {
    if (!motionStarted || setComplete || isPaused) return;
    if (totalSets <= 0) return;

    if (event.endpoint == BlsEndpoint.right) {
      visitedRightThisSet = true;
      return;
    }

    if (!visitedRightThisSet) return;
    visitedRightThisSet = false;
    _registerCompletedSet();
  }

  void _registerCompletedSet() {
    if (setComplete || isPaused) return;
    if (moveCount >= totalSets) {
      _completeSet();
      return;
    }

    moveCount++;
    if (totalSets > 0) {
      final stepMs = animationController.animation.isDismissed ? 0 : 0; // Wait, we just calculate from setDuration if not based on moves
      // The original code did: stepMs = fullCycleMs, remainingMs = setDuration - (stepMs * moveCount)
      // Actually we just let it go up to totalSets.
    }
    notifyListeners();

    if (moveCount >= totalSets) {
      _completeSet();
    }
  }

  void startSessionTimer() {
    _sessionTimer?.cancel();
    if (sessionLimit == Duration.zero) return;

    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (setComplete || sessionComplete) return;
      if (!motionStarted || isPaused) return;

      processingElapsed += const Duration(seconds: 1);
      notifyListeners();

      if (processingElapsed >= sessionLimit) {
        _completeByTimeLimit();
      }
    });
  }

  void startSetTimer() {
    _setTimer?.cancel();
    if (setComplete || isPaused) return;

    if (totalSets > 0) return; // Based on moves

    _setTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSetTime.inSeconds <= 1) {
        _completeSet();
        return;
      }
      remainingSetTime -= const Duration(seconds: 1);
      notifyListeners();
    });
  }

  void _completeSet() {
    if (setComplete) return;
    _setTimer?.cancel();
    motionStarted = false;
    setComplete = true;
    isPaused = true;
    remainingSetTime = Duration.zero;
    notifyListeners();
    onSetComplete();
  }

  void _completeByTimeLimit() {
    if (sessionComplete) return;
    _setTimer?.cancel();
    motionStarted = false;
    setComplete = true;
    sessionComplete = true;
    isPaused = true;
    remainingSetTime = Duration.zero;
    notifyListeners();
    onSessionComplete();
  }

  void pause() {
    isPaused = true;
    _setTimer?.cancel();
    notifyListeners();
  }

  void resume() {
    isPaused = false;
    startSetTimer();
    notifyListeners();
  }

  void restartSet() {
    setComplete = false;
    isPaused = false;
    motionStarted = false;
    moveCount = 0;
    visitedRightThisSet = false;
    remainingSetTime = setDuration;
    notifyListeners();
  }

  Duration get sessionRemaining {
    if (sessionLimit == Duration.zero) return Duration.zero;
    final remaining = sessionLimit - processingElapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  void dispose() {
    _sessionTimer?.cancel();
    _setTimer?.cancel();
    super.dispose();
  }
}
