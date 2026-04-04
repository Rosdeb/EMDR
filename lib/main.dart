import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jonssony/healper/route.dart';
import 'package:jonssony/controller/auth_controller.dart';

Future<void> main() async {
  runApp(const MyApp());
  await GetStorage.init();
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