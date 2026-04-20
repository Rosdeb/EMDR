import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jonssony/controller/notification_controller.dart';

class NotificationService {
  static Future<void> initialize() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // ১. নোটিফিকেশন পারমিশন রিকোয়েস্ট (Android 13+ এর জন্য)
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('🔐 Notification Permission: ${settings.authorizationStatus}');

    // ২. FCM টোকেন সংগ্রহ (এটি দিয়ে কনসোল থেকে টেস্ট করবেন)
    String? token = await messaging.getToken();
    debugPrint("📱 FCM TOKEN: $token");

    // ৩. অ্যাপ পুরোপুরি বন্ধ (Terminated) থাকা অবস্থায় নোটিফিকেশন ক্লিক করলে
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageClick(initialMessage);
    }

    // ৪. অ্যাপ সচল (Foreground) থাকা অবস্থায় নোটিফিকেশন রিসিভ করা
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("📩 Foreground Message: ${message.toMap()}");

      final title = message.notification?.title ?? message.data['title'] ?? 'New Notification';
      final body = message.notification?.body ?? message.data['body'] ?? '';

      try {
        // কন্ট্রোলারে ডাটা সেভ করা
        final notifController = Get.find<NotificationController>();
        notifController.addNotification(
          title: title,
          body: body,
        );

        // ফোরগ্রাউন্ডে ইউজারকে জানানোর জন্য স্নাকবার দেখানো
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
        );
      } catch (e) {
        debugPrint("❌ Error in Foreground Handler: $e");
      }
    });

    // ৫. অ্যাপ ব্যাকগ্রাউন্ডে থাকা অবস্থায় নোটিফিকেশন ক্লিক করলে
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleMessageClick(message);
    });
  }

  // ক্লিক হ্যান্ডেল করার ফাংশন
  static void _handleMessageClick(RemoteMessage message) {
    debugPrint("👉 User Clicked Notification: ${message.data}");
    // আপনি চাইলে এখানে নেভিগেশন যোগ করতে পারেন
    // Get.toNamed('/notification-screen');
  }
}