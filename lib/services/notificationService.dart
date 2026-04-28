import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jonssony/controller/notification_controller.dart';
import 'package:jonssony/healper/route.dart';

class NotificationService {
  static Future<void> initialize() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('🔐 Notification Permission: ${settings.authorizationStatus}');


    String? token = await messaging.getToken();
    debugPrint("📱 FCM TOKEN: $token");



    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("📩 Foreground Message: ${message.toMap()}");

      final title = message.notification?.title ?? message.data['title'] ?? 'New Notification';
      final body = message.notification?.body ?? message.data['body'] ?? '';

      try {

        final notifController = Get.find<NotificationController>();
        notifController.addNotification(
          title: title,
          body: body,
        );


        Get.snackbar(
          title,
          body,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.white,
          colorText: Colors.black,
          boxShadows: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)
          ],
          margin: const EdgeInsets.all(10),
          duration: const Duration(seconds: 4),
          onTap: (_) {
            if (Get.isRegistered<NotificationController>()) {
              final controller = Get.find<NotificationController>();
              controller.reloadFromStorage();
              controller.markAllAsRead();
            }
            Get.toNamed(RouteHelper.notifications);
          },
        );
      } catch (e) {
        debugPrint("❌ Error in Foreground Handler: $e");
      }
    });


    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleMessageClick(message);
    });
  }


  static void _handleMessageClick(RemoteMessage message) {
    debugPrint("👉 User Clicked Notification: ${message.data}");
    

    if (Get.isRegistered<NotificationController>()) {
      final notifController = Get.find<NotificationController>();
      notifController.reloadFromStorage();
      notifController.markAllAsRead();
    }
    
    Get.toNamed(RouteHelper.notifications);
  }
}