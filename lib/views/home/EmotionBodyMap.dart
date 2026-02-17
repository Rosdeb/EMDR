import 'package:flutter/material.dart';

class EmotionBodyMap extends StatefulWidget {
  const EmotionBodyMap({super.key});

  @override
  State<EmotionBodyMap> createState() => _EmotionBodyMapState();
}

class _EmotionBodyMapState extends State<EmotionBodyMap> {
  Color _selectedColor = const Color(0xFFE57373);
  double _brushSize = 10.0;
  bool _isEraser = false;
  final Map<String, List<DrawingPoint?>> _emotionPoints = {
    'Anxiety': [],
    'Sadness': [],
    'Anger': [],
    'Pain/Hurt': [],
    'Happiness': [],
    'Custom': [],
  };

  final List<Color> _palette = [
    const Color(0xFFE57373), const Color(0xFF81C784), const Color(0xFFFFB74D),
    const Color(0xFF64B5F6), const Color(0xFFBA68C8), const Color(0xFF4DB6AC),
    const Color(0xFFFF8A65), const Color(0xFFA1887F), const Color(0xFF90A4AE),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        title: const Text("INKIND EMDR", style: TextStyle(letterSpacing: 2, fontSize: 12, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            _buildPalette(),
            _buildBrushSettings(),
            _buildCanvasGrid(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const Text("Where Do You Feel It?", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF2C5F2D))),
          const SizedBox(height: 10),
          Text(
            "Draw the shape and color of your emotions in the body maps below.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[700], fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPalette() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.black12)),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: [
          ..._palette.map((color) => GestureDetector(
            onTap: () => setState(() { _selectedColor = color; _isEraser = false; }),
            child: Container(
              width: 35, height: 35,
              decoration: BoxDecoration(
                color: color, shape: BoxShape.circle,
                border: Border.all(color: _selectedColor == color && !_isEraser ? Colors.black : Colors.transparent, width: 2),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
            ),
          )),
          // Eraser Button
          GestureDetector(
            onTap: () => setState(() => _isEraser = !_isEraser),
            child: Container(
              width: 35, height: 35,
              decoration: BoxDecoration(
                color: _isEraser ? Colors.green[100] : Colors.grey[200],
                shape: BoxShape.circle,
                border: Border.all(color: _isEraser ? Colors.green : Colors.transparent, width: 2),
              ),
              child: const Icon(Icons.cleaning_services, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrushSettings() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const Text("Brush Size", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          Expanded(
            child: Slider(
              value: _brushSize,
              min: 5, max: 30,
              activeColor: const Color(0xFF81C784),
              onChanged: (v) => setState(() => _brushSize = v),
            ),
          ),
          TextButton(
            onPressed: () => setState(() => _emotionPoints.forEach((k, v) => v.clear())),
            child: const Text("Clear All", style: TextStyle(color: Colors.redAccent)),
          )
        ],
      ),
    );
  }

  Widget _buildCanvasGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, childAspectRatio: 0.55, crossAxisSpacing: 15, mainAxisSpacing: 15,
      ),
      itemCount: _emotionPoints.length,
      itemBuilder: (context, index) {
        String key = _emotionPoints.keys.elementAt(index);
        return _buildSingleBodyCanvas(key);
      },
    );
  }

  Widget _buildSingleBodyCanvas(String emotion) {
    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _emotionPoints[emotion]!.add(DrawingPoint(
                      offset: details.localPosition,
                      paint: Paint()
                        ..color = _isEraser ? Colors.white : _selectedColor.withOpacity(0.6)
                        ..strokeWidth = _brushSize
                        ..strokeCap = StrokeCap.round
                        ..blendMode = _isEraser ? BlendMode.clear : BlendMode.srcOver,
                    ));
                  });
                },
                onPanEnd: (_) => _emotionPoints[emotion]!.add(null),
                child: CustomPaint(
                  size: Size.infinite,
                  painter: BodyMapPainter(points: _emotionPoints[emotion]!),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(emotion, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2C5F2D))),
      ],
    );
  }
}

class DrawingPoint {
  Offset offset; Paint paint;
  DrawingPoint({required this.offset, required this.paint});
}

class BodyMapPainter extends CustomPainter {
  final List<DrawingPoint?> points;
  BodyMapPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!.offset, points[i + 1]!.offset, points[i]!.paint);
      }
    }
    canvas.restore();
    final paintOutline = Paint()
      ..color = Colors.black38
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    double w = size.width;
    double h = size.height;

    // Head
    canvas.drawCircle(Offset(w / 2, h * 0.15), h * 0.07, paintOutline);
    // Torso
    Path body = Path();
    body.moveTo(w * 0.35, h * 0.22);
    body.lineTo(w * 0.65, h * 0.22);
    body.lineTo(w * 0.75, h * 0.55);
    body.lineTo(w * 0.25, h * 0.55);
    body.close();
    canvas.drawPath(body, paintOutline);
    // Arms & Legs
    canvas.drawLine(Offset(w * 0.35, h * 0.22), Offset(w * 0.15, h * 0.5), paintOutline);
    canvas.drawLine(Offset(w * 0.65, h * 0.22), Offset(w * 0.85, h * 0.5), paintOutline);
    canvas.drawLine(Offset(w * 0.35, h * 0.55), Offset(w * 0.3, h * 0.9), paintOutline);
    canvas.drawLine(Offset(w * 0.65, h * 0.55), Offset(w * 0.7, h * 0.9), paintOutline);
  }

  @override
  bool shouldRepaint(BodyMapPainter oldDelegate) => true;
}