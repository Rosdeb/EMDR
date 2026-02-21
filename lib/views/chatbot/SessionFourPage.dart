import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jonssony/utils/app_text.dart';
import 'popup_session_four.dart';

class SessionFourPage extends StatefulWidget {
  const SessionFourPage({super.key});

  @override
  State<SessionFourPage> createState() => _SessionFourPageState();
}

class _SessionFourPageState extends State<SessionFourPage> {
  final box = GetStorage();

  final List<String> _questions = [
    '"Beautifully simple. Incredibly easy to use but can be customized to your hiring workflow and needs."',
    '"How do you feel today about your progress in this session?"',
    '"What is one thing you would like to change about your current routine?"',
  ];

  late List<dynamic> _userAnswers;
  final TextEditingController _answerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedAnswers();
  }

  void _loadSavedAnswers() {
    var savedData = box.read('session4_answers');
    if (savedData != null) {
      _userAnswers = List.from(savedData);
    } else {
      _userAnswers = List.generate(_questions.length, (index) => null);
    }
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _saveAll() {
    box.write('session4_answers', _userAnswers);
    showReadyDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    const double appBarImageHeight = 150;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 0, left: 0, right: 0, height: appBarImageHeight,
            child: Image.asset('assets/images/my_emdr.png', fit: BoxFit.fill),
          ),
          Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(35),
                            topRight: Radius.circular(35),
                          ),
                          image: DecorationImage(
                            image: AssetImage('assets/images/chatbot_bg.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(
                          left: 20, right: 20, top: 30, bottom: 110,
                        ),
                        itemCount: _questions.length,
                        itemBuilder: (context, index) {
                          return _buildClickableCard(
                            context,
                            _questions[index],
                            _userAnswers[index]?.toString(),
                            index,
                          );
                        },
                      ),
                    ),

                    // Bottom Buttons
                    Positioned(
                      bottom: 0, left: 0, right: 0,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: EdgeInsets.only(
                              left: 20, right: 20, top: 16,
                              bottom: MediaQuery.of(context).padding.bottom + 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.4),
                              border: Border(
                                top: BorderSide(color: Colors.white.withOpacity(0.3)),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => Get.back(),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      side: const BorderSide(color: Color(0xFF537E5D), width: 1.5),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    ),
                                    child: const AppText('Skip for now', fontSize: 15, color: Color(0xFF537E5D), fontWeight: FontWeight.w600),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 2,
                                  child: ElevatedButton(
                                    onPressed: _saveAll,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF537E5D),
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    ),
                                    child: const AppText('Save & Continue', fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClickableCard(BuildContext context, String question, String? answer, int index) {
    bool hasAnswer = answer != null && answer.isNotEmpty;

    return GestureDetector(
      onTap: () => _showAnswerPopup(context, question, index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(question, fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500),
                  if (!hasAnswer) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: const [
                        Icon(Icons.edit_outlined, size: 13, color: Color(0xFF537E5D)),
                        SizedBox(width: 4),
                        AppText('Tap to answer', fontSize: 12, color: Color(0xFF537E5D), fontWeight: FontWeight.w400),
                      ],
                    ),
                  ],
                  if (hasAnswer) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(color: Colors.black12, thickness: 1),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.person_outline_outlined, size: 16, color: Color(0xFF537E5D)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: AppText(answer, fontSize: 14, color: const Color(0xFF537E5D), fontWeight: FontWeight.w600),
                        ),
                        const Icon(Icons.edit_outlined, size: 14, color: Color(0xFF537E5D)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAnswerPopup(BuildContext context, String question, int index) {
    _answerController.text = _userAnswers[index]?.toString() ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
            decoration: const BoxDecoration(
              color: Color(0xFF4D4D4D),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(color: Colors.white30, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                AppText(question, color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(color: const Color(0xFFFFF9F1), borderRadius: BorderRadius.circular(15)),
                  child: TextField(
                    controller: _answerController,
                    maxLines: 5,
                    autofocus: true,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      hintText: 'Write your answer here...',
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.black38),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_answerController.text.trim().isNotEmpty) {
                        setState(() {
                          _userAnswers[index] = _answerController.text.trim();
                          box.write('session4_answers', _userAnswers);
                        });
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF537E5D),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const AppText('Save', color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, left: 10),
      child: Row(children: [
        IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Get.back()),
        const AppText('Session 4', fontSize: 20, fontWeight: FontWeight.bold),
      ]),
    );
  }
}

