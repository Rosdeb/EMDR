import 'package:get/get.dart';
import 'package:jonssony/controller/auth_controller.dart';
import 'package:jonssony/services/onboarding_service.dart';

class OnboardingController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxMap onboardingStatus = {}.obs;

  // Track if user is blocked due to safety check
  final RxBool isBlocked = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (_authController.isLoggedIn) {
      fetchOnboardingStatus();
    }
  }

  // 1. Fetch current onboarding status
  Future<void> fetchOnboardingStatus() async {
    isLoading.value = true;
    try {
      final token = _authController.token;
      if (token == null) return;

      final result = await OnboardingService.getOnboardingStatus(token);
      if (result['success']) {
        onboardingStatus.value = result['data'] ?? {};
      }
    } catch (e) {
      print('Error fetching onboarding status: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // 2. Submit Step 1, 2, and 3 in sequence
  Future<bool> completeOnboardingSteps({
    required String dob,
    required String sex,
    required Map<String, bool> safetyCheck,
    required Map<String, dynamic> consent,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';
    isBlocked.value = false;

    try {
      final token = _authController.token;
      if (token == null) return false;

      // Step 1: Profile
      final profileRes = await OnboardingService.saveProfile(
        token: token,
        dateOfBirth: dob,
        sex: sex,
      );
      if (!profileRes['success']) {
        errorMessage.value = profileRes['message'];
        return false;
      }

      // Step 2: Safety Check
      final safetyRes = await OnboardingService.submitSafetyCheck(
        token: token,
        activeSuicidalThoughts: safetyCheck['activeSuicidalThoughts'] ?? false,
        historyOfSeizures: safetyCheck['historyOfSeizures'] ?? false,
        pregnancy: safetyCheck['pregnancy'] ?? false,
        severeDissociativeDisorders: safetyCheck['severeDissociativeDisorders'] ?? false,
        activePsychosis: safetyCheck['activePsychosis'] ?? false,
      );
      
      if (!safetyRes['success']) {
        errorMessage.value = safetyRes['message'];
        // Check if the error code/message indicates a block
        if (safetyCheck.values.any((v) => v == true)) {
           isBlocked.value = true;
        }
        return false;
      }

      // Step 3: Consent
      final consentRes = await OnboardingService.saveConsent(
        token: token,
        understoodEMDRNatureAndRisks: consent['understoodEMDRNatureAndRisks'] ?? false,
        agreedToGDPR: consent['agreedToGDPR'] ?? false,
        participatingVoluntarily: consent['participatingVoluntarily'] ?? false,
        savedCrisisSupportNumbers: consent['savedCrisisSupportNumbers'] ?? false,
        optionalResearchParticipation: consent['optionalResearchParticipation'] ?? false,
        electronicSignature: consent['electronicSignature'] ?? '',
      );

      if (!consentRes['success']) {
        errorMessage.value = consentRes['message'];
        return false;
      }

      return true;
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred.';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // 3. Submit Assessment
  Future<Map<String, dynamic>> submitAssessment({
    required List<int> phq9,
    required List<int> gad7,
    required List<double> des11,
  }) async {
    isLoading.value = true;
    try {
      final token = _authController.token;
      if (token == null) return {'success': false, 'message': 'No session found'};

      final result = await OnboardingService.submitAssessment(
        token: token,
        phq9Answers: phq9,
        gad7Answers: gad7,
        des11Answers: des11,
      );

      return result;
    } catch (e) {
      return {'success': false, 'message': 'Network error'};
    } finally {
      isLoading.value = false;
    }
  }
}
