import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jonssony/controller/profile_controller.dart';
import 'package:jonssony/controller/onboarding_controller.dart';
import 'assignment.dart'; // Assume this contains FullAssessmentFlow

class ConsentFormScreen extends StatefulWidget {
  const ConsentFormScreen({super.key});

  @override
  State<ConsentFormScreen> createState() => _ConsentFormScreenState();
}

class _ConsentFormScreenState extends State<ConsentFormScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  // Controllers
  final nameCtrl = TextEditingController();
  final dobCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final signatureCtrl = TextEditingController();

  final OnboardingController _onboardingController = Get.find<OnboardingController>();

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

  // UPDATED LOGIC: Any of these conditions block submission.
  bool get cannotContinue =>
      isSuicidal || isSeizures || isPregnancy || isDissociative || isPsychosis;

  // Theme
  static const _primary = Color(0xFF0E7C73);
  static const _primaryLight = Color(0xFF17B5A7);
  static const _bg = Color(0xFFF5FAF9);
  static const _cardBg = Colors.white;
  static const _textDark = Color(0xFF1A2E2C);
  static const _textMid = Color(0xFF4A6360);
  static const _textLight = Color(0xFF8BA8A5);
  static const _accent = Color(0xFF00C9B8);

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();

    // Auto-fill available user data from ProfileController
    if (Get.isRegistered<ProfileController>()) {
      final profileController = Get.find<ProfileController>();
      final profile = profileController.userProfile;
      if (profile.isNotEmpty) {
        nameCtrl.text = profile['fullName'] ?? '';
        emailCtrl.text = profile['email'] ?? '';
        // If your API returns DOB, you can also fill it here:
        // dobCtrl.text = profile['dob'] ?? '';
      }
    }
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    nameCtrl.dispose();
    dobCtrl.dispose();
    emailCtrl.dispose();
    signatureCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      _headerBanner(),
                      const SizedBox(height: 28),

                      _numberedSection(
                        number: '01',
                        title: 'Personal Information',
                        icon: Icons.person_outline_rounded,
                        child: Column(
                          children: [
                            _styledTextField('Full Name', nameCtrl, Icons.badge_outlined),
                            const SizedBox(height: 14),
                            _styledDateField('Date of Birth', dobCtrl, Icons.calendar_today_outlined),
                            const SizedBox(height: 14),
                            _styledDropdown(),
                            const SizedBox(height: 14),
                            _styledTextField('Email Address', emailCtrl, Icons.email_outlined),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      _numberedSection(
                        number: '02',
                        title: 'About EMDR Therapy',
                        icon: Icons.psychology_outlined,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _infoTextBlock(
                              'Eye Movement Desensitization and Reprocessing (EMDR) is a psychotherapy treatment recognised by the World Health Organization (WHO) for treating trauma and PTSD. This digital programme combines standard EMDR sessions with Cognitive Behavioural Therapy (CBT) techniques.',
                            ),
                            const SizedBox(height: 10),
                            _infoTextBlock(
                              'The treatment follows eight structured phases and has been shown to be effective for approximately 67% of trauma cases.',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      _numberedSection(
                        number: '03',
                        title: 'Medical & Safety Screening',
                        icon: Icons.health_and_safety_outlined,
                        accentColor: const Color(0xFFF59E0B),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _warningBanner(
                              'Important Safety Check: Do you currently have or experience any of the following conditions?',
                              const Color(0xFFFFF7E6),
                              const Color(0xFFF59E0B),
                              Icons.warning_amber_rounded,
                            ),
                            const SizedBox(height: 6),
                            _dangerBanner('Note: You cannot continue with this programme if you are actively suicidal.'),
                            const SizedBox(height: 4),
                            _styledCheckTile(
                              label: 'Active suicidal thoughts or plans',
                              value: isSuicidal,
                              onChange: (v) => setState(() => isSuicidal = v!),
                              danger: true,
                            ),
                            _styledCheckTile(
                              label: 'History of seizures',
                              value: isSeizures,
                              onChange: (v) => setState(() => isSeizures = v!),
                              danger: true,
                            ),
                            _styledCheckTile(
                              label: 'Pregnancy',
                              value: isPregnancy,
                              onChange: (v) => setState(() => isPregnancy = v!),
                              danger: true,
                            ),
                            _styledCheckTile(
                              label: 'Severe dissociative disorders',
                              value: isDissociative,
                              onChange: (v) => setState(() => isDissociative = v!),
                              danger: true,
                            ),
                            _styledCheckTile(
                              label: 'Active psychosis',
                              value: isPsychosis,
                              onChange: (v) => setState(() => isPsychosis = v!),
                              danger: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      _numberedSection(
                        number: '04',
                        title: 'Potential Risks & Side Effects',
                        icon: Icons.info_outline_rounded,
                        child: Column(
                          children: [
                            _riskItem('Heightened emotions and vivid dreams'),
                            _riskItem('Physical sensations (headaches, dizziness, fatigue)'),
                            _riskItem('Emergence of associated memories'),
                            _riskItem('Continuation of processing between sessions'), // ADDED
                            _riskItem('Temporary increase in distress levels'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      _numberedSection(
                        number: '05',
                        title: 'Data Protection & Privacy',
                        icon: Icons.shield_outlined,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _dataPrivacyRow(Icons.gavel_rounded, 'Legal Basis', 'Article 9(2)(h) UK GDPR'),
                            _dataPrivacyRow(Icons.cloud_outlined, 'Data Storage', 'AWS Elastic Beanstalk (UK/EU)'),
                            _dataPrivacyRow(Icons.lock_outline_rounded, 'Encryption', 'AES-256 at rest, TLS 1.2+ in transit'),
                            _dataPrivacyRow(Icons.history_rounded, 'Retention', '8 years for adults, age 25 for children'),
                            const SizedBox(height: 12),
                            _warningBanner(
                              'Your Rights: Access, Rectify, Object, or Lodge a complaint with ICO.',
                              const Color(0xFFE8F5E9),
                              const Color(0xFF43A047),
                              Icons.verified_user_outlined,
                            ),
                            const SizedBox(height: 8),
                            _warningBanner(
                              'Note: Right to erasure is limited due to clinical record-keeping requirements.',
                              const Color(0xFFFFF3E0),
                              const Color(0xFFE65100),
                              Icons.warning_amber_rounded,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      _numberedSection(
                        number: '06',
                        title: 'Optional Research Participation',
                        icon: Icons.science_outlined,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _styledCheckTile(
                              label: 'I consent to my anonymised data being used for future research purposes',
                              value: researchConsent,
                              onChange: (v) => setState(() => researchConsent = v!),
                              themed: true,
                            ),
                            const SizedBox(height: 8),
                            _infoTextBlock(
                              'Your therapy data may be anonymised (all identifying information removed) and used to improve EMDR treatments. This is entirely optional and won\'t affect your treatment.',
                            ),
                            const SizedBox(height: 16),
                            const Text('How we protect your privacy in research:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: _textDark)),
                            const SizedBox(height: 8),
                            // ADDED MISSING BULLET POINTS
                            _bulletItem('All personal identifiers are permanently removed'),
                            _bulletItem('Data is aggregated with other participants'),
                            _bulletItem('Researchers have no access to your identity'),
                            _bulletItem('Research is reviewed by ethics committees'),
                            _bulletItem('Findings are published only in aggregate form'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ADDED ENTIRE MISSING SECTION
                      _numberedSection(
                        number: '07',
                        title: 'Your Rights During Treatment',
                        icon: Icons.assignment_ind_outlined,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _infoTextBlock('You have the right to:'),
                            const SizedBox(height: 10),
                            _bulletItem('Withdraw from the programme whenever you would like to and cancel your subscription'),
                            _bulletItem('Refuse any specific intervention'),
                            _bulletItem('Access emergency support if needed (see crisis contacts below)'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      _numberedSection(
                        number: '08',
                        title: 'Crisis Support & Emergency Contacts',
                        icon: Icons.emergency_outlined,
                        accentColor: const Color(0xFFE53935),
                        child: _crisisCard(),
                      ),
                      const SizedBox(height: 20),

                      _numberedSection(
                        number: '09',
                        title: 'Consent Declarations',
                        icon: Icons.task_alt_rounded,
                        child: Column(
                          children: [
                            _styledCheckTile(
                              label: 'I understand the nature of EMDR therapy and its potential risks and benefits',
                              value: understandsEMDR,
                              onChange: (v) => setState(() => understandsEMDR = v!),
                            ),
                            _styledCheckTile(
                              label: 'I understand how my data will be processed and stored in accordance with UK GDPR',
                              value: understandsGDPR,
                              onChange: (v) => setState(() => understandsGDPR = v!),
                            ),
                            _styledCheckTile(
                              label: 'I am participating voluntarily and understand I can withdraw at any time',
                              value: isVoluntary,
                              onChange: (v) => setState(() => isVoluntary = v!),
                            ),
                            _styledCheckTile(
                              label: 'I understand the emergency procedures and have saved the crisis support numbers provided',
                              value: knowsEmergency,
                              onChange: (v) => setState(() => knowsEmergency = v!),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      _numberedSection(
                        number: '10',
                        title: 'Electronic Signature',
                        icon: Icons.draw_outlined,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _styledTextField('Type your full name to sign electronically', signatureCtrl, Icons.edit_outlined),
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 2.0),
                                  child: Icon(Icons.verified_outlined, size: 14, color: _textLight),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'By typing your name above, you confirm that you have read, understood, and agree to the terms outlined in this consent form. This electronic signature is legally binding.',
                                    style: TextStyle(fontSize: 12, color: _textLight, fontStyle: FontStyle.italic, height: 1.4),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 36),

                      _submitButton(),

                      const SizedBox(height: 36),
                      // ADDED MISSING FOOTER
                      const Center(
                        child: Text(
                          'This form is compliant with UK GDPR Standards',
                          style: TextStyle(fontSize: 12, color: _textLight, fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── App Bar ──────────────────────────────────────────────────────────────

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 160,
      pinned: true,
      elevation: 0,
      backgroundColor: _primary,
      iconTheme: const IconThemeData(color: Colors.white),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0B5E57), Color(0xFF17B5A7)],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.psychology_rounded, color: Colors.white, size: 32),
                ),
                const SizedBox(height: 10),
                const Text(
                  'INKIND – National Psychology Clinic',
                  style: TextStyle(color: Colors.white70, fontSize: 16, letterSpacing: 1.0, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
        centerTitle: true,
      ),
    );
  }

  // ─── Header Banner ────────────────────────────────────────────────────────

  Widget _headerBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0B5E57), Color(0xFF17B5A7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: _primaryLight.withOpacity(0.25), blurRadius: 20, offset: const Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.article_outlined, color: Colors.white, size: 36),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'EMDR Programme',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Informed Consent & Data Processing Agreement',
                  style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Section Card ─────────────────────────────────────────────────────────

  Widget _numberedSection({
    required String number,
    required String title,
    required IconData icon,
    required Widget child,
    Color accentColor = _primary,
  }) {
    // Dim the section if the form is locked and it's Consent or Signature
    bool isDimmed = cannotContinue && (number == '09' || number == '10');

    return Opacity(
      opacity: isDimmed ? 0.5 : 1.0,
      child: AbsorbPointer(
        absorbing: isDimmed,
        child: Container(
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.07),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          number,
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(icon, color: accentColor, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Text Field ───────────────────────────────────────────────────────────

  Widget _styledTextField(String label, TextEditingController ctrl, IconData icon) {
    return TextFormField(
      controller: ctrl,
      style: const TextStyle(fontSize: 14, color: _textDark),
      validator: (v) => v!.isEmpty ? 'This field is required' : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13, color: _textMid),
        prefixIcon: Icon(icon, size: 18, color: _primary),
        filled: true,
        fillColor: _bg,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }

  // ─── Date Field ───────────────────────────────────────────────────────────

  Widget _styledDateField(String label, TextEditingController ctrl, IconData icon) {
    return TextFormField(
      controller: ctrl,
      readOnly: true,
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: _primary,
                  onPrimary: Colors.white,
                  onSurface: _textDark,
                ),
              ),
              child: child!,
            );
          },
        );
        if (pickedDate != null) {
          setState(() {
            ctrl.text = "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
          });
        }
      },
      style: const TextStyle(fontSize: 14, color: _textDark),
      validator: (v) => v!.isEmpty ? 'This field is required' : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: 'Select Date',
        labelStyle: const TextStyle(fontSize: 13, color: _textMid),
        prefixIcon: Icon(icon, size: 18, color: _primary),
        suffixIcon: const Icon(Icons.calendar_month, color: _primary),
        filled: true,
        fillColor: _bg,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }

  // ─── Dropdown ─────────────────────────────────────────────────────────────

  Widget _styledDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedSex,
      hint: const Text('Select Sex', style: TextStyle(fontSize: 13, color: _textMid)),
      items: ['Male', 'Female', 'Other', 'Prefer not to say']
          .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14))))
          .toList(),
      onChanged: (v) => setState(() => selectedSex = v),
      validator: (v) => v == null || v.isEmpty ? 'Please select your sex' : null,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.wc_outlined, size: 18, color: _primary),
        filled: true,
        fillColor: _bg,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }

  // ─── Checkbox Tile ────────────────────────────────────────────────────────

  Widget _styledCheckTile({
    required String label,
    required bool value,
    required Function(bool?) onChange,
    bool danger = false,
    bool themed = false,
  }) {
    final color = danger
        ? const Color(0xFFE53935)
        : themed
        ? _primaryLight
        : _primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => onChange(!value),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22,
                  height: 22,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    color: value ? color : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: value ? color : Colors.grey.shade400,
                      width: 1.8,
                    ),
                  ),
                  child: value
                      ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      color: danger && value ? const Color(0xFFE53935) : _textDark,
                      fontWeight: value ? FontWeight.w600 : FontWeight.normal,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Info Text Block ──────────────────────────────────────────────────────

  Widget _infoTextBlock(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 13, color: _textMid, height: 1.7),
    );
  }

  // ─── Bullet Item (Added for lists) ────────────────────────────────────────

  Widget _bulletItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•', style: TextStyle(color: _primaryLight, fontSize: 16, height: 1.2, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 13, color: _textMid, height: 1.5)),
          ),
        ],
      ),
    );
  }

  // ─── Warning Banner ───────────────────────────────────────────────────────

  Widget _warningBanner(String text, Color bg, Color border, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border.withOpacity(0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: border),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12.5, color: border.withRed(60), height: 1.5, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dangerBanner(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.block_rounded, size: 15, color: Color(0xFFE53935)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12.5, color: Color(0xFFE53935), fontWeight: FontWeight.w600, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Risk Item ────────────────────────────────────────────────────────────

  Widget _riskItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(color: _primaryLight, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 13, color: _textMid, height: 1.5)),
          ),
        ],
      ),
    );
  }

  // ─── Data Privacy Row ─────────────────────────────────────────────────────

  Widget _dataPrivacyRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: _primary),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: _textLight, fontWeight: FontWeight.w600)),
              Text(value, style: const TextStyle(fontSize: 13, color: _textDark, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Crisis Card ──────────────────────────────────────────────────────────

  Widget _crisisCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _warningBanner(
          'If you are experiencing a mental health crisis or emergency:',
          const Color(0xFFFFEBEE),
          const Color(0xFFE53935),
          Icons.emergency_rounded,
        ),
        const SizedBox(height: 4),
        _crisisRow(Icons.local_hospital_outlined, 'GP / NHS 111', 'Urgent Support / Non-life-threatening'), // UPDATED
        _crisisRow(Icons.phone_in_talk_outlined, 'Samaritans', '116 123 (Free, 24/7)'),
        _crisisRow(Icons.sms_outlined, 'Crisis Text Line', "Text 'SHOUT' to 85258"),
        _crisisRow(Icons.support_agent_outlined, 'Mind Infoline', '0300 123 3393 (9am–6pm)'),
        _crisisRow(Icons.headset_mic_outlined, 'SANEline', '0300 304 7000 (4pm–10pm)'),
        _crisisRow(Icons.warning_rounded, 'Emergency', 'Call 999 or go to A&E'),

        const SizedBox(height: 12),
        // ADDED MISSING HELPLINE LINK
        const Text(
          'Full list of mental health helplines available at:\nmind.org.uk/information-support/guides-to-support-and-services/',
          style: TextStyle(fontSize: 11, color: _textMid, fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 20),

        // ADDED MISSING BETWEEN-SESSION SUPPORT
        _infoTextBlock('Between-session support:'),
        const SizedBox(height: 8),
        _bulletItem('Save these numbers in your phone before beginning treatment'),
        _bulletItem('Share them with a trusted friend or family member'),
        _bulletItem('Don\'t wait until crisis point - reach out early if you\'re struggling'),
      ],
    );
  }

  Widget _crisisRow(IconData icon, String label, String contact) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1.0),
            child: Icon(icon, size: 16, color: const Color(0xFFE53935)),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 3,
            child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _textDark)),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 4,
            child: Text(
              contact,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 12, color: Color(0xFFE53935), fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Submit Button ────────────────────────────────────────────────────────

  Widget _submitButton() {
    final isLocked = cannotContinue;
    return Column(
      children: [
        if (isLocked)
        // ADDED MISSING MEDICAL REVIEW TEXT
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning_rounded, color: Color(0xFFE53935), size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '⚠️ Medical Review Required',
                        style: TextStyle(fontSize: 13, color: Color(0xFFE53935), fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'You have indicated one or more conditions that require medical review before proceeding with EMDR therapy.\n\nIf you are experiencing suicidal thoughts, please contact your GP immediately or call 999.\n\nClinical team contact: 0800 XXX XXXX or email clinical@inkind.uk',
                        style: TextStyle(fontSize: 12, color: Color(0xFFB71C1C), height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        Obx(() => SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: (isLocked || _onboardingController.isLoading.value) ? Colors.grey.shade300 : _primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: isLocked ? 0 : 4,
              shadowColor: _primary.withOpacity(0.4),
            ),
            onPressed: (isLocked || _onboardingController.isLoading.value) ? null : _submit,
            child: _onboardingController.isLoading.value 
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(isLocked ? Icons.lock_rounded : Icons.check_circle_rounded, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      isLocked ? 'SUBMISSION LOCKED' : 'SUBMIT CONSENT',
                      style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 14),
                    ),
                  ],
                ),
          ),
        )),
      ],
    );
  }

  // Full API-connected submission (Step 1 → Profile, Step 2 → Safety Check, Step 3 → Consent)
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate Consent Checkboxes
    if (!understandsEMDR || !understandsGDPR || !isVoluntary || !knowsEmergency) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please confirm all required consent declarations.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Validate Signature match
    if (nameCtrl.text.trim().toLowerCase() != signatureCtrl.text.trim().toLowerCase()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Electronic signature must match your full name exactly.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Call all 3 onboarding API steps via OnboardingController
    final success = await _onboardingController.completeOnboardingSteps(
      dob: dobCtrl.text.trim(),
      sex: selectedSex ?? '',
      safetyCheck: {
        'activeSuicidalThoughts': isSuicidal,
        'historyOfSeizures': isSeizures,
        'pregnancy': isPregnancy,
        'severeDissociativeDisorders': isDissociative,
        'activePsychosis': isPsychosis,
      },
      consent: {
        'understoodEMDRNatureAndRisks': understandsEMDR,
        'agreedToGDPR': understandsGDPR,
        'participatingVoluntarily': isVoluntary,
        'savedCrisisSupportNumbers': knowsEmergency,
        'optionalResearchParticipation': researchConsent,
        'electronicSignature': signatureCtrl.text.trim(),
      },
    );

    if (!mounted) return;

    if (success) {
      // All 3 steps succeeded → go to assessment
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const FullAssessmentFlow()),
      );
    } else {
      final msg = _onboardingController.errorMessage.value;
      final isBlocked = _onboardingController.isBlocked.value;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isBlocked
                ? 'You cannot continue due to one or more safety conditions. Please seek immediate professional support.'
                : (msg.isNotEmpty ? msg : 'Something went wrong. Please try again.'),
          ),
          backgroundColor: isBlocked ? Colors.red.shade700 : Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }
}