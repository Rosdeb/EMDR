import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class StroopTestScreen extends StatefulWidget {
  const StroopTestScreen({super.key});

  @override
  State<StroopTestScreen> createState() => _StroopTestScreenState();
}

class _StroopTestScreenState extends State<StroopTestScreen> {
  // Game Configuration [cite: 319-325, 328]
  final List<String> _words = ['RED', 'BLUE', 'GREEN', 'YELLOW'];
  final Map<String, Color> _colors = {
    'RED': const Color(0xFFC1475B),
    'BLUE': const Color(0xFF4A7C9E),
    'GREEN': const Color(0xFF6B8E23),
    'YELLOW': const Color(0xFFD4A017),
  };

  // Game State [cite: 326-331]
  int _currentRound = 0;
  int _correctAnswers = 0;
  final int _totalRounds = 10;
  String _displayWord = "";
  Color _displayColor = Colors.black;
  String _targetColorName = "";

  bool _gameStarted = false;
  bool _isFinished = false;
  bool _buttonsDisabled = false;
  String _feedbackText = "";
  Color _feedbackColor = Colors.transparent;

  // Timer [cite: 330-331]
  Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  String _elapsedTime = "0.0s";

  void _startGame() {
    setState(() {
      _gameStarted = true;
      _isFinished = false;
      _currentRound = 0;
      _correctAnswers = 0;
      _stopwatch.reset();
      _stopwatch.start();
      _startTimer();
      _nextRound();
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _elapsedTime = "${(_stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(1)}s";
      });
    });
  }

  void _nextRound() {
    if (_currentRound >= _totalRounds) {
      _endGame();
      return;
    }

    final random = Random();
    int wordIndex = random.nextInt(_words.length);
    int colorIndex;

    // 70% chance to make the color different from the word for "mental friction" [cite: 350-352]
    do {
      colorIndex = random.nextInt(_words.length);
    } while (colorIndex == wordIndex && random.nextDouble() > 0.3);

    setState(() {
      _currentRound++;
      _displayWord = _words[wordIndex];
      _targetColorName = _words[colorIndex];
      _displayColor = _colors[_targetColorName]!;
      _feedbackText = "";
      _buttonsDisabled = false;
    });
  }

  void _checkAnswer(String selectedColorName) {
    if (_buttonsDisabled) return;

    setState(() {
      _buttonsDisabled = true;
      if (selectedColorName == _targetColorName) {
        _correctAnswers++;
        _feedbackText = "✓ Correct!";
        _feedbackColor = const Color(0xFF6B8E23); // [cite: 217]
      } else {
        _feedbackText = "✗ Not quite - it was $_targetColorName";
        _feedbackColor = const Color(0xFFC1475B); // [cite: 220]
      }
    });

    // Brief delay before next round [cite: 384-387]
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) _nextRound();
    });
  }

  void _endGame() {
    _stopwatch.stop();
    _timer?.cancel();
    setState(() {
      _isFinished = true;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E6D3), // [cite: 15]
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 30),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9), // [cite: 24]
              borderRadius: BorderRadius.circular(3),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
              ],
            ),
            child: _gameStarted ? (_isFinished ? _buildResults() : _buildGame()) : _buildInstructions(),
          ),
        ),
      ),
    );
  }

  // UI Components matching the notebook style [cite: 79-113]
  Widget _buildInstructions() {
    return Column(
      children: [
        const Text("The Stroop Test", style: TextStyle(fontSize: 32, fontFamily: 'Georgia', color: Color(0xFF5A4A42))),
        const Text("A Focus & Attention Exercise", style: TextStyle(fontStyle: FontStyle.italic, color: Color(0xFF8B7355))),
        const SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
            border: Border.all(color: const Color(0xFF8B7355).withOpacity(0.2), width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text(
            "Look at the colour the word is displayed in (not the word itself), then select the matching colour button below.\n\n"
                "This creates mental friction - a workout for your brain's ability to focus.",
            textAlign: TextAlign.center,
            style: TextStyle(height: 1.6, color: Color(0xFF5A4A42)),
          ),
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: _startGame,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6B8E23),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          ),
          child: const Text("Begin Exercise", style: TextStyle(color: Colors.white, fontSize: 18)),
        ),
      ],
    );
  }

  Widget _buildGame() {
    return Column(
      children: [
        // Score Board [cite: 170-192]
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _scoreItem("Round", "$_currentRound/$_totalRounds"),
            _scoreItem("Correct", "$_correctAnswers"),
            _scoreItem("Time", _elapsedTime),
          ],
        ),
        const SizedBox(height: 40),
        // Word Display [cite: 119-126]
        Text(
          _displayWord,
          style: TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.bold,
            fontFamily: 'Georgia',
            color: _displayColor,
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 40),
        // Color Buttons [cite: 127-169]
        Wrap(
          spacing: 15,
          runSpacing: 15,
          alignment: WrapAlignment.center,
          children: _words.map((colorName) {
            return OutlinedButton(
              onPressed: _buttonsDisabled ? null : () => _checkAnswer(colorName),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: _colors[colorName]!, width: 3),
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
              child: Text(
                colorName,
                style: TextStyle(color: _colors[colorName], fontWeight: FontWeight.bold, fontSize: 18),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 30),
        Text(_feedbackText, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _feedbackColor)),
      ],
    );
  }

  Widget _buildResults() {
    double accuracy = (_correctAnswers / _totalRounds) * 100; // [cite: 392]
    return Column(
      children: [
        const Icon(Icons.stars, color: Color(0xFF6B8E23), size: 80),
        const SizedBox(height: 20),
        const Text("Well Done!", style: TextStyle(fontSize: 28, fontFamily: 'Georgia', color: Color(0xFF6B8E23))),
        const SizedBox(height: 20),
        Text(
          "You got $_correctAnswers out of $_totalRounds correct (${accuracy.toStringAsFixed(0)}% accuracy) in $_elapsedTime.", // [cite: 397]
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, color: Color(0xFF5A4A42)),
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: _startGame,
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6B8E23)),
          child: const Text("Try Again", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _scoreItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF8B7355))),
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF5A4A42))),
      ],
    );
  }
}