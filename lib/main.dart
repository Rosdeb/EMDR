import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:jonssony/controller/auth_controller.dart';
import 'package:jonssony/controller/onboarding_controller.dart';
import 'package:jonssony/controller/profile_controller.dart';
import 'package:jonssony/controller/static_content_controller.dart';
import 'package:jonssony/controller/subscription_controller.dart';
import 'package:jonssony/controller/support_controller.dart';
import 'package:jonssony/controller/home_controller.dart';
import 'package:jonssony/controller/navigation_controller.dart';
import 'package:jonssony/controller/NotificationController/notification_controller.dart';
import 'package:jonssony/controller/bilateral_controller.dart';
import 'package:jonssony/controller/media_controller.dart';
import 'package:jonssony/controller/category_controller.dart';
import 'package:jonssony/controller/journey_controller.dart';
import 'package:jonssony/controller/my_tests_controller.dart';
import 'package:jonssony/firebase_options.dart';
import 'package:jonssony/healper/route.dart';
import 'package:jonssony/services/notificationService.dart';
import 'package:jonssony/utils/app_constant.dart';

// Background message handler (Top-level)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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
    'title':
        message.notification?.title ??
        message.data['title'] ??
        'New Notification',
    'body': message.notification?.body ?? message.data['body'] ?? '',
    'receivedAt': DateTime.now().toIso8601String(),
    'isRead': false,
  });

  await box.write('app_notifications', jsonEncode(list));
  debugPrint('🔔 Background Notification Saved: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Firebase initialize
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Register background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Load env
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Error loading .env file: $e");
  }

  // Stripe setup
  Stripe.publishableKey = AppConstants.Publishable_key;
  await Stripe.instance.applySettings();

  // Local storage
  await GetStorage.init();

  // Register essential controllers and initialize notifications
  Get.put(NotificationController(), permanent: true);

  // don't wait for permission
  Future.microtask(()async{
    await NotificationService.initialize();
  });
  //await NotificationService.initialize();

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
    _checkInitialMessage();
  }

  void _checkInitialMessage() async {
    RemoteMessage? initialMessage = await FirebaseMessaging.instance
        .getInitialMessage();
    if (initialMessage != null) {
      debugPrint('Notification clicked from terminated state and app opened!');
      // Short delay to ensure GetMaterialApp has fully initialized navigation
      Future.delayed(const Duration(milliseconds: 500), () {
        Get.toNamed(RouteHelper.notifications);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: RouteHelper.splash,
      initialBinding: BindingsBuilder(() {
        Get.put(AuthController(), permanent: true);
        Get.lazyPut(() => OnboardingController(), fenix: true);
        Get.lazyPut(() => ProfileController(), fenix: true);
        Get.lazyPut(() => StaticContentController(), fenix: true);
        Get.lazyPut(() => SubscriptionController(), fenix: true);
        Get.lazyPut(() => SupportController(), fenix: true);
        Get.lazyPut(() => HomeController(), fenix: true);
        Get.lazyPut(() => NavigationController(), fenix: true);
        Get.lazyPut(() => BilateralController(), fenix: true);
        Get.lazyPut(() => MediaController(), fenix: true);
        Get.lazyPut(() => CategoryController(), fenix: true);
        Get.lazyPut(() => JourneyController(), fenix: true);
        Get.lazyPut(() => MyTestsController(), fenix: true);
      }),
      getPages: RouteHelper.routes,
      theme: ThemeData(fontFamily: 'Regular', useMaterial3: true),
    );
  }
}
