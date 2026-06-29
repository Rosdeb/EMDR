import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jonssony/core/network/network_controller.dart';

class OfflinePage extends StatelessWidget {
  const OfflinePage({super.key});

  @override
  Widget build(BuildContext context) {
    final network = Get.find<NetworkController>();
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/images/home_bg1.jpg', fit: BoxFit.cover),
            Container(color: Colors.black.withValues(alpha: 0.58)),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(28),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 440),
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.94),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.cloud_off_rounded,
                          size: 72,
                          color: Color(0xFF537E5D),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'You are offline',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF151515),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Check your Wi-Fi or mobile data. This page will close automatically when your connection returns.',
                          textAlign: TextAlign.center,
                          style: TextStyle(height: 1.5, color: Colors.black54),
                        ),
                        const SizedBox(height: 24),
                        Obx(
                          () => SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: network.isOffline.value
                                  ? network.checkNow
                                  : null,
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('Try again'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF537E5D),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
