import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jonssony/controller/auth_controller.dart';
import 'package:jonssony/firebase_options.dart';
import 'package:jonssony/healper/route.dart';
import 'package:jonssony/utils/app_constant.dart';
import 'package:jonssony/controller/profile_controller.dart';
import 'package:jonssony/controller/onboarding_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase — must be done before using Auth, Firestore, etc.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await dotenv.load(fileName: ".env");

  // Initialize Stripe
  if (AppConstants.Publishable_key.isNotEmpty && AppConstants.Publishable_key != 'pk_test_your_key_here') {
    try {
      Stripe.publishableKey = AppConstants.Publishable_key;
      await Stripe.instance.applySettings();
    } catch (e) {
      debugPrint("Stripe initialization failed: $e");
    }
  } else {
    debugPrint("Stripe Publishable Key is missing or invalid. Please check your .env file.");
  }

  await GetStorage.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: RouteHelper.splash,
      initialBinding: BindingsBuilder(() {
        Get.put(AuthController());
        Get.put(ProfileController());
        Get.put(OnboardingController());
      }),
      getPages: RouteHelper.routes,
      theme: ThemeData(fontFamily: 'Regular'),
    );
  }
}