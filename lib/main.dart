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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase — must be done before using Auth, Firestore, etc.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await dotenv.load(fileName: ".env");

  // Initialize Stripe
  Stripe.publishableKey = AppConstants.Publishable_key;
  await Stripe.instance.applySettings();

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
      }),
      getPages: RouteHelper.routes,
      theme: ThemeData(fontFamily: 'Regular'),
    );
  }
}