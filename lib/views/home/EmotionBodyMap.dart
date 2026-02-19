import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:saver_gallery/saver_gallery.dart';

import 'package:permission_handler/permission_handler.dart';

class EmotionBodyMap extends StatefulWidget {
  const EmotionBodyMap({super.key});

  @override
  State<EmotionBodyMap> createState() => _EmotionBodyMapState();
}

class _EmotionBodyMapState extends State<EmotionBodyMap> {
  Color _selectedColor = const Color(0xFFE57373);
  double _brushSize = 8.0;
  bool _isEraser = false;
  bool _isToolsExpanded = true;
  bool _isSaving = false;

  final GlobalKey _repaintKey = GlobalKey();

  final Map<String, List<DrawingPoint?>> _emotionPoints = {
    'Anxiety': [],
    'Sadness': [],
    'Anger': [],
    'Pain/Hurt': [],
    'Happiness': [],
    'Your emotion': [],
  };

  final List<Color> _palette = [
    const Color(0xFFD9665B), const Color(0xFF81B384), const Color(0xFFFBB03B),
    const Color(0xFF6FB9F6), const Color(0xFFBC71C8), const Color(0xFF53B6A9),
    const Color(0xFFFF8B66), const Color(0xFFA1887F), const Color(0xFF90A4AE),
    const Color(0xFFAED581), const Color(0xFFF06292), const Color(0xFF9575CD),
  ];

  Future<void> _saveMap() async {
    setState(() => _isSaving = true);

    try {
      // Android permission check (Android 13+ uses READ_MEDIA_IMAGES, older uses WRITE_EXTERNAL_STORAGE)
      final photosStatus = await Permission.photos.status;
      final storageStatus = await Permission.storage.status;

      if (photosStatus.isDenied) {
        await Permission.photos.request();
      }
      if (storageStatus.isDenied) {
        await Permission.storage.request();
      }

      // Re-check after request
      final photosGranted = await Permission.photos.isGranted;
      final storageGranted = await Permission.storage.isGranted;

      if (!photosGranted && !storageGranted) {
        _showSnack('Storage permission denied', isError: true);
        return;
      }

      // RepaintBoundary থেকে image capture
      final boundary = _repaintKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        _showSnack('Could not capture canvas', isError: true);
        return;
      }

      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        _showSnack('Failed to encode image', isError: true);
        return;
      }

      final bytes = byteData.buffer.asUint8List();

      // Gallery তে save
      final result = await SaverGallery.saveImage(
        bytes,
        quality: 95,
        fileName: 'emotion_body_map_${DateTime.now().millisecondsSinceEpoch}.png',
        androidRelativePath: 'Pictures/EmotionBodyMap',
        skipIfExists: false,
      );

      if (result.isSuccess) {
        _showSnack('✅ Map saved to Gallery!');
      } else {
        _showSnack('Failed to save image', isError: true);
      }
    } catch (e) {
      _showSnack('Error: $e', isError: true);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red[700] : const Color(0xFF4C6D4F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8F1),
      appBar: AppBar(
        title: const Text("INKIND EMDR", style: TextStyle(letterSpacing: 2, fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                _buildTitleSection(),
                _buildInstructionBox(),
                RepaintBoundary(
                  key: _repaintKey,
                  child: Container(
                    color: const Color(0xFFF1F8F1),
                    child: _buildCanvasGrid(),
                  ),
                ),
                const SizedBox(height: 250),
              ],
            ),
          ),
          _buildFloatingDrawingTools(),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      child: Column(
        children: [
          Text("Where Do You Feel It?",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w500, color: Color(0xFF3D5A40), fontFamily: 'Serif')),
          SizedBox(height: 15),
          Text(
            "Your body holds emotions in different places. Draw each emotion's shape and colour - it might be a tight knot, a swirling cloud, heavy blocks, or flowing waves.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Color(0xFF5D7A60), fontStyle: FontStyle.italic, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionBox() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F3E8),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("HOW TO USE THIS TOOL:", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6B8E6D), fontSize: 13)),
          const SizedBox(height: 10),
          _stepText("1. Pick a colour from the palette that feels right for each emotion"),
          _stepText("2. Draw the emotion inside each body - show its shape, size, and where it lives"),
          _stepText("3. Your emotions might be swirls, blocks, waves, or any shape that feels true"),
          _stepText("4. Layer different colours to show how emotions overlap or change"),
        ],
      ),
    );
  }

  Widget _stepText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: const TextStyle(fontSize: 13, color: Color(0xFF5D7A60), height: 1.3)),
    );
  }

  Widget _buildFloatingDrawingTools() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.all(15),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => setState(() => _isToolsExpanded = !_isToolsExpanded),
              child: Row(
                children: [
                  CircleAvatar(backgroundColor: _selectedColor, radius: 12),
                  const SizedBox(width: 15),
                  const Text("Drawing Tools", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3D5A40))),
                  const Spacer(),
                  Icon(_isToolsExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up),
                ],
              ),
            ),
            if (_isToolsExpanded) ...[
              const Divider(height: 30),
              const Align(alignment: Alignment.centerLeft, child: Text("PALETTE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey))),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10, runSpacing: 10,
                children: _palette.map((color) => GestureDetector(
                  onTap: () => setState(() { _selectedColor = color; _isEraser = false; }),
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    child: _selectedColor == color && !_isEraser ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
                  ),
                )).toList(),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text("BRUSH SETTINGS", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const Spacer(),
                  Text("${_brushSize.toInt()}px", style: const TextStyle(fontSize: 10)),
                ],
              ),
              Slider(
                value: _brushSize, min: 2, max: 30,
                activeColor: const Color(0xFF4C6D4F),
                onChanged: (v) => setState(() => _brushSize = v),
              ),
              Row(
                children: [
                  _toolButton("Eraser", Icons.cleaning_services_outlined, () => setState(() => _isEraser = true), isEraser: _isEraser),
                  const SizedBox(width: 10),
                  _toolButton("Clear All", Icons.delete_outline, () => setState(() => _emotionPoints.forEach((k, v) => v.clear())), color: Colors.red[50], textColor: Colors.red),
                  const SizedBox(width: 10),
                  _toolButton(
                    _isSaving ? "Saving..." : "Save Map",
                    _isSaving ? Icons.hourglass_top_outlined : Icons.download_outlined,
                    _isSaving ? () {} : _saveMap,
                    isPrimary: true,
                  ),
                ],
              )
            ]
          ],
        ),
      ),
    );
  }

  Widget _toolButton(String label, IconData icon, VoidCallback onTap, {bool isEraser = false, bool isPrimary = false, Color? color, Color? textColor}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isPrimary ? const Color(0xFF4C6D4F) : (color ?? const Color(0xFFF5F9F5)),
            borderRadius: BorderRadius.circular(15),
            border: isEraser ? Border.all(color: const Color(0xFF4C6D4F)) : null,
          ),
          child: Column(
            children: [
              Icon(icon, size: 20, color: isPrimary ? Colors.white : (textColor ?? const Color(0xFF4C6D4F))),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isPrimary ? Colors.white : (textColor ?? const Color(0xFF4C6D4F)))),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildCanvasGrid() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _emotionPoints.length,
      itemBuilder: (context, index) {
        String key = _emotionPoints.keys.elementAt(index);
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: _buildSingleBodyCanvas(key),
        );
      },
    );
  }
  Widget _buildSingleBodyCanvas(String emotion) {
    return Column(
      children: [
        Container(
          height: 450,
          width: 300,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
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
                painter: BodyMapPainter(points: _emotionPoints[emotion]!),
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black12),
          ),
          child: Text(emotion, style: const TextStyle(fontWeight: FontWeight.w400, color: Color(0xFFD9665B), fontStyle: FontStyle.italic)),
        ),
      ],
    );
  }
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
      ..color = const Color(0xFF3D5A40).withOpacity(0.4)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    double w = size.width;
    double h = size.height;

    canvas.drawCircle(Offset(w * 0.5, h * 0.15), h * 0.06, paintOutline);
    canvas.drawCircle(Offset(w * 0.47, h * 0.14), 1.5, paintOutline);
    canvas.drawCircle(Offset(w * 0.53, h * 0.14), 1.5, paintOutline);

    canvas.drawArc(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.165), width: w * 0.05, height: h * 0.02),
      0, 3.14, false, paintOutline,
    );

    Path bodyPath = Path();
    bodyPath.moveTo(w * 0.5, h * 0.21);
    bodyPath.lineTo(w * 0.35, h * 0.23);
    bodyPath.quadraticBezierTo(w * 0.20, h * 0.45, w * 0.30, h * 0.75);
    bodyPath.lineTo(w * 0.33, h * 0.75);
    bodyPath.quadraticBezierTo(w * 0.25, h * 0.45, w * 0.38, h * 0.23);
    bodyPath.lineTo(w * 0.38, h * 0.65);
    bodyPath.lineTo(w * 0.38, h * 0.90);
    bodyPath.quadraticBezierTo(w * 0.40, h * 0.93, w * 0.45, h * 0.90);
    bodyPath.lineTo(w * 0.45, h * 0.70);
    bodyPath.lineTo(w * 0.55, h * 0.70);
    bodyPath.lineTo(w * 0.55, h * 0.90);
    bodyPath.quadraticBezierTo(w * 0.60, h * 0.93, w * 0.65, h * 0.90);
    bodyPath.lineTo(w * 0.65, h * 0.65);
    bodyPath.lineTo(w * 0.62, h * 0.23);
    bodyPath.quadraticBezierTo(w * 0.75, h * 0.45, w * 0.67, h * 0.75);
    bodyPath.lineTo(w * 0.70, h * 0.75);
    bodyPath.quadraticBezierTo(w * 0.85, h * 0.45, w * 0.65, h * 0.23);
    bodyPath.close();
    canvas.drawPath(bodyPath, paintOutline);
  }

  @override
  bool shouldRepaint(BodyMapPainter oldDelegate) => true;
}
class DrawingPoint {
  Offset offset;
  Paint paint;
  DrawingPoint({required this.offset, required this.paint});
}
