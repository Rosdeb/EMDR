import 'package:flutter/material.dart';
import '../../home/my_homework.dart';

class FullAssessmentFlow extends StatefulWidget {
  const FullAssessmentFlow({super.key});

  @override
  State<FullAssessmentFlow> createState() => _FullAssessmentFlowState();
}

class _FullAssessmentFlowState extends State<FullAssessmentFlow> {
  int _currentStep = 0; // 0: PHQ9, 1: GAD7, 2: DES-II, 3: Result
  int _questionIndex = 0;

  // ডাটা স্টোরেজ
  Map<int, int> phq9Answers = {};
  Map<int, int> gad7Answers = {};
  Map<int, double> des2Answers = {};

  // প্রশ্নপত্র
  final List<String> phq9Questions = [
    "Little interest or pleasure in doing things",
    "Feeling down, depressed, or hopeless",
    "Trouble falling or staying asleep, or sleeping too much",
    "Feeling tired or having little energy",
    "Poor appetite or overeating",
    "Feeling bad about yourself — or that you are a failure",
    "Trouble concentrating on things, such as reading the newspaper",
    "Moving or speaking so slowly that other people could have noticed",
    "Thoughts that you would be better off dead, or of hurting yourself"
  ];

  final List<String> gad7Questions = [
    "Feeling nervous, anxious or on edge",
    "Not being able to stop or control worrying",
    "Worrying too much about different things",
    "Trouble relaxing",
    "Being so restless that it is hard to sit still",
    "Becoming easily annoyed or irritable",
    "Feeling afraid as if something awful might happen"
  ];

  final List<String> des2Questions = [
    "Experience of driving or riding in a car and suddenly realizing you don't remember part of the trip.",
    "Realizing you did not hear part or all of what was said during a conversation.",
    "Finding yourself in a place and having no idea how you got there.",
    "Finding yourself dressed in clothes that you don't remember putting on.",
    "Finding new things among your belongings that you don't remember buying.",
    "Being approached by people you don't know who call you by another name.",
    "Feeling as though you are standing next to yourself or watching yourself do something.",
    "Finding that you sometimes don't recognize friends or family members."
  ];

  // --- লজিক সেকশন ---

  int getTotalScore(Map<int, int> answers) => answers.values.fold(0, (prev, element) => prev + element);

  double getDesAverage() {
    if (des2Answers.isEmpty) return 0.0;
    double sum = des2Answers.values.fold(0, (prev, element) => prev + element);
    return sum / des2Questions.length;
  }

  String getPhqInterpretation(int score) {
    if (score <= 4) return "Minimal depression";
    if (score <= 9) return "Mild depression";
    if (score <= 14) return "Moderate depression";
    if (score <= 19) return "Moderately severe depression";
    return "Severe depression";
  }

  String getGadInterpretation(int score) {
    if (score <= 4) return "Minimal anxiety";
    if (score <= 9) return "Mild anxiety";
    if (score <= 14) return "Moderate anxiety";
    return "Severe anxiety";
  }

  void _handleNext() {
    if (_currentStep == 3) {
      // Save and Exit লজিক
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MyHomeworkPri()),
      );
      return;
    }

    setState(() {
      int totalQ = _currentStep == 0 ? phq9Questions.length : (_currentStep == 1 ? gad7Questions.length : des2Questions.length);
      if (_questionIndex < totalQ - 1) {
        _questionIndex++;
      } else {
        _currentStep++;
        _questionIndex = 0;
      }
    });
  }

  void _handleBack() {
    setState(() {
      if (_questionIndex > 0) {
        _questionIndex--;
      } else if (_currentStep > 0) {
        _currentStep--;
        _questionIndex = (_currentStep == 0) ? phq9Questions.length - 1 : (_currentStep == 1 ? gad7Questions.length - 1 : 0);
      } else {
        Navigator.pop(context);
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
            _buildTabNavigation(),
            if (_currentStep < 3) _buildProgressBar(),
            Expanded(
              child: SingleChildScrollView(
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

  // --- UI কম্পোনেন্টসমূহ ---

  Widget _buildCustomHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Column(
        children: [
          const Text("INKIND EMDR", style: TextStyle(fontSize: 10, letterSpacing: 2, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(_currentStep == 3 ? "Your Summary" : "Assessment",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2D3142))),
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
            child: Text(tabs[index], style: TextStyle(color: isActive ? Colors.white : Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
          );
        }),
      ),
    );
  }

  Widget _buildProgressBar() {
    int total = _currentStep == 0 ? phq9Questions.length : (_currentStep == 1 ? gad7Questions.length : des2Questions.length);
    double progress = (_questionIndex + 1) / total;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(value: progress, minHeight: 8, backgroundColor: Colors.black12, color: const Color(0xFF52734D)),
          ),
          const SizedBox(height: 8),
          Text("Progress: ${(progress * 100).toInt()}%", style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildBodyContent() {
    if (_currentStep == 0) return _buildQuestionStep(phq9Questions[_questionIndex], phq9Answers, "PHQ-9");
    if (_currentStep == 1) return _buildQuestionStep(gad7Questions[_questionIndex], gad7Answers, "GAD-7");
    if (_currentStep == 2) return _buildSliderStep(des2Questions[_questionIndex]);
    return _buildResultStep();
  }

  Widget _buildQuestionStep(String question, Map<int, int> answerMap, String title) {
    int total = _currentStep == 0 ? phq9Questions.length : gad7Questions.length;
    return Column(
      children: [
        _buildInfoCard(title, "Over the last 2 weeks, how often have you been bothered by the following?"),
        Container(
          margin: const EdgeInsets.only(top: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: const Color(0xFFFFFBF0), borderRadius: BorderRadius.circular(18)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("QUESTION ${_questionIndex + 1} OF $total", style: const TextStyle(fontSize: 11, color: Colors.black38, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(question, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600, height: 1.3)),
              const SizedBox(height: 25),
              ...List.generate(4, (i) {
                List<String> labels = ["Not at all", "Several days", "More than half the days", "Nearly every day"];
                bool isSelected = answerMap[_questionIndex] == i;
                return GestureDetector(
                  onTap: () => setState(() => answerMap[_questionIndex] = i),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF52734D).withOpacity(0.1) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isSelected ? const Color(0xFF52734D) : Colors.black12, width: 1.5),
                    ),
                    child: Row(
                      children: [
                        Icon(isSelected ? Icons.check_circle : Icons.circle_outlined, color: isSelected ? const Color(0xFF52734D) : Colors.black26),
                        const SizedBox(width: 15),
                        Expanded(child: Text(labels[i], style: TextStyle(color: isSelected ? const Color(0xFF52734D) : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal))),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSliderStep(String question) {
    double currentVal = des2Answers[_questionIndex] ?? 0.0;
    return Column(
      children: [
        _buildInfoCard("DES-II", "Indicate what percentage of the time this happens to you."),
        Container(
          margin: const EdgeInsets.only(top: 20),
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(color: const Color(0xFFFFFBF0), borderRadius: BorderRadius.circular(18)),
          child: Column(
            children: [
              Text("QUESTION ${_questionIndex + 1} OF ${des2Questions.length}", style: const TextStyle(fontSize: 11, color: Colors.black38, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              Text(question, textAlign: TextAlign.center, style: const TextStyle(fontSize: 17, height: 1.4)),
              const SizedBox(height: 35),
              // রিয়েল-টাইম পার্সেন্টেজ ডিসপ্লে
              Text("${currentVal.toInt()}%", style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Color(0xFF52734D))),
              Slider(
                value: currentVal,
                min: 0, max: 100,
                divisions: 10,
                activeColor: const Color(0xFF52734D),
                onChanged: (v) => setState(() => des2Answers[_questionIndex] = v),
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text("0% (NEVER)", style: TextStyle(fontSize: 10, color: Colors.grey)), Text("100% (ALWAYS)", style: TextStyle(fontSize: 10, color: Colors.grey))],
              )
            ],
          ),
        ),
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
        // ইমেজের মতো সাপোর্ট ব্যানার
        if (phq >= 10 || gad >= 10 || des >= 30)
          Container(
            padding: const EdgeInsets.all(15),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(color: Colors.red.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red.withOpacity(0.2))),
            child: const Row(children: [
              Icon(Icons.info_outline, color: Colors.redAccent),
              SizedBox(width: 10),
              Expanded(child: Text("Important: Additional professional support is recommended based on your scores.", style: TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.bold))),
            ]),
          ),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: const Color(0xFFFFFBF0), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.black12)),
          child: Column(
            children: [
              _resultRow("Depression (PHQ-9)", "$phq/27", getPhqInterpretation(phq), phq >= 10 ? Colors.redAccent : const Color(0xFF52734D)),
              _resultRow("Anxiety (GAD-7)", "$gad/21", getGadInterpretation(gad), gad >= 10 ? Colors.redAccent : const Color(0xFF52734D)),
              _resultRow("Dissociation (DES-II)", "Avg: ${des.toStringAsFixed(1)}%", des >= 30 ? "Consultation Advised" : "Normal Range", des >= 30 ? Colors.redAccent : const Color(0xFF52734D), isLast: true),
            ],
          ),
        ),
        const SizedBox(height: 25),
        const Text("Resources & Help:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        _buildContactBox("Samaritans", "Call 116 123", "24/7 Emotional Support Helpline"),
        const SizedBox(height: 10),
        _buildContactBox("Crisis Text Line", "Text SHOUT to 85258", "Confidential text-based support"),
        const SizedBox(height: 20),
        const Center(child: Text("Note: This screening is not a clinical diagnosis.", style: TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic))),
      ],
    );
  }

  Widget _resultRow(String t, String s, String desc, Color color, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(t, style: const TextStyle(fontSize: 12, color: Colors.black45, fontWeight: FontWeight.bold)),
              Text(s, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const SizedBox(height: 5),
          Text(desc, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          if (!isLast) const Divider(height: 30),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String sub) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFFF3F6F9), borderRadius: BorderRadius.circular(15)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(sub, style: const TextStyle(color: Colors.black54, fontSize: 13, height: 1.4)),
      ]),
    );
  }

  Widget _buildContactBox(String t, String s, String c) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.black12), borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(t, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Text(s, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
        Text(c, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ]),
    );
  }

  Widget _buildBottomButtons() {
    bool canContinue = (_currentStep == 0 && phq9Answers.containsKey(_questionIndex)) ||
        (_currentStep == 1 && gad7Answers.containsKey(_questionIndex)) ||
        (_currentStep == 2 && des2Answers.containsKey(_questionIndex)) || (_currentStep == 3);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(child: TextButton(onPressed: _handleBack, child: const Text("Back", style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)))),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: canContinue ? _handleNext : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF52734D),
                disabledBackgroundColor: Colors.grey.shade300,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Text(_currentStep == 3 ? "Save & Exit" : "Continue", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}