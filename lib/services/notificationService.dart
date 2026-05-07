import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jonssony/controller/notification_controller.dart';
import 'package:jonssony/healper/route.dart';
import 'package:jonssony/services/notification_api_service.dart';

class NotificationService {
  static final GetStorage _box = GetStorage();

  static Future<void> initialize() async {
    final messaging = FirebaseMessaging.instance;

    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('Notification Permission: ${settings.authorizationStatus}');

    final token = await messaging.getToken();
    debugPrint('FCM TOKEN: $token');
    await registerFcmToken(token);

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      debugPrint('FCM TOKEN refreshed: $newToken');
      await registerFcmToken(newToken);
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Foreground Message: ${message.toMap()}');

      final title =
          message.notification?.title ?? message.data['title'] ?? 'New Notification';
      final body = message.notification?.body ?? message.data['body'] ?? '';
      final id =
          message.data['notificationId']?.toString() ??
          message.data['_id']?.toString() ??
          message.messageId;

      try {
        final notifController = Get.find<NotificationController>();
        notifController.addNotification(id: id, title: title, body: body);

        Get.snackbar(
          title,
          body,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.white,
          colorText: Colors.black,
          boxShadows: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
            ),
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
        debugPrint('Error in Foreground Handler: $e');
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageClick);
  }

  static void _handleMessageClick(RemoteMessage message) {
    debugPrint('User Clicked Notification: ${message.data}');

    if (Get.isRegistered<NotificationController>()) {
      final notifController = Get.find<NotificationController>();
      notifController.reloadFromStorage();
      notifController.markAllAsRead();
    }

    Get.toNamed(RouteHelper.notifications);
  }

  static Future<void> registerCurrentDeviceToken() async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    await registerFcmToken(fcmToken);
  }

  static Future<void> registerFcmToken(String? fcmToken) async {
    final authToken = _box.read<String>('auth_token');
    if (authToken == null ||
        authToken.isEmpty ||
        fcmToken == null ||
        fcmToken.isEmpty) {
      return;
    }

    try {
      final result = await NotificationApiService.registerFcmToken(
        token: authToken,
        fcmToken: fcmToken,
      );
      if (result['success'] == true) {
        await _box.write('registered_fcm_token', fcmToken);
      } else {
        debugPrint(
          'FCM token registration failed: ${result['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      debugPrint('FCM token registration error: $e');
    }
  }
}
