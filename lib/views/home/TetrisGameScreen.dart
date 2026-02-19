import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class TetrisGameScreen extends StatefulWidget {
  const TetrisGameScreen({super.key});

  @override
  State<TetrisGameScreen> createState() => _TetrisGameScreenState();
}

enum GameState { start, playing, paused, gameOver }

class _TetrisGameScreenState extends State<TetrisGameScreen> {
  // Game Constants
  static const int boardWidth = 10;
  static const int boardHeight = 20;
  static const double cellSize = 20.0;

  // Watercolor Palette
  final Map<String, Color> pieceColors = {
    'I': const Color(0xFF4A7C9E).withOpacity(0.7), // Blue
    'O': const Color(0xFFD4A017).withOpacity(0.7), // Yellow
    'T': const Color(0xFF8B7355).withOpacity(0.7), // Tan
    'S': const Color(0xFF6B8E23).withOpacity(0.7), // Green
    'Z': const Color(0xFFC1475B).withOpacity(0.7), // Red
    'J': const Color(0xFF5A4A42).withOpacity(0.7), // Brown
    'L': const Color(0xFF94544B).withOpacity(0.7), // Rust
  };

  // Standard Tetris Shapes
  final Map<String, List<List<int>>> shapes = {
    'I': [[1, 1, 1, 1]],
    'O': [[1, 1], [1, 1]],
    'T': [[0, 1, 0], [1, 1, 1]],
    'S': [[0, 1, 1], [1, 1, 0]],
    'Z': [[1, 1, 0], [0, 1, 1]],
    'J': [[1, 0, 0], [1, 1, 1]],
    'L': [[0, 0, 1], [1, 1, 1]],
  };

  // Game Logic Variables
  List<List<String?>> board = List.generate(boardHeight, (_) => List.filled(boardWidth, null));
  Timer? gameTimer;
  GameState gameState = GameState.start;
  int score = 0;

  // Current Piece State
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
    gameTimer = Timer.periodic(const Duration(milliseconds: 550), (timer) {
      if (gameState == GameState.playing) moveDown();
    });
  }

  void spawnPiece() {
    final keys = shapes.keys.toList();
    currentType = keys[Random().nextInt(keys.length)];
    currentPiece = shapes[currentType];
    currentX = (boardWidth / 2).floor() - (currentPiece![0].length / 2).floor();
    currentY = 0;

    if (checkCollision(currentX, currentY, currentPiece!)) {
      setState(() => gameState = GameState.gameOver);
      gameTimer?.cancel();
    }
  }

  bool checkCollision(int x, int y, List<List<int>> piece) {
    for (int row = 0; row < piece.length; row++) {
      for (int col = 0; col < piece[row].length; col++) {
        if (piece[row][col] == 1) {
          int nextX = x + col;
          int nextY = y + row;
          if (nextX < 0 || nextX >= boardWidth || nextY >= boardHeight || (nextY >= 0 && board[nextY][nextX] != null)) {
            return true;
          }
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

  void lockPiece() {
    for (int row = 0; row < currentPiece!.length; row++) {
      for (int col = 0; col < currentPiece![row].length; col++) {
        if (currentPiece![row][col] == 1) {
          board[currentY + row][currentX + col] = currentType;
        }
      }
    }
    clearLines();
    spawnPiece();
  }

  void clearLines() {
    int linesCleared = 0;
    for (int row = boardHeight - 1; row >= 0; row--) {
      if (board[row].every((cell) => cell != null)) {
        board.removeAt(row);
        board.insert(0, List.filled(boardWidth, null));
        linesCleared++;
        row++;
      }
    }
    if (linesCleared > 0) score += (linesCleared * 100);
  }

  void rotatePiece() {
    if (currentPiece == null) return;
    List<List<int>> rotated = List.generate(
      currentPiece![0].length,
          (j) => List.generate(currentPiece!.length, (i) => currentPiece![currentPiece!.length - 1 - i][j]),
    );
    if (!checkCollision(currentX, currentY, rotated)) {
      setState(() => currentPiece = rotated);
    }
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E6D3),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Watercolor Tetris", style: TextStyle(fontSize: 24, fontFamily: 'Georgia', color: Color(0xFF5A4A42))),
                  Text("Score: $score", style: TextStyle(fontSize: 16, color: Color(0xFF8B7355))),
                  const SizedBox(height: 15),
                  GestureDetector(
                    onTap: rotatePiece,
                    child: Container(
                      width: boardWidth * cellSize,
                      height: boardHeight * cellSize,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF5EB),
                        border: Border.all(color: Colors.brown.withOpacity(0.2)),
                      ),
                      child: Stack(
                        children: [
                          _buildBoard(),
                          if (currentPiece != null && gameState == GameState.playing) _buildCurrentPiece(),
                          if (gameState == GameState.start || gameState == GameState.gameOver) _buildOverlay(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildControls(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBoard() {
    return SizedBox(
      width: boardWidth * cellSize,
      height: boardHeight * cellSize,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(boardHeight, (y) => Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(boardWidth, (x) => Container(
            width: cellSize,
            height: cellSize,
            decoration: BoxDecoration(
              color: board[y][x] != null ? pieceColors[board[y][x]] : Colors.transparent,
              border: Border.all(color: Colors.black.withOpacity(0.05), width: 0.5),
            ),
          )),
        )),
      ),
    );
  }

  Widget _buildCurrentPiece() {
    return Positioned(
      left: currentX * cellSize,
      top: currentY * cellSize,
      child: Column(
        children: List.generate(currentPiece!.length, (y) => Row(
          children: List.generate(currentPiece![y].length, (x) => Container(
            width: cellSize,
            height: cellSize,
            decoration: BoxDecoration(
              color: currentPiece![y][x] == 1 ? pieceColors[currentType] : Colors.transparent,
            ),
          )),
        )),
      ),
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(icon: const Icon(Icons.arrow_left), onPressed: () => setState(() { if(!checkCollision(currentX-1, currentY, currentPiece!)) currentX--; })),
        IconButton(icon: const Icon(Icons.arrow_drop_down), onPressed: moveDown),
        IconButton(icon: const Icon(Icons.arrow_right), onPressed: () => setState(() { if(!checkCollision(currentX+1, currentY, currentPiece!)) currentX++; })),
        const SizedBox(width: 20),
        IconButton(icon: const Icon(Icons.rotate_right), onPressed: rotatePiece),
      ],
    );
  }

  Widget _buildOverlay() {
    return Container(
      color: Colors.white.withOpacity(0.8),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(gameState == GameState.start ? "Ready to Focus?" : "Game Over",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF5A4A42))),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: startGame,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B7355)),
              child: Text(gameState == GameState.start ? "Start Game" : "Try Again", style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}