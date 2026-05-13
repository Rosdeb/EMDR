import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jonssony/controller/onboarding_controller.dart';
import 'package:jonssony/controller/subscription_controller.dart';
import 'package:jonssony/services/stripe_service.dart';
import '../../home/my_homework.dart';

class FullAssessmentFlow extends StatefulWidget {
  const FullAssessmentFlow({super.key});

  @override
  State<FullAssessmentFlow> createState() => _FullAssessmentFlowState();
}

class _FullAssessmentFlowState extends State<FullAssessmentFlow> {
  int _currentStep = 0; // 0: PHQ9, 1: GAD7, 2: DES-II, 3: Result
  final ScrollController _scrollController = ScrollController();

  Map<int, int> phq9Answers = {};
  Map<int, int> gad7Answers = {};
  Map<int, double> des2Answers = {};

  final OnboardingController _onboardingController =
      Get.find<OnboardingController>();
  bool _apiReportedNeedsSupport = false;
  String _apiRecommendation = '';
  Map<String, dynamic>? _apiScores; // Stores the full scores map from API

  final List<String> phq9Questions = [
    "Little interest or pleasure in doing things",
    "Feeling down, depressed, or hopeless",
    "Trouble falling or staying asleep, or sleeping too much",
    "Feeling tired or having little energy",
    "Poor appetite or overeating",
    "Feeling bad about yourself — or that you are a failure",
    "Trouble concentrating on things, such as reading the newspaper",
    "Moving or speaking so slowly that other people could have noticed",
    "Thoughts that you would be better off dead, or of hurting yourself",
  ];

  final List<String> gad7Questions = [
    "Feeling nervous, anxious or on edge",
    "Not being able to stop or control worrying",
    "Worrying too much about different things",
    "Trouble relaxing",
    "Being so restless that it is hard to sit still",
    "Becoming easily annoyed or irritable",
    "Feeling afraid as if something awful might happen",
  ];

  final List<String> des2Questions = [
    "Experience of driving or riding in a car and suddenly realizing you don't remember part of the trip.",
    "Realizing you did not hear part or all of what was said during a conversation.",
    "Finding yourself in a place and having no idea how you got there.",
    "Finding yourself dressed in clothes that you don't remember putting on.",
    "Finding new things among your belongings that you don't remember buying.",
    "Being approached by people you don't know who call you by another name.",
    "Feeling as though you are standing next to yourself or watching yourself do something.",
    "Finding that you sometimes don't recognize friends or family members.",
  ];

  int getTotalScore(Map<int, int> answers) =>
      answers.values.fold(0, (prev, element) => prev + element);

  double getDesAverage() {
    if (des2Answers.isEmpty) return 0.0;
    double sum = des2Answers.values.fold(0, (prev, element) => prev + element);
    return sum / des2Questions.length;
  }

  String getPhqInterpretation(int score) {
    if (score <= 4) return "Minimal";
    if (score <= 9) return "Mild";
    if (score <= 14) return "Moderate";
    if (score <= 19) return "Moderately Severe";
    return "Severe";
  }

  String getGadInterpretation(int score) {
    if (score <= 4) return "Minimal";
    if (score <= 9) return "Mild";
    if (score <= 14) return "Moderate";
    return "Severe";
  }

  bool get _needsSupport {
    if (_apiReportedNeedsSupport) return true;
    int phq = getTotalScore(phq9Answers);
    int gad = getTotalScore(gad7Answers);
    double des = getDesAverage();
    return phq >= 10 || gad >= 10 || des >= 30;
  }

  bool get _isScoreTooLow => getDesAverage() < 30;

  /// Safe capitalize — avoids GetX's nullable .capitalize() getter
  String _capitalizeFirst(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).toLowerCase();

  void _handleNext() async {
    if (_currentStep == 2) {
      final success = await _submitToApi();
      if (!success) return;
    }

    if (_currentStep == 3) {
      final controller = Get.find<SubscriptionController>();
      final plan = controller.selectedPlanForCheckout.value;

      if (plan == null) {
        Get.snackbar(
          "Error",
          "No plan selected. Please go back and select a plan.",
        );
        return;
      }

      final rawPrice = plan['price'];
      bool isFree =
          rawPrice == 0 ||
          rawPrice == "0" ||
          rawPrice.toString().toLowerCase() == "free";

      if (isFree) {
        controller.subscribe(plan).then((success) {
          if (success) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const MyHomeworkPri()),
              (route) => false,
            );
          }
        });
      } else {
        _processStripePayment(plan, controller);
      }
      return;
    }
    setState(() {
      _currentStep++;
    });
    // Scroll back to top on step change
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });
  }

  Future<bool> _submitToApi() async {
    List<int> phqList = List.generate(
      phq9Questions.length,
      (i) => phq9Answers[i] ?? 0,
    );
    List<int> gadList = List.generate(
      gad7Questions.length,
      (i) => gad7Answers[i] ?? 0,
    );
    List<double> desList = List.generate(
      des2Questions.length,
      (i) => des2Answers[i] ?? 0.0,
    );

    final result = await _onboardingController.submitAssessment(
      phq9: phqList,
      gad7: gadList,
      des11: desList,
    );

    if (result['success'] == true) {
      // OnboardingService._handleResponse wraps as {'success': true, 'data': fullBody}
      // fullBody itself is {'success': true, 'data': { scores, recommendation, ... }}
      // So the actual assessment data lives at result['data']['data']
      final rawBody = result['data'] as Map<String, dynamic>? ?? {};
      final data = (rawBody['data'] ?? rawBody) as Map<String, dynamic>;

      setState(() {
        _apiReportedNeedsSupport = data['requiresProfessionalSupport'] ?? false;
        _apiRecommendation = data['recommendation']?.toString() ?? '';
        _apiScores = data['scores'] as Map<String, dynamic>?;
      });
      return true;
    } else {
      Get.snackbar(
        "Error",
        result['message']?.toString() ??
            "Failed to submit assessment. Please check your connection.",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    }
  }

  /// Maps currency symbols (£, $, €) to Stripe ISO codes (gbp, usd, eur)
  String _currencyToIso(String? rawCurrency) {
    final Map<String, String> symbolMap = {
      '£': 'gbp',
      '\$': 'usd',
      '€': 'eur',
      'GBP': 'gbp',
      'USD': 'usd',
      'EUR': 'eur',
    };
    final raw = (rawCurrency ?? '').trim();
    return symbolMap[raw] ?? raw.toLowerCase();
  }

  Future<void> _processStripePayment(
    Map<String, dynamic> plan,
    SubscriptionController controller,
  ) async {
    final double amount = double.tryParse(plan['price'].toString()) ?? 0.0;
    final String currency = _currencyToIso(plan['currency']?.toString());

    print(
      '💳 Plan price: ${plan['price']}, currency raw: ${plan['currency']}, ISO: $currency',
    );

    if (amount <= 0) {
      Get.snackbar("Error", "Invalid payment amount.");
      return;
    }

    // Show loading? The Stripe Service handles the sheet presentation.
    final response = await StripeService.instance.makePayment(
      amount: amount,
      currency: currency,
    );

    if (response.result == PaymentResult.success) {
      // Payment Done -> Subscribe on Backend
      final success = await controller.subscribe(
        plan,
        paymentId: response.paymentIntentId,
      );
      if (success) {
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const MyHomeworkPri()),
            (route) => false,
          );
        }
      }
    } else if (response.result == PaymentResult.failed) {
      Get.snackbar(
        "Payment Failed",
        "Something went wrong with the payment transaction.",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } else if (response.result == PaymentResult.canceled) {
      // User simply closed the sheet, no snackbar needed usually
      print("Payment canceled by user.");
    }
  }

  void _handleBack() {
    setState(() {
      if (_currentStep > 0) {
        _currentStep--;
      } else {
        Navigator.pop(context);
        return;
      }
    });
    // Scroll back to top on step change
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: SafeArea(
        child: Column(
          children: [
            _buildCustomHeader(),
            if (_currentStep < 3) _buildTabNavigation(),
            if (_currentStep < 3) _buildProgressBar(),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildBodyContent(),
              ),
            ),
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black54),
              onPressed: _handleBack,
            ),
          ),
          Column(
            children: [
              const Text(
                "INKIND EMDR",
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 2,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _currentStep == 3 ? "Your Summary" : "Assessment",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3142),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabNavigation() {
    final tabs = ["PHQ-9", "GAD-7", "DES-II"];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          bool isActive = _currentStep == index;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 5),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF52734D) : Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.black12),
            ),
            child: Text(
              tabs[index],
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildProgressBar() {
    double progress = (_currentStep + 1) / 3;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.black12,
              color: const Color(0xFF52734D),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Section progress: ${_currentStep + 1} of 3",
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyContent() {
    if (_currentStep == 0) {
      return _buildQuestionStep(phq9Questions, phq9Answers, "PHQ-9");
    }
    if (_currentStep == 1) {
      return _buildQuestionStep(gad7Questions, gad7Answers, "GAD-7");
    }
    if (_currentStep == 2) return _buildSliderStep(des2Questions);
    return _buildResultStep();
  }

  Widget _buildQuestionStep(
    List<String> questions,
    Map<int, int> answerMap,
    String title,
  ) {
    return Column(
      children: [
        _buildInfoCard(
          title,
          "Over the last 2 weeks, how often have you been bothered by the following?",
        ),
        const SizedBox(height: 10),
        ...List.generate(questions.length, (index) {
          return Container(
            margin: const EdgeInsets.only(top: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBF0),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "QUESTION ${index + 1} OF ${questions.length}",
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black38,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  questions[index],
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 25),
                ...List.generate(4, (i) {
                  List<String> labels = [
                    "Not at all",
                    "Several days",
                    "More than half the days",
                    "Nearly every day",
                  ];
                  bool isSelected = answerMap[index] == i;
                  return GestureDetector(
                    onTap: () => setState(() => answerMap[index] = i),
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF52734D).withOpacity(0.1)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF52734D)
                              : Colors.black12,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            color: isSelected
                                ? const Color(0xFF52734D)
                                : Colors.black26,
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Text(
                              labels[i],
                              style: TextStyle(
                                color: isSelected
                                    ? const Color(0xFF52734D)
                                    : Colors.black87,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                          // Score badge on the right
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF52734D)
                                  : Colors.grey.shade100,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF52734D)
                                    : Colors.black12,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '$i',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black54,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        }),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSliderStep(List<String> questions) {
    return Column(
      children: [
        _buildInfoCard(
          "DES-II",
          "Indicate what percentage of the time this happens to you.",
        ),
        const SizedBox(height: 10),
        ...List.generate(questions.length, (index) {
          double currentVal = des2Answers[index] ?? 0.0;
          return Container(
            margin: const EdgeInsets.only(top: 20),
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBF0),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                Text(
                  "QUESTION ${index + 1} OF ${questions.length}",
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black38,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  questions[index],
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 17, height: 1.4),
                ),
                const SizedBox(height: 35),
                Text(
                  "${currentVal.toInt()}%",
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF52734D),
                  ),
                ),
                Slider(
                  value: currentVal,
                  min: 0,
                  max: 100,
                  divisions: 10,
                  activeColor: const Color(0xFF52734D),
                  onChanged: (v) => setState(() => des2Answers[index] = v),
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "0% (NEVER)",
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                    Text(
                      "100% (ALWAYS)",
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildResultStep() {
    int phq = getTotalScore(phq9Answers);
    int gad = getTotalScore(gad7Answers);
    double des = getDesAverage();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),

        if (_isScoreTooLow)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(14),
              border: const Border(
                left: BorderSide(color: Colors.blueAccent, width: 4),
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Assessment Result: Low Severity",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Based on your assessment, your symptoms are in the normal range. Our self-guided EMDR programme is specifically designed for individuals experiencing clinical levels of distress (Score 30+).\n\nSince your score is below 30, you cannot proceed to subscription at this time. We recommend continuing with healthy habits or consulting a professional if you have specific concerns.",
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.6,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

        // ── Important Banner (API recommendation or fallback) ──
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: _needsSupport
                ? Colors.red.withOpacity(0.04)
                : _isScoreTooLow
                ? Colors.blue.withOpacity(0.04)
                : const Color(0xFF52734D).withOpacity(0.05),
            borderRadius: BorderRadius.circular(14),
            border: Border(
              left: BorderSide(
                color: _needsSupport
                    ? Colors.redAccent
                    : const Color(0xFF52734D),
                width: 4,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _needsSupport
                    ? "Important: Additional Support Recommended"
                    : _isScoreTooLow
                    ? "General Feedback"
                    : "Assessment Complete",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _needsSupport
                      ? Colors.redAccent
                      : const Color(0xFF52734D),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                // Show API recommendation if available, else fallback text
                _apiRecommendation.isNotEmpty
                    ? _apiRecommendation
                    : _needsSupport
                    ? "Thank you for completing the assessment. Based on your responses, we believe you would benefit from immediate professional support before beginning a self-guided EMDR program.\n\nYour wellbeing is our priority."
                    : "Thank you for completing the assessment. Your responses suggest you may be a good candidate for self-guided EMDR.",
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.6,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),

        // ── YOUR ASSESSMENT RESULTS header ──
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text(
            "YOUR ASSESSMENT RESULTS",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.black45,
              letterSpacing: 1.2,
            ),
          ),
        ),

        // ── Score Cards ── (API scores take priority over locally computed)
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.black12),
          ),
          child: Column(
            children: [
              _resultRow(
                label: "Depression (PHQ-9)",
                interpretation: _apiScores != null
                    ? _capitalizeFirst(
                        _apiScores!['depression']?['severity']?.toString() ??
                            getPhqInterpretation(phq),
                      )
                    : getPhqInterpretation(phq),
                scoreText: _apiScores != null
                    ? "Score: ${_apiScores!['depression']?['score'] ?? phq}/${_apiScores!['depression']?['outOf'] ?? 27}"
                    : "Score: $phq/27",
                color: phq >= 10 ? Colors.redAccent : Colors.black54,
                isLast: false,
              ),
              _resultRow(
                label: "Anxiety (GAD-7)",
                interpretation: _apiScores != null
                    ? _capitalizeFirst(
                        _apiScores!['anxiety']?['severity']?.toString() ??
                            getGadInterpretation(gad),
                      )
                    : getGadInterpretation(gad),
                scoreText: _apiScores != null
                    ? "Score: ${_apiScores!['anxiety']?['score'] ?? gad}/${_apiScores!['anxiety']?['outOf'] ?? 21}"
                    : "Score: $gad/21",
                color: gad >= 10 ? Colors.redAccent : Colors.black54,
                isLast: false,
              ),
              _resultRow(
                label: "Dissociation (DES-II)",
                interpretation: _apiScores != null
                    ? ((_apiScores!['dissociation']?['score'] ?? 0) >= 30
                          ? "Consultation Advised"
                          : "Normal Range")
                    : (des >= 30 ? "Consultation Advised" : "Normal Range"),
                scoreText: _apiScores != null
                    ? "Score: ${_apiScores!['dissociation']?['score']}%"
                    : "Score: ${des.toStringAsFixed(1)}%",
                color: des >= 30 ? Colors.redAccent : Colors.black54,
                isLast: true,
              ),
            ],
          ),
        ),

        const SizedBox(height: 25),

        // ── Immediate Support Available ──
        const Text(
          "Immediate Support Available",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),

        _buildContactBox(
          title: "Samaritans (24/7)",
          subtitle: "Free emotional support for anyone in distress",
          contact: "Call: 116 123",
          contactNote: "(Free from any phone)",
        ),
        const SizedBox(height: 10),
        _buildContactBox(
          title: "NHS Crisis Line",
          subtitle: "Urgent mental health support",
          contact: "Call: 111",
          contactNote: "and select mental health option",
        ),
        const SizedBox(height: 10),
        _buildContactBox(
          title: "SHOUT Crisis Text Line",
          subtitle: "24/7 text support for anyone in crisis",
          contact: 'Text "SHOUT" to 85258',
          contactNote: "",
        ),
        const SizedBox(height: 10),
        _buildContactBox(
          title: "Your GP Surgery",
          subtitle: "Contact your GP for an urgent appointment",
          contact: "They can provide immediate support and referrals",
          contactNote: "",
        ),

        const SizedBox(height: 20),
        const Center(
          child: Text(
            "Note: This screening is not a clinical diagnosis.",
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _resultRow({
    required String label,
    required String interpretation,
    required String scoreText,
    required Color color,
    required bool isLast,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontSize: 12, color: Colors.black45),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    interpretation,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              Text(
                scoreText,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(
            height: 1,
            thickness: 1,
            indent: 18,
            endIndent: 18,
            color: Colors.black12,
          ),
      ],
    );
  }

  Widget _buildInfoCard(String title, String sub) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F6F9),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            sub,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactBox({
    required String title,
    required String subtitle,
    required String contact,
    required String contactNote,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 6),
          Text(
            contact,
            style: const TextStyle(
              color: Color(0xFF1565C0),
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          if (contactNote.isNotEmpty)
            Text(
              contactNote,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    bool canContinue = false;
    if (_currentStep == 0) {
      canContinue = phq9Answers.length == phq9Questions.length;
    } else if (_currentStep == 1) {
      canContinue = gad7Answers.length == gad7Questions.length;
    } else if (_currentStep == 2) {
      canContinue = des2Answers.length == des2Questions.length;
    } else {
      canContinue = true;
    }

    if (_currentStep == 3) {
      // Result screen: two full-width stacked buttons
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isScoreTooLow ? null : _handleNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isScoreTooLow
                      ? Colors.grey
                      : const Color(0xFF52734D),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Complete Assessment",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _handleBack,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Colors.black12),
                  ),
                ),
                child: const Text(
                  "Save Results & Exit",
                  style: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Steps 0–2: Back + Continue side by side
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: _handleBack,
              child: const Text(
                "Back",
                style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: canContinue ? _handleNext : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF52734D),
                disabledBackgroundColor: Colors.grey.shade300,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Continue",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
