import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jonssony/controller/notification_controller.dart';

class NotificationService {
  static Future<void> initialize() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Request permission
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('🔐 Permission: ${settings.authorizationStatus}');

    // Get token
    String? token = await messaging.getToken();
    debugPrint("📱 FCM TOKEN: $token");

    // Foreground message
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("📩 Foreground Message: ${message.toMap()}");
      
      final title = message.notification?.title ?? message.data['title'] ?? 'New Notification';
      final body = message.notification?.body ?? message.data['body'] ?? '';
      
      // Save to NotificationController
      try {
        final notifController = Get.find<NotificationController>();
        notifController.addNotification(
          title: title,
          body: body,
        );
      } catch (e) {
        debugPrint("Failed to find NotificationController: $e");
      }
    });

    // App opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("👉 Notification Clicked!");
    });
  }
}