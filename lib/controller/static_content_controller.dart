import 'package:get/get.dart';
import 'package:jonssony/controller/auth_controller.dart';
import 'package:jonssony/services/static_content_service.dart';

class StaticContentController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();

  final RxBool isPrivacyLoading = false.obs;
  final RxBool isTermsLoading = false.obs;
  final RxBool isFaqLoading = false.obs;
  final RxBool isAboutUsLoading = false.obs;
  final RxBool isAcceptingTerms = false.obs;

  final RxMap privacyData = {}.obs;
  final RxMap termsData = {}.obs;
  final RxList faqList = [].obs;
  final RxMap aboutUsData = {}.obs;
  final RxBool isTermsAccepted = false.obs;

  final RxString privacyError = ''.obs;
  final RxString termsError = ''.obs;
  final RxString faqError = ''.obs;
  final RxString aboutUsError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Initial fetch for terms acceptance status if logged in
    if (_authController.isLoggedIn) {
      fetchTermsAcceptanceStatus();
    }
  }

  // 0. Fetch About Us
  Future<void> fetchAboutUs() async {
    isAboutUsLoading.value = true;
    aboutUsError.value = '';
    try {
      final result = await StaticContentService.getAboutUs();
      if (result['success'] == true) {
        aboutUsData.value = result['data'] ?? {};
        print('About Us Data: ${aboutUsData.value}');
      } else {
        aboutUsError.value = result['message'] ?? 'Failed to fetch About Us';
      }
    } catch (e) {
      print('Fetch About Us Error: $e');
      aboutUsError.value = 'Network error. Please try again.';
    } finally {
      isAboutUsLoading.value = false;
    }
  }

  // 1. Fetch Privacy Policy
  Future<void> fetchPrivacyPolicy() async {
    isPrivacyLoading.value = true;
    privacyError.value = '';
    try {
      final result = await StaticContentService.getPrivacyPolicy();
      if (result['success'] == true) {
        privacyData.value = result['data'] ?? {};
      } else {
        privacyError.value = result['message'] ?? 'Failed to fetch Privacy Policy';
      }
    } catch (e) {
      privacyError.value = 'Network error. Please try again.';
    } finally {
      isPrivacyLoading.value = false;
    }
  }

  // 2. Fetch Terms of Service
  Future<void> fetchTermsOfService() async {
    isTermsLoading.value = true;
    termsError.value = '';
    try {
      final result = await StaticContentService.getTermsOfService();
      if (result['success'] == true) {
        termsData.value = result['data'] ?? {};
      } else {
        termsError.value = result['message'] ?? 'Failed to fetch Terms of Service';
      }
    } catch (e) {
      termsError.value = 'Network error. Please try again.';
    } finally {
      isTermsLoading.value = false;
    }
  }

  // 2.1 Accept Terms
  Future<void> acceptTerms(String termsId) async {
    final token = _authController.token;
    if (token == null) return;

    isAcceptingTerms.value = true;
    try {
      final result = await StaticContentService.acceptTerms(token, termsId);
      if (result['success'] == true) {
        isTermsAccepted.value = true;
        Get.snackbar('Success', 'Terms accepted successfully.');
      } else {
        Get.snackbar('Error', result['message'] ?? 'Failed to accept terms.');
      }
    } catch (e) {
      Get.snackbar('Error', 'Network error. Please try again.');
    } finally {
      isAcceptingTerms.value = false;
    }
  }

  // 2.2 Fetch Acceptance Status
  Future<void> fetchTermsAcceptanceStatus() async {
    final token = _authController.token;
    if (token == null) return;

    try {
      final result = await StaticContentService.getTermsAcceptanceStatus(token);
      if (result['success'] == true) {
        isTermsAccepted.value = result['data']?['isAccepted'] ?? false;
      }
    } catch (e) {
      print('Fetch Acceptance Status Error: $e');
    }
  }

  // 3. Fetch FAQs
  Future<void> fetchFaqs() async {
    isFaqLoading.value = true;
    faqError.value = '';
    try {
      final result = await StaticContentService.getFaqs();
      if (result['success'] == true) {
        List faqs = result['data'] ?? [];
        // Sort by order if available
        faqs.sort((a, b) => (a['order'] ?? 0).compareTo(b['order'] ?? 0));
        faqList.value = faqs;
      } else {
        faqError.value = result['message'] ?? 'Failed to fetch FAQs';
      }
    } catch (e) {
      faqError.value = 'Network error. Please try again.';
    } finally {
      isFaqLoading.value = false;
    }
  }
}
