import 'package:get/get.dart';

class HomeController extends GetxController {
  var userName = "Shuvo Paul".obs;
  var progress = 0.95.obs;

  // API integrate korle ekhane function likhben
  void updateProgress(double val) => progress.value = val;
}