import 'dart:async';
import 'package:flutter/material.dart';

enum BlsEndpoint { left, right }

class EndpointEvent {
  final BlsEndpoint endpoint;
  EndpointEvent(this.endpoint);
}

class BilateralAnimationController {
  final AnimationController _controller;
  late final Animation<double> _mappedAnimation;
  final StreamController<EndpointEvent> _endpointStreamController = StreamController<EndpointEvent>.broadcast();
  
  bool _leftPlayed = false;
  bool _rightPlayed = false;
  bool _isPaused = false;
  double _savedValue = 0.0;
  bool _savedIsReversing = false;
  
  BilateralAnimationController({required TickerProvider vsync, required Duration halfCycleDuration})
      : _controller = AnimationController(duration: halfCycleDuration, vsync: vsync) {
    _mappedAnimation = Tween<double>(begin: -1.0, end: 1.0).animate(_controller);
    _controller.addListener(_onTick);
  }

  Stream<EndpointEvent> get endpointStream => _endpointStreamController.stream;
  Animation<double> get animation => _mappedAnimation;
  double get value => _controller.value;
  bool get isPaused => _isPaused;

  void _onTick() {
    final val = _controller.value;
    if (val >= 0.995 && !_rightPlayed) {
      _rightPlayed = true;
      _leftPlayed = false;
      _endpointStreamController.add(EndpointEvent(BlsEndpoint.right));
      _scheduleReverse();
    } else if (val <= 0.005 && !_leftPlayed) {
      _leftPlayed = true;
      _rightPlayed = false;
      _endpointStreamController.add(EndpointEvent(BlsEndpoint.left));
      _scheduleForward();
    }
  }

  void _scheduleReverse() async {
    if (_isPaused) return;
    final ms = _controller.duration!.inMilliseconds;
    int pauseMs = _getPauseDuration(ms);
    if (pauseMs > 0) {
      await Future.delayed(Duration(milliseconds: pauseMs));
    }
    if (!_isPaused) {
      _leftPlayed = false;
      _controller.reverse();
    }
  }

  void _scheduleForward() async {
    if (_isPaused) return;
    final ms = _controller.duration!.inMilliseconds;
    int pauseMs = _getPauseDuration(ms);
    if (pauseMs > 0) {
      await Future.delayed(Duration(milliseconds: pauseMs));
    }
    if (!_isPaused) {
      _rightPlayed = false;
      _controller.forward();
    }
  }

  int _getPauseDuration(int halfCycleMs) {
    if (halfCycleMs <= 250) return 0;
    if (halfCycleMs <= 450) return 0;
    if (halfCycleMs <= 700) return 10;
    return 116;
  }

  void start() {
    _isPaused = false;
    _leftPlayed = false;
    _rightPlayed = false;
    _controller.value = 0.0;
    _controller.forward();
  }

  void pause() {
    if (_isPaused) return;
    _isPaused = true;
    _savedValue = _controller.value;
    _savedIsReversing = _controller.status == AnimationStatus.reverse;
    _controller.stop();
  }

  void resume() {
    if (!_isPaused) return;
    _isPaused = false;
    if (_savedIsReversing) {
      _controller.reverse(from: _savedValue);
    } else {
      _controller.forward(from: _savedValue);
    }
  }

  void stop() {
    _isPaused = true;
    _controller.stop();
  }

  void dispose() {
    _endpointStreamController.close();
    _controller.dispose();
  }
}
