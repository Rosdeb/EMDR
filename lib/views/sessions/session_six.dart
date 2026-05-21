import 'package:flutter/material.dart';
import 'package:jonssony/views/sessions/session_bilateral_simulation.dart';

class SessionSix extends StatelessWidget {
  const SessionSix({super.key});

  @override
  Widget build(BuildContext context) {
    return const SessionBilateralSimulation(
      showSaveSettings: false,
      showBeginSession: true,
      backTitle: 'Session 6',
    );
  }
}
