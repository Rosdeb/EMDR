import 'package:get/get.dart';
import 'package:jonssony/services/static_content_service.dart';

class StaticContentController extends GetxController {
  final RxBool isPrivacyLoading = false.obs;
  final RxBool isTermsLoading = false.obs;
  final RxBool isFaqLoading = false.obs;

  final RxMap privacyData = {}.obs;
  final RxMap termsData = {}.obs;
  final RxList faqList = [].obs;

  final RxString privacyError = ''.obs;
  final RxString termsError = ''.obs;
  final RxString faqError = ''.obs;

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

  // 3. Fetch FAQs
  Future<void> fetchFaqs() async {
    isFaqLoading.value = true;
    faqError.value = '';
    try {
      final result = await StaticContentService.getFaqs();
      if (result['success'] == true) {
        faqList.value = result['data'] ?? [];
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
