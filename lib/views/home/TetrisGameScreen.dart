import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TetrisGameScreen extends StatefulWidget {
  const TetrisGameScreen({super.key});

  @override
  State<TetrisGameScreen> createState() => _TetrisGameScreenState();
}

enum GameState { start, playing, paused, gameOver }

class _TetrisGameScreenState extends State<TetrisGameScreen> {
  static const int boardWidth = 10;
  static const int boardHeight = 20;
  static const double boardAspectRatio = boardWidth / boardHeight; // 0.5

  final Map<String, Color> pieceColors = {
    'I': Color(0xFF4A7C9E),
    'O': Color(0xFFD4A017),
    'T': Color(0xFF8B7355),
    'S': Color(0xFF6B8E23),
    'Z': Color(0xFFC1475B),
    'J': Color(0xFF5A4A42),
    'L': Color(0xFF94544B),
  };

  final Map<String, List<List<int>>> shapes = {
    'I': [[1, 1, 1, 1]],
    'O': [[1, 1], [1, 1]],
    'T': [[0, 1, 0], [1, 1, 1]],
    'S': [[0, 1, 1], [1, 1, 0]],
    'Z': [[1, 1, 0], [0, 1, 1]],
    'J': [[1, 0, 0], [1, 1, 1]],
    'L': [[0, 0, 1], [1, 1, 1]],
  };

  List<List<String?>> board =
  List.generate(boardHeight, (_) => List.filled(boardWidth, null));
  Timer? gameTimer;
  GameState gameState = GameState.start;
  int score = 0;
  int highScore = 0;

  List<List<int>>? currentPiece;
  String? currentType;
  int currentX = 0;
  int currentY = 0;

  void startGame() {
    setState(() {
      board = List.generate(boardHeight, (_) => List.filled(boardWidth, null));
      score = 0;
      gameState = GameState.playing;
      spawnPiece();
    });
    gameTimer?.cancel();
    gameTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (gameState == GameState.playing) moveDown();
    });
  }

  void togglePause() {
    setState(() {
      if (gameState == GameState.playing) {
        gameState = GameState.paused;
        gameTimer?.cancel();
      } else if (gameState == GameState.paused) {
        gameState = GameState.playing;
        gameTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
          if (gameState == GameState.playing) moveDown();
        });
      }
    });
  }

  void spawnPiece() {
    final keys = shapes.keys.toList();
    currentType = keys[Random().nextInt(keys.length)];
    currentPiece = shapes[currentType];
    currentX = (boardWidth / 2).floor() - (currentPiece![0].length / 2).floor();
    currentY = 0;
    if (checkCollision(currentX, currentY, currentPiece!)) {
      if (score > highScore) highScore = score;
      setState(() => gameState = GameState.gameOver);
      gameTimer?.cancel();
    }
  }

  bool checkCollision(int x, int y, List<List<int>> piece) {
    for (int r = 0; r < piece.length; r++) {
      for (int c = 0; c < piece[r].length; c++) {
        if (piece[r][c] == 1) {
          final nx = x + c;
          final ny = y + r;
          if (nx < 0 || nx >= boardWidth || ny >= boardHeight ||
              (ny >= 0 && board[ny][nx] != null)) return true;
        }
      }
    }
    return false;
  }

  void moveDown() {
    setState(() {
      if (!checkCollision(currentX, currentY + 1, currentPiece!)) {
        currentY++;
      } else {
        lockPiece();
      }
    });
  }

  void moveLeft() {
    if (gameState != GameState.playing) return;
    setState(() {
      if (!checkCollision(currentX - 1, currentY, currentPiece!)) currentX--;
    });
  }

  void moveRight() {
    if (gameState != GameState.playing) return;
    setState(() {
      if (!checkCollision(currentX + 1, currentY, currentPiece!)) currentX++;
    });
  }

  void hardDrop() {
    if (gameState != GameState.playing) return;
    setState(() {
      while (!checkCollision(currentX, currentY + 1, currentPiece!)) currentY++;
      lockPiece();
    });
  }

  void rotatePiece() {
    if (currentPiece == null || gameState != GameState.playing) return;
    final rotated = List.generate(
      currentPiece![0].length,
          (j) => List.generate(
          currentPiece!.length,
              (i) => currentPiece![currentPiece!.length - 1 - i][j]),
    );
    if (!checkCollision(currentX, currentY, rotated)) {
      setState(() => currentPiece = rotated);
    }
  }

  void lockPiece() {
    for (int r = 0; r < currentPiece!.length; r++) {
      for (int c = 0; c < currentPiece![r].length; c++) {
        if (currentPiece![r][c] == 1 && currentY + r >= 0) {
          board[currentY + r][currentX + c] = currentType;
        }
      }
    }
    clearLines();
    spawnPiece();
  }

  void clearLines() {
    int cleared = 0;
    for (int r = boardHeight - 1; r >= 0; r--) {
      if (board[r].every((c) => c != null)) {
        board.removeAt(r);
        board.insert(0, List.filled(boardWidth, null));
        cleared++;
        r++;
      }
    }
    const pts = [0, 100, 300, 500, 800];
    if (cleared > 0) score += pts[cleared.clamp(0, 4)];
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return Scaffold(
      backgroundColor: const Color(0xFFF5E6D3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5E6D3),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF5A4A42)),
          onPressed: () {
            gameTimer?.cancel();
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Watercolor Tetris',
          style: TextStyle(
            fontSize: 20,
            fontFamily: 'Georgia',
            color: Color(0xFF5A4A42),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          if (gameState == GameState.playing || gameState == GameState.paused)
            IconButton(
              icon: Icon(
                gameState == GameState.paused
                    ? Icons.play_arrow_rounded
                    : Icons.pause_rounded,
                color: const Color(0xFF5A4A42),
              ),
              onPressed: togglePause,
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Score Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _scoreBox('SCORE', score),
                  _scoreBox('BEST', highScore),
                ],
              ),
            ),

            // Board — fills all remaining vertical space
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Center(
                  // AspectRatio ensures board is always 1:2 (w:h)
                  // and never overflows either axis
                  child: AspectRatio(
                    aspectRatio: boardAspectRatio,
                    child: GestureDetector(
                      onTap: rotatePiece,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAF5EB),
                          border: Border.all(
                              color: Colors.brown.withOpacity(0.25),
                              width: 1.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: LayoutBuilder(builder: (ctx, bc) {
                          // cell dimensions derived from actual rendered size
                          final cw = bc.maxWidth / boardWidth;
                          final ch = bc.maxHeight / boardHeight;
                          return Stack(children: [
                            _buildBoard(cw, ch),
                            if (currentPiece != null &&
                                gameState == GameState.playing)
                              _buildCurrentPiece(cw, ch),
                            if (gameState != GameState.playing)
                              _buildOverlay(),
                          ]);
                        }),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),
            _buildControls(),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _scoreBox(String label, int value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.brown.withOpacity(0.15)),
      ),
      child: Column(children: [
        Text(label,
            style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF8B7355),
                fontWeight: FontWeight.w600,
                letterSpacing: 1)),
        Text('$value',
            style: const TextStyle(
                fontSize: 22,
                color: Color(0xFF5A4A42),
                fontWeight: FontWeight.bold)),
      ]),
    );
  }

  Widget _buildBoard(double cw, double ch) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        boardHeight,
            (y) => SizedBox(
          height: ch,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              boardWidth,
                  (x) => Container(
                width: cw,
                height: ch,
                decoration: BoxDecoration(
                  color: board[y][x] != null
                      ? pieceColors[board[y][x]]!.withOpacity(0.75)
                      : Colors.transparent,
                  border: Border.all(
                      color: Colors.black.withOpacity(0.04), width: 0.5),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentPiece(double cw, double ch) {
    return Positioned(
      left: currentX * cw,
      top: currentY * ch,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          currentPiece!.length,
              (y) => Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              currentPiece![y].length,
                  (x) => Container(
                width: cw,
                height: ch,
                color: currentPiece![y][x] == 1
                    ? pieceColors[currentType]!.withOpacity(0.75)
                    : Colors.transparent,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverlay() {
    final isGameOver = gameState == GameState.gameOver;
    final isPaused = gameState == GameState.paused;
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(
              isPaused ? '⏸ Paused' : isGameOver ? 'Game Over' : 'Ready to Focus?',
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Georgia',
                  color: Color(0xFF5A4A42)),
            ),
            if (isGameOver) ...[
              const SizedBox(height: 8),
              Text('Score: $score',
                  style: const TextStyle(fontSize: 16, color: Color(0xFF8B7355))),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isPaused ? togglePause : startGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B7355),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Text(
                isPaused ? 'Resume' : isGameOver ? 'Try Again' : 'Start Game',
                style: const TextStyle(
                    color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.brown.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ctrlBtn(Icons.arrow_left_rounded, moveLeft),
          _ctrlBtn(Icons.arrow_drop_down_rounded, moveDown),
          _ctrlBtn(Icons.arrow_right_rounded, moveRight),
          Container(width: 1, height: 28, color: Colors.brown.withOpacity(0.2)),
          _ctrlBtn(Icons.rotate_right_rounded, rotatePiece),
          _ctrlBtn(Icons.vertical_align_bottom_rounded, hardDrop),
        ],
      ),
    );
  }

  Widget _ctrlBtn(IconData icon, VoidCallback onPressed) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Icon(icon, size: 30, color: const Color(0xFF5A4A42)),
      ),
    );
  }
}