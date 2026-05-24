import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Displays a bundled GIF/WebP with near-white backgrounds keyed out.
class WhiteKeyAssetImage extends StatefulWidget {
  const WhiteKeyAssetImage({
    super.key,
    required this.assetPath,
    this.fit = BoxFit.contain,
    this.width,
    this.height,
    this.enabled = true,
  });

  final String assetPath;
  final BoxFit fit;
  final double? width;
  final double? height;
  final bool enabled;

  @override
  State<WhiteKeyAssetImage> createState() => _WhiteKeyAssetImageState();
}

class _WhiteKeyAssetImageState extends State<WhiteKeyAssetImage> {
  static Future<ui.FragmentProgram>? _programFuture;
  ui.FragmentProgram? _program;

  @override
  void initState() {
    super.initState();
    if (widget.enabled) {
      _loadShader();
    }
  }

  @override
  void didUpdateWidget(covariant WhiteKeyAssetImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled && !oldWidget.enabled && _program == null) {
      _loadShader();
    }
  }

  void _loadShader() {
    _programFuture ??= ui.FragmentProgram.fromAsset('shaders/white_key.frag');
    _programFuture!.then((program) {
      if (mounted) setState(() => _program = program);
    }).catchError((_) {});
  }

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      widget.assetPath,
      fit: widget.fit,
      width: widget.width,
      height: widget.height,
      gaplessPlayback: true,
      filterQuality: FilterQuality.medium,
      errorBuilder: (context, error, stackTrace) => Icon(
        Icons.broken_image_outlined,
        size: (widget.width ?? widget.height ?? 48) * 0.45,
        color: Colors.white70,
      ),
    );

    final program = _program;
    if (!widget.enabled || program == null) return image;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = widget.width ??
            (constraints.maxWidth.isFinite ? constraints.maxWidth : 1.0);
        final height = widget.height ??
            (constraints.maxHeight.isFinite ? constraints.maxHeight : 1.0);

        final shader = program.fragmentShader()
          ..setFloat(0, width)
          ..setFloat(1, height);

        return ImageFiltered(
          imageFilter: ui.ImageFilter.shader(shader),
          child: image,
        );
      },
    );
  }
}
