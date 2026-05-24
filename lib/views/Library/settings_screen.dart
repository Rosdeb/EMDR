import 'package:flutter/material.dart';
import 'package:jonssony/views/sessions/session_bilateral_simulation.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SessionBilateralSimulation(
      showSaveSettings: true,
      showBeginSession: false,
      backTitle: 'Bilateral Settings',
    );
  }
}
