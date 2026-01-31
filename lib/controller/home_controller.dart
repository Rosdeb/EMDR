import 'package:get/get.dart';

class HomeController extends GetxController {
  // Reactive variable (.obs mane holo eti observe kora jabe)
  var userName = "Shuvo Paul".obs;
  var isLoading = false.obs;
  var progress = 0.95.obs;

  void fetchUserData() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 2)); // Mock API delay
    userName.value = "Updated Shuvo";
    isLoading.value = false;
  }
}