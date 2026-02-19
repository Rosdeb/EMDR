import 'dart:async';
import 'package:flutter/material.dart';

class GameScreenN extends StatefulWidget {
  final String mode; // 'counting' অথবা 'spelling'
  final String difficulty; // 'easy', 'medium', 'hard'

  const GameScreenN({
    super.key,
    required this.mode,
    required this.difficulty
  });

  @override
  State<GameScreenN> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreenN> with SingleTickerProviderStateMixin {
  final TextEditingController _answerController = TextEditingController();

  // গেম স্টেট ভেরিয়েবল
  late String currentTaskTitle;
  late String correctAnswer;
  int currentStep = 1;
  int totalSteps = 5;
  bool isCorrect = false;
  bool isFinished = false;

  // EMDR ডট অ্যানিমেশনের জন্য
  late AnimationController _dotController;
  late Animation<Alignment> _dotAnimation;

  @override
  void initState() {
    super.initState();
    _generateNewTask();

    // বাম-থেকে-ডানে ডট মুভমেন্ট অ্যানিমেশন (Bilateral Stimulation)
    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _dotAnimation = Tween<Alignment>(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ).animate(CurvedAnimation(parent: _dotController, curve: Curves.easeInOut));
  }

  // নতুন টাস্ক তৈরি করার লজিক
  void _generateNewTask() {
    setState(() {
      _answerController.clear();
      isCorrect = false;

      if (widget.mode == 'counting') {
        // উল্টো গণনার লজিক
        int startNum = (widget.difficulty == 'easy') ? 50 : (widget.difficulty == 'medium' ? 100 : 200);
        int minusNum = (widget.difficulty == 'easy') ? 3 : 7;
        int currentVal = startNum - (currentStep * minusNum);

        currentTaskTitle = "What is $startNum minus ${currentStep * minusNum}?";
        correctAnswer = currentVal.toString();
      } else {
        // উল্টো বানানের লজিক
        List<String> words = widget.difficulty == 'easy'
            ? ["APPLE", "HAPPY", "CALM"]
            : ["EMPATHY", "KINDNESS", "MINDFUL"];

        String word = words[currentStep % words.length];
        currentTaskTitle = "Spell '$word' backwards";
        correctAnswer = word.split('').reversed.join('');
      }
    });
  }

  void _checkAnswer() {
    if (_answerController.text.trim().toUpperCase() == correctAnswer.toUpperCase()) {
      setState(() {
        isCorrect = true;
      });

      if (currentStep < totalSteps) {
        Future.delayed(const Duration(seconds: 1), () {
          setState(() {
            currentStep++;
            _generateNewTask();
          });
        });
      } else {
        setState(() {
          isFinished = true;
        });
      }
    } else {
      // ভুল উত্তরের ক্ষেত্রে ফিডব্যাক
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Not quite right, try again!")),
      );
    }
  }

  @override
  void dispose() {
    _dotController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.mode.toUpperCase()} Challenge"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF5A4A42),
      ),
      body: Stack(
        children: [
          // ১. EMDR ডট অ্যানিমেশন (সবার উপরে ব্যাকগ্রাউন্ডে থাকবে)
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: SizedBox(
              height: 40,
              child: AnimatedBuilder(
                animation: _dotAnimation,
                builder: (context, child) {
                  return Align(
                    alignment: _dotAnimation.value,
                    child: Container(
                      width: 25,
                      height: 25,
                      decoration: const BoxDecoration(
                        color: Color(0xFF8B7355),
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // ২. মেইন গেম কার্ড
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: isFinished ? _buildFinishView() : _buildTaskCard(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Step $currentStep of $totalSteps",
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 20),
          Text(
            currentTaskTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 24,
                fontFamily: 'Georgia',
                color: Color(0xFF5A4A42),
                fontWeight: FontWeight.bold
            ),
          ),
          const SizedBox(height: 30),
          TextField(
            controller: _answerController,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, letterSpacing: 2),
            decoration: InputDecoration(
              hintText: "Type here...",
              filled: true,
              fillColor: const Color(0xFFFAF5EB),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onSubmitted: (_) => _checkAnswer(),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _checkAnswer,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B8E23),
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text(
                "CHECK",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinishView() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 80),
          const SizedBox(height: 20),
          const Text(
            "Fantastic Work!",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          const Text(
            "You have successfully completed the backwards challenge. This helps focus your working memory.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Back to Menu"),
          ),
        ],
      ),
    );
  }
}