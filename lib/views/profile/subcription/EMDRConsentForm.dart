import 'dart:ui';
import 'package:flutter/material.dart';
import 'assignment.dart';


class ConsentFormScreen extends StatefulWidget {
  const ConsentFormScreen({super.key});

  @override
  State<ConsentFormScreen> createState() => _ConsentFormScreenState();
}

class _ConsentFormScreenState extends State<ConsentFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final nameCtrl = TextEditingController();
  final dobCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final signatureCtrl = TextEditingController();

  // Selections & States
  String? selectedSex;
  bool isSuicidal = false;
  bool isSeizures = false;
  bool isPregnancy = false;
  bool isDissociative = false;
  bool isPsychosis = false;

  bool researchConsent = false;
  bool understandsEMDR = false;
  bool understandsGDPR = false;
  bool isVoluntary = false;
  bool knowsEmergency = false;

  bool get cannotContinue => isSuicidal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF1F8F7), Colors.white],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: const Color(0xFF2E3E32).withOpacity(0.9),
                floating: true,
                elevation: 0,
                iconTheme: const IconThemeData(color: Colors.white),
                title: const Text("INKIND - National Psychology Clinic",
                    style: TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 1)),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _headerSection(),
                        const SizedBox(height: 30),

                        // 1. Personal Information
                        _glassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _sectionTitle("Personal Information"),
                              _textField("Full Name", nameCtrl),
                              _textField("Date of Birth", dobCtrl),
                              _sexDropdown(),
                              _textField("Email Address", emailCtrl),
                            ],
                          ),
                        ),

                        const SizedBox(height: 25),

                        // 2. About EMDR
                        _sectionTitle("About EMDR Therapy"),
                        _bodyText("Eye Movement Desensitization and Reprocessing (EMDR) is a psychotherapy treatment recognised by the World Health Organization (WHO) for treating trauma and PTSD. This digital programme combines standard EMDR sessions with Cognitive Behavioural Therapy (CBT) techniques."),
                        const SizedBox(height: 10),
                        _bodyText("The treatment follows eight structured phases and has been shown to be effective for approximately 67% of trauma cases."),

                        const SizedBox(height: 25),

                        // 3. Medical Screening
                        _glassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _sectionTitle("Medical & Safety Screening"),
                              _infoBox("Safety Check: Do you have any of the following conditions?", Colors.orange.withOpacity(0.2)),
                              _bodyText("Note: You cannot continue if you are actively suicidal.", color: Colors.red, isBold: true),
                              _checkTile("Active suicidal thoughts or plans", isSuicidal, (v) => setState(() => isSuicidal = v!)),
                              _checkTile("History of seizures", isSeizures, (v) => setState(() => isSeizures = v!)),
                              _checkTile("Pregnancy", isPregnancy, (v) => setState(() => isPregnancy = v!)),
                              _checkTile("Severe dissociative disorders", isDissociative, (v) => setState(() => isDissociative = v!)),
                              _checkTile("Active psychosis", isPsychosis, (v) => setState(() => isPsychosis = v!)),
                            ],
                          ),
                        ),

                        const SizedBox(height: 25),

                        // 4. Potential Risks
                        _sectionTitle("Potential Risks and Side Effects"),
                        _bulletPoint("Heightened emotions and vivid dreams"),
                        _bulletPoint("Physical sensations (headaches, dizziness, fatigue)"),
                        _bulletPoint("Emergence of associated memories"),
                        _bulletPoint("Temporary increase in distress levels"),

                        const SizedBox(height: 25),

                        // 5. Data Protection (UK GDPR)
                        _glassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _sectionTitle("Data Protection & Privacy"),
                              _bodyText("Legal Basis: Article 9(2)(h) UK GDPR.", isBold: true),
                              _bodyText("• Data Storage: AWS Elastic Beanstalk (UK/EU مراکز)\n• Encryption: AES-256 at rest, TLS 1.2+ in transit\n• Retention: 8 years for adults, age 25 for children"),
                              const SizedBox(height: 10),
                              _bodyText("Your Rights: Access, Rectify, Object, or Lodge a complaint with ICO."),
                              _bodyText("Note: Right to erasure is limited due to clinical record-keeping requirements.", color: Colors.orange.shade900, isBold: true),
                            ],
                          ),
                        ),

                        const SizedBox(height: 25),

                        // 6. Research Participation
                        _sectionTitle("Optional Research Participation"),
                        _checkTile("Consent to anonymised research use", researchConsent, (v) => setState(() => researchConsent = v!), isTheme: true),
                        _bodyText("Data is anonymised (all identifying information removed). This is entirely optional and won't affect treatment."),

                        const SizedBox(height: 25),

                        // 7. Crisis Support (The full detailed part)
                        _sectionTitle("Crisis Support & Emergency Contacts"),
                        _crisisCard(),

                        const SizedBox(height: 25),

                        // 8. Consent Declarations
                        _glassCard(
                          child: Column(
                            children: [
                              _checkTile("I understand EMDR nature and risks", understandsEMDR, (v) => setState(() => understandsEMDR = v!)),
                              _checkTile("I agree to UK GDPR data processing", understandsGDPR, (v) => setState(() => understandsGDPR = v!)),
                              _checkTile("I am participating voluntarily", isVoluntary, (v) => setState(() => isVoluntary = v!)),
                              _checkTile("I have saved crisis support numbers", knowsEmergency, (v) => setState(() => knowsEmergency = v!)),
                            ],
                          ),
                        ),

                        const SizedBox(height: 25),

                        // 9. Electronic Signature
                        _sectionTitle("Electronic Signature"),
                        _textField("Type full name to sign", signatureCtrl),
                        const SizedBox(height: 10),
                        _bodyText("This electronic signature is legally binding.", color: Colors.grey),

                        const SizedBox(height: 40),

                        _submitButton(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Glass UI Helpers ---

  Widget _glassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.35),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.4)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title.toUpperCase(),
          style: const TextStyle(color: Color(0xFF11756C), fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2)),
    );
  }

  Widget _textField(String label, TextEditingController ctrl) {
    return TextFormField(
      controller: ctrl,
      decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(fontSize: 13)),
      validator: (v) => v!.isEmpty ? "Required" : null,
    );
  }

  Widget _sexDropdown() {
    return DropdownButtonFormField<String>(
      hint: const Text("Sex"),
      items: ["Male", "Female", "Other", "Prefer not to say"]
          .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: (v) => setState(() => selectedSex = v),
    );
  }

  Widget _checkTile(String title, bool val, Function(bool?)? onChange, {bool isTheme = false}) {
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: TextStyle(fontSize: 13, color: isTheme ? const Color(0xFF17B5A7) : Colors.black87)),
      value: val,
      onChanged: onChange,
      activeColor: const Color(0xFF17B5A7),
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  Widget _bodyText(String text, {Color color = Colors.black54, bool isBold = false}) {
    return Text(text, style: TextStyle(fontSize: 13, color: color, height: 1.5, fontWeight: isBold ? FontWeight.bold : FontWeight.normal));
  }

  Widget _bulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: Colors.black87))),
        ],
      ),
    );
  }

  Widget _infoBox(String text, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
      child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  Widget _crisisCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("If in crisis, reach out immediately:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 13)),
          const SizedBox(height: 10),
          _crisisLine("GP / NHS 111", "Urgent Support"),
          _crisisLine("Samaritans", "116 123 (Free, 24/7)"),
          _crisisLine("Crisis Text Line", "Text 'SHOUT' to 85258"),
          _crisisLine("Mind Infoline", "0300 123 3393 (9am-6pm)"),
          _crisisLine("SANEline", "0300 304 7000 (4pm-10pm)"),
          _crisisLine("Emergency", "Call 999 or go to A&E"),
        ],
      ),
    );
  }

  Widget _crisisLine(String label, String contact) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          Text(contact, style: const TextStyle(fontSize: 12, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _headerSection() {
    return const Center(
      child: Column(
        children: [
          Text("EMDR Programme", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF11756C))),
          Text("Consent & Data Agreement", style: TextStyle(fontSize: 13, color: Colors.blueGrey)),
        ],
      ),
    );
  }

  Widget _submitButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: cannotContinue ? Colors.grey : const Color(0xFF17B5A7),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 0,
        ),
        onPressed: cannotContinue ? null : _submit,
        child: const Text("SUBMIT CONSENT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (!understandsEMDR || !understandsGDPR || !isVoluntary || !knowsEmergency) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please accept all declarations.")));
        return;
      }
      if (nameCtrl.text.trim() != signatureCtrl.text.trim()) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Signature name does not match Full Name.")));
        return;
      }
      // navigation for submission success
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const FullAssessmentFlow()),
      );
    }
  }
}