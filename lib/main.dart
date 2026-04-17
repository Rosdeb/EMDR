import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:jonssony/controller/auth_controller.dart';
import 'package:jonssony/controller/notification_controller.dart';
import 'package:jonssony/firebase_options.dart';
import 'package:jonssony/healper/route.dart';
import 'package:jonssony/services/notificationService.dart';
import 'package:jonssony/utils/app_constant.dart';

/// 🔥 Background message handler (top-level, required by FCM)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // সরাসরি GetStorage ব্যবহার করে ব্যাকগ্রাউন্ডে নোটিফিকেশন সেভ করা
  await GetStorage.init();
  final box = GetStorage();
  final String? raw = box.read('app_notifications');
  List<dynamic> list = [];
  if (raw != null) {
    try {
      list = jsonDecode(raw);
    } catch (e) {
      list = [];
    }
  }

  list.insert(0, {
    'id': DateTime.now().millisecondsSinceEpoch.toString(),
    'title': message.notification?.title ?? message.data['title'] ?? 'New Notification',
    'body': message.notification?.body ?? message.data['body'] ?? '',
    'receivedAt': DateTime.now().toIso8601String(),
    'isRead': false,
  });

  await box.write('app_notifications', jsonEncode(list));
  debugPrint('🔔 Background Notification Saved: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Firebase initialize (once)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ✅ Register background handler before any other FCM call
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // ✅ Load env
  await dotenv.load(fileName: ".env");

  // ✅ Stripe setup
  Stripe.publishableKey = AppConstants.Publishable_key;
  await Stripe.instance.applySettings();

  // ✅ Local storage
  await GetStorage.init();

  // ✅ Register controllers and initialize notifications
  Get.put(NotificationController(), permanent: true);
  await NotificationService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: RouteHelper.splash,
      initialBinding: BindingsBuilder(() {
        Get.put(AuthController());
      }),
      getPages: RouteHelper.routes,
      theme: ThemeData(fontFamily: 'Regular'),
    );
  }
}