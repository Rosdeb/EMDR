import 'package:flutter/material.dart';

class FullAssessmentFlow extends StatefulWidget {
  const FullAssessmentFlow({super.key});

  @override
  State<FullAssessmentFlow> createState() => _FullAssessmentFlowState();
}

class _FullAssessmentFlowState extends State<FullAssessmentFlow> {
  // Navigation index: 0=PHQ9, 1=GAD7, 2=DES-II, 3=Result
  int _currentStep = 0;

  void _handleNext() {
    setState(() {
      if (_currentStep < 3) _currentStep++;
    });
  }

  void _handleBack() {
    setState(() {
      if (_currentStep > 0) _currentStep--;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6), // Exact background from image
      body: SafeArea(
        child: Column(
          children: [
            _buildCustomHeader(),
            _buildTabNavigation(),
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

  // Header design matching image_7c6ad9.png
  Widget _buildCustomHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Column(
        children: [
          const Text("INKIND EMDR",
              style: TextStyle(fontSize: 10, letterSpacing: 2, color: Colors.grey, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(
            _currentStep == 1 ? "Mental Health Assessment" : "Assessment",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, fontFamily: 'Serif', color: Color(0xFF2D3142)),
          ),
        ],
      ),
    );
  }

  // Tab indicator design matching image_7c7183.png
  Widget _buildTabNavigation() {
    final tabs = ["PHQ-9", "GAD-7", "DES-II"];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(tabs.length, (index) {
          bool isActive = (_currentStep == index) || (_currentStep == 3 && index == 2);
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 5),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF52734D) : Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.black.withOpacity(0.05)),
              boxShadow: [
                if (isActive) BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))
              ],
            ),
            child: Text(
              tabs[index],
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBodyContent() {
    switch (_currentStep) {
      case 0: // PHQ-9 Flow
        return Column(
          children: [
            _buildTitleSection("How are you feeling?", "This assessment helps us tailor your EMDR experience. Take your time with each question."),
            _buildInfoCard("Patient Health Questionnaire (PHQ-9)", "Over the last 2 weeks, how often have you been bothered by any of the following problems?"),
            _buildQuestionCard("1 OF 9", "Little interest or pleasure in doing things"),
            _buildQuestionCard("2 OF 9", "Feeling down, depressed, or hopeless"),
            _buildQuestionCard("9 OF 9", "Thoughts that you would be better off dead or of hurting yourself"),
          ],
        );
      case 1: // GAD-7 Flow
        return Column(
          children: [
            _buildInfoCard("Generalized Anxiety Disorder Scale (GAD-7)", "Over the last 2 weeks, how often have you been bothered by any of the following problems?\n\nReference: Spitzer, R. L., Kroenke, K., et al (2006)."),
            _buildQuestionCard("1 OF 7", "Feeling nervous, anxious or on edge"),
            _buildQuestionCard("2 OF 7", "Not being able to stop or control worrying"),
            _buildQuestionCard("7 OF 7", "Feeling afraid as if something awful might happen"),
          ],
        );
      case 2: // DES-II Flow
        return Column(
          children: [
            _buildTitleSection("How are you feeling?", "This questionnaire consists of experiences that you may have in your daily life. Please indicate what percentage of the time this happens to you."),
            _buildInfoCard("Dissociative Experiences Scale (DES-II)", "Reference: Carlson, E. B., & Putnam, F. W. (1993). An update on the Dissociative Experiences Scale."),
            _buildSliderCard("1 OF 8", "Some people have the experience of driving or riding in a car..."),
            _buildSliderCard("2 OF 8", "Some people find that sometimes they are listening to someone talk..."),
          ],
        );
      case 3: // Results Flow
        return Column(
          children: [
            _buildSupportBanner(),
            const SizedBox(height: 25),
            _buildSummaryCard(),
            const SizedBox(height: 25),
            _buildContactBox("Samaritans (24/7)", "Free emotional support for anyone in distress", "Call: 116 123"),
            _buildContactBox("NHS Crisis Line", "Urgent mental health support", "Call: 111"),
            _buildContactBox("SHOUT Crisis Text Line", "24/7 text support for anyone in crisis", "Text \"SHOUT\" to 85258"),
          ],
        );
      default: return const SizedBox();
    }
  }

  // --- Reusable UI Component Helpers ---

  Widget _buildTitleSection(String title, String subtitle) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, fontFamily: 'Serif')),
        const SizedBox(height: 12),
        Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54, fontSize: 14, height: 1.5)),
        const SizedBox(height: 25),
      ],
    );
  }

  Widget _buildInfoCard(String title, String sub) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(color: const Color(0xFFF3F6F9), borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2D3142))),
          const SizedBox(height: 12),
          Text(sub, style: const TextStyle(color: Colors.black54, fontSize: 14, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(String num, String text) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFFFFFBF0), borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("QUESTION $num", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black38, letterSpacing: 1)),
          const SizedBox(height: 12),
          Text(text, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500, fontFamily: 'Serif')),
          const SizedBox(height: 20),
          _buildOption("Not at all", "0"),
          _buildOption("Several days", "1"),
          _buildOption("More than half the days", "2"),
          _buildOption("Nearly every day", "3"),
        ],
      ),
    );
  }

  Widget _buildOption(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            height: 22, width: 22,
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.black12, width: 2)),
          ),
          const SizedBox(width: 15),
          Text(label, style: const TextStyle(fontSize: 15, color: Colors.black87)),
          const Spacer(),
          Text(val, style: const TextStyle(color: Colors.black26, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSliderCard(String num, String text) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFFFFFBF0), borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("QUESTION $num", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black38)),
          const SizedBox(height: 12),
          Text(text, style: const TextStyle(fontSize: 16, height: 1.4)),
          const SizedBox(height: 20),
          SliderTheme(
            data: SliderThemeData(trackHeight: 6, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10)),
            child: Slider(value: 0.1, onChanged: (v){}, activeColor: const Color(0xFF52734D), inactiveColor: const Color(0xFFDDE4DC)),
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("0% (NEVER)", style: TextStyle(fontSize: 10, color: Colors.black38, fontWeight: FontWeight.bold)),
              Text("10% ", style: TextStyle(fontSize: 10, color: Colors.black38)),
              Text("100% (ALWAYS)", style: TextStyle(fontSize: 10, color: Colors.black38, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSupportBanner() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBFA),
        borderRadius: BorderRadius.circular(15),
        border: const Border(left: BorderSide(color: Color(0xFFFF4D4D), width: 5)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Important: Additional Support Recommended", style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Color(0xFF2D3142))),
          SizedBox(height: 12),
          Text("Based on your responses, we believe you would benefit from immediate professional support before beginning a self-guided EMDR program.",
              style: TextStyle(fontSize: 14, height: 1.5, color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFFFFFBF0), borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          _resultRow("Depression (PHQ-9)", "Minimal (Score: 0/27)"),
          _resultRow("Anxiety (GAD-7)", "Minimal (Score: 0/21)"),
          _resultRow("Dissociation (DES-II)", "Score: 2.5%", isLast: true),
        ],
      ),
    );
  }

  Widget _resultRow(String t, String v, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t, style: const TextStyle(fontSize: 12, color: Colors.black38)),
          const SizedBox(height: 4),
          Text(v, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
          if (!isLast) const Divider(height: 25, color: Colors.black12),
        ],
      ),
    );
  }

  Widget _buildContactBox(String t, String s, String c) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFFFFFBF0), borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text(s, style: const TextStyle(fontSize: 14, color: Colors.black54)),
          const SizedBox(height: 10),
          Text(c, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black38)),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: ElevatedButton(
                onPressed: _handleBack,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE5EAE5),
                  foregroundColor: Colors.black87,
                  elevation: 0, padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Back", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _handleNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF52734D),
                foregroundColor: Colors.white,
                elevation: 0, padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                _currentStep == 2 ? "Complete Assessment" :
                _currentStep == 3 ? "Save Results & Exit" : "Continue",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}