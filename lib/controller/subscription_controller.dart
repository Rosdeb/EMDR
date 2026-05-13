import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jonssony/controller/auth_controller.dart';
import 'package:jonssony/services/subscription_service.dart';

class SubscriptionController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();

  final RxBool isLoadingPlans = false.obs;
  final RxBool isLoadingMySubscription = false.obs;
  final RxBool isSubscribing = false.obs;

  final RxList<dynamic> plans = [].obs;
  final RxMap<String, dynamic> mySubscription = <String, dynamic>{}.obs;
  final Rx<Map<String, dynamic>?> selectedPlanForCheckout =
      Rx<Map<String, dynamic>?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchPlans();
    if (_authController.isLoggedIn) {
      fetchMySubscription();
    }
  }

  Future<void> fetchPlans() async {
    isLoadingPlans.value = true;
    try {
      // If token is null, this will still get plans since it might not be protected
      // or user might not be fully logged in. Adjust based on API requirements.
      final result = await SubscriptionService.getPlans(_authController.token);
      if (result['success'] == true) {
        plans.value = result['data'] ?? [];
      } else {
        Get.snackbar(
          "Error",
          result['message'] ?? "Failed to load plans",
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Network error while loading plans.",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoadingPlans.value = false;
    }
  }

  Future<void> fetchMySubscription() async {
    final token = _authController.token;
    if (token == null) return;

    isLoadingMySubscription.value = true;
    try {
      final result = await SubscriptionService.getMySubscription(token);
      if (result['success'] == true) {
        mySubscription.value = result['data'] ?? {};
      }
    } catch (e) {
      print("Error fetching my subscription: $e");
    } finally {
      isLoadingMySubscription.value = false;
    }
  }

  Future<bool> subscribe(Map<String, dynamic> plan, {String? paymentId}) async {
    final token = _authController.token;
    final planId = plan['_id'];

    if (token == null) {
      Get.snackbar("Login Required", "Please log in to subscribe.");
      return false;
    }

    if (planId == null) {
      Get.snackbar("Error", "Invalid plan selected.");
      return false;
    }

    isSubscribing.value = true;
    try {
      Map<String, dynamic> result;
      // Free plans must go through the apply endpoint; paid plans subscribe
      // after payment confirmation.
      bool isFreePrice =
          plan['price'] == 0 ||
          plan['price'] == "0" ||
          plan['price']?.toString().toLowerCase() == "free";

      if (isFreePrice) {
        result = await SubscriptionService.applyForCommunityAccess(
          token,
          planId,
        );
      } else {
        result = await SubscriptionService.subscribe(
          token,
          planId,
          paymentId: paymentId,
        );
      }

      if (result['success'] == true) {
        bool isFree =
            plan['price'] == 0 ||
            plan['price'] == "0" ||
            plan['price']?.toString().toLowerCase() == "free";

        Get.snackbar(
          "Success",
          isFree
              ? "Application submitted successfully."
              : "Subscribed successfully.",
          backgroundColor: const Color(0xFF4F7957).withOpacity(0.7),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        fetchMySubscription(); // Refresh current subscription
        return true;
      } else {
        Get.snackbar(
          "Error",
          result['message'] ?? "Operation failed.",
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Network error. Please try again.",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isSubscribing.value = false;
    }
  }
}
