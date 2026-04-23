import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

class PatternMemoryGame extends StatefulWidget {
  const PatternMemoryGame({super.key});

  @override
  State<PatternMemoryGame> createState() => _PatternMemoryGameState();
}

class _PatternMemoryGameState extends State<PatternMemoryGame> {

  final List<Color> colors = [
    const Color(0xFFC1475B),
    const Color(0xFF4A7C9E),
    const Color(0xFF6B8E23),
    const Color(0xFFD4A017),
    const Color(0xFF9B59B6),
    const Color(0xFFE67E22),
  ];

  String? difficulty;
  int currentRound = 1;
  int longestSequence = 0;
  List<Color> currentPattern = [];
  List<Color> userPattern = [];
  bool isShowingPattern = false;
  int sequenceLength = 3;
  bool gameStarted = false;
  String statusMessage = "Watch the pattern...";

  void selectDifficulty(String level) {
    setState(() {
      difficulty = level;
      if (level == 'easy') sequenceLength = 3;
      if (level == 'medium') sequenceLength = 4;
      if (level == 'hard') sequenceLength = 5;
    });
  }


  void showChallengeModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("The Challenge", textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF6B8E23), fontWeight: FontWeight.bold)),
        content: const Text(
          "Whilst doing this task, try as hard as you can to force the emotion you're struggling with to the forefront - as if it's a competition!",
          textAlign: TextAlign.center,
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6B8E23)),
              onPressed: () {
                Navigator.pop(context);
                setState(() => gameStarted = true);
                startRound();
              },
              child: const Text("I'm Ready - Let's Begin", style: TextStyle(color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }

  void startRound() {
    setState(() {
      userPattern = [];
      statusMessage = "Watch the pattern...";
      isShowingPattern = true;
    });

    // র‍্যান্ডম প্যাটার্ন তৈরি
    currentPattern = List.generate(sequenceLength, (_) => colors[Random().nextInt(colors.length)]);

    // প্যাটার্ন দেখানো (অ্যানিমেশন সিমুলেশন)
    Timer(const Duration(milliseconds: 500), () {
      showPatternOneByOne();
    });
  }

  void showPatternOneByOne() async {
    // এখানে আমরা UI-তে প্যাটার্নটি দেখাবো
    await Future.delayed(Duration(milliseconds: 800 * currentPattern.length + 1000));
    if (mounted) {
      setState(() {
        isShowingPattern = false;
        statusMessage = "Now repeat the pattern!";
      });
    }
  }

  void handleColorTap(Color color) {
    if (isShowingPattern) return;

    setState(() {
      userPattern.add(color);
    });

    if (userPattern.length == currentPattern.length) {
      checkPattern();
    }
  }

  void checkPattern() {
    bool isCorrect = true;
    for (int i = 0; i < currentPattern.length; i++) {
      if (userPattern[i] != currentPattern[i]) {
        isCorrect = false;
        break;
      }
    }

    if (isCorrect) {
      setState(() {
        statusMessage = "Correct! Well done.";
        if (sequenceLength > longestSequence) longestSequence = sequenceLength;
        sequenceLength++;
        currentRound++;
      });
      Future.delayed(const Duration(seconds: 2), startRound);
    } else {
      setState(() {
        statusMessage = "Not quite right. Starting over.";
        sequenceLength = (difficulty == 'easy') ? 3 : (difficulty == 'medium' ? 4 : 5);
        currentRound = 1;
      });
      Future.delayed(const Duration(seconds: 2), startRound);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5E6D3),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF5A4A42)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Pattern Memory',
          style: TextStyle(
            fontSize: 18,
            fontFamily: 'Serif',
            color: Color(0xFF5A4A42),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5E6D3), Color(0xFFE8D5C4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 40),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
                ),
                child: !gameStarted ? _buildSetupScreen() : _buildGameScreen(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSetupScreen() {
    return Column(
      children: [
        const Text("Pattern Memory", style: TextStyle(fontSize: 32, fontFamily: 'Serif', color: Color(0xFF5A4A42))),
        const Text("A Working Memory Exercise", style: TextStyle(fontStyle: FontStyle.italic, color: Color(0xFF8B7355))),
        const SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(color: const Color(0xFF6B8E23).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: const Text(
            "This working memory task occupies part of your brain whilst you hold difficult emotions in mind, helping reduce overwhelming feelings.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF5A4A42)),
          ),
        ),
        const SizedBox(height: 30),
        const Text("Choose Difficulty:", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        _difficultyBtn("Gentle (Easy)", "easy"),
        _difficultyBtn("Moderate (Medium)", "medium"),
        _difficultyBtn("Challenging (Hard)", "hard"),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: difficulty == null ? null : showChallengeModal,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6B8E23),
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: const Text("Begin Exercise", style: TextStyle(fontSize: 18, color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildGameScreen() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _scoreTile("Round", currentRound.toString()),
            _scoreTile("Longest", longestSequence.toString()),
          ],
        ),
        const SizedBox(height: 30),
        Text(statusMessage, style: TextStyle(fontSize: 20, color: isShowingPattern ? Colors.blue : Colors.green)),
        const SizedBox(height: 30),
        // প্যাটার্ন ডিসপ্লে
        Wrap(
          spacing: 10,
          children: (isShowingPattern ? currentPattern : userPattern).map((c) => _circle(c)).toList(),
        ),
        const SizedBox(height: 40),
        // কালার অপশনস
        if (!isShowingPattern)
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: colors.map((c) => GestureDetector(
              onTap: () => handleColorTap(c),
              child: _circle(c, size: 60, isButton: true),
            )).toList(),
          ),
        const SizedBox(height: 40),
        TextButton(
          onPressed: () => setState(() => gameStarted = false),
          child: const Text("Start Over", style: TextStyle(color: Colors.brown)),
        )
      ],
    );
  }

  Widget _difficultyBtn(String title, String level) {
    bool isSelected = difficulty == level;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            backgroundColor: isSelected ? const Color(0xFF4A7C9E) : Colors.transparent,
            side: const BorderSide(color: Color(0xFF4A7C9E)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          ),
          onPressed: () => selectDifficulty(level),
          child: Text(title, style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF4A7C9E))),
        ),
      ),
    );
  }

  Widget _scoreTile(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _circle(Color color, {double size = 40, bool isButton = false}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: isButton ? [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 5)] : null,
      ),
    );
  }
}