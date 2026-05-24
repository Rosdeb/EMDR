// ignore_for_file: deprecated_member_use, curly_braces_in_flow_control_structures

import 'dart:math';
import 'package:flutter/material.dart';
import '../models/app_theme.dart';

// ─────────────────────────────────────────────────────────
//  BILATERAL OBJECT PAINTER  — 28 animated objects
// ─────────────────────────────────────────────────────────
class ObjectPainter extends CustomPainter {
  final BilateralObject type;
  final double t; // elapsed ms
  final double x, y; // center in pixels
  final double vx; // direction

  ObjectPainter({
    required this.type,
    required this.t,
    required this.x,
    required this.y,
    required this.vx,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(x, y);
    switch (type) {
      case BilateralObject.orb:
        _drawOrb(canvas);
        break;
      case BilateralObject.plasma:
        _drawPlasma(canvas);
        break;
      case BilateralObject.pulsar:
        _drawPulsar(canvas);
        break;
      case BilateralObject.sunbeam:
        _drawSunbeam(canvas);
        break;
      case BilateralObject.star:
        _drawStar(canvas);
        break;
      case BilateralObject.comet:
        _drawComet(canvas);
        break;
      case BilateralObject.galaxy:
        _drawGalaxy(canvas);
        break;
      case BilateralObject.nebula:
        _drawNebula(canvas);
        break;
      case BilateralObject.blackhole:
        _drawBlackhole(canvas);
        break;
      case BilateralObject.butterfly:
        _drawButterfly(canvas);
        break;
      case BilateralObject.lotus:
        _drawLotus(canvas);
        break;
      case BilateralObject.feather:
        _drawFeather(canvas);
        break;
      case BilateralObject.flame:
        _drawFlame(canvas);
        break;
      case BilateralObject.snowflake:
        _drawSnowflake(canvas);
        break;
      case BilateralObject.leaf:
        _drawLeaf(canvas);
        break;
      case BilateralObject.dandelion:
        _drawDandelion(canvas);
        break;
      case BilateralObject.crystal:
        _drawCrystal(canvas);
        break;
      case BilateralObject.diamond:
        _drawDiamond(canvas);
        break;
      case BilateralObject.prism:
        _drawPrism(canvas);
        break;
      case BilateralObject.geode:
        _drawGeode(canvas);
        break;
      case BilateralObject.jellyfish:
        _drawJellyfish(canvas);
        break;
      case BilateralObject.droplet:
        _drawDroplet(canvas);
        break;
      case BilateralObject.ripple:
        _drawRipple(canvas);
        break;
      case BilateralObject.bubble:
        _drawBubble(canvas);
        break;
      case BilateralObject.aurora:
        _drawAurora(canvas);
        break;
      case BilateralObject.mandala:
        _drawMandala(canvas);
        break;
      case BilateralObject.torus:
        _drawTorus(canvas);
        break;
      case BilateralObject.merkaba:
        _drawMerkaba(canvas);
        break;
    }
    canvas.restore();
  }

  // Helpers
  Paint _radialPaint(Offset c, double r, List<Color> cols, List<double> stops) {
    return Paint()
      ..shader = RadialGradient(
        colors: cols,
        stops: stops,
      ).createShader(Rect.fromCircle(center: c, radius: r));
  }

  void _glow(Canvas c, double r, Color col, double alpha) {
    c.drawCircle(
      Offset.zero,
      r,
      _radialPaint(
        Offset.zero,
        r,
        [col.withOpacity(alpha), Colors.transparent],
        [0, 1],
      ),
    );
  }

  // ── OBJECTS ─────────────────────────────────────────────

  void _drawOrb(Canvas c) {
    final r = 28.0 * (1 + 0.06 * sin(t * 0.004));
    _glow(c, r * 3, const Color(0xFF7F77DD), 0.18);
    _glow(c, r * 1.5, const Color(0xFFB4AFFF), 0.25);
    c.drawCircle(
      Offset.zero,
      r,
      _radialPaint(
        const Offset(-8, -8),
        r,
        [
          const Color(0xFFE8E4FF),
          const Color(0xFF9F97EE),
          const Color(0xFF4A3FA0),
          const Color(0xFF1A1540),
        ],
        [0, 0.4, 0.8, 1],
      ),
    );
    c.drawOval(
      const Rect.fromLTWH(-18, -14, 18, 10),
      Paint()..color = Colors.white.withOpacity(0.28),
    );
  }

  void _drawPlasma(Canvas c) {
    final r = 24.0;
    for (int i = 3; i >= 0; i--) {
      _glow(
        c,
        r * (1 + i * 0.6),
        i.isEven ? const Color(0xFF50C8FF) : const Color(0xFFFF50C8),
        0.08,
      );
    }
    c.drawCircle(
      Offset.zero,
      r,
      _radialPaint(
        Offset.zero,
        r,
        [
          Colors.white,
          const Color(0xFFFF80FF),
          const Color(0xFF6020C0),
          Colors.transparent,
        ],
        [0, 0.3, 0.7, 1],
      ),
    );
    final sp = Paint()
      ..color = const Color(0xFFDCA0FF).withOpacity(0.5)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    for (int i = 0; i < 5; i++) {
      final a = t * 0.006 + i * (pi * 2 / 5);
      final ex = cos(a) * (r + 14), ey = sin(a) * (r + 14);
      final path = Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(
          ex * 0.5 + sin(t * 0.012 + i) * 12,
          ey * 0.5,
          ex,
          ey,
        );
      c.drawPath(path, sp);
    }
  }

  void _drawPulsar(Canvas c) {
    final r = 22.0, phase = t * 0.005;
    for (int i = 4; i >= 1; i--) {
      final rr = r + i * 14 * (0.5 + 0.5 * sin(phase * i));
      c.drawCircle(
        Offset.zero,
        rr,
        Paint()
          ..color = const Color(0xFF50C8FF).withOpacity(0.18 / i)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
    _glow(c, r * 2, const Color(0xFF50C8FF), 0.3);
    c.drawCircle(
      Offset.zero,
      r,
      _radialPaint(
        Offset.zero,
        r,
        [Colors.white, const Color(0xFF50C8FF), Colors.transparent],
        [0, 0.5, 1],
      ),
    );
  }

  void _drawSunbeam(Canvas c) {
    final rot = t * 0.003, r = 20.0;
    c.save();
    c.rotate(rot);
    final rayPaint = Paint()
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    for (int i = 0; i < 12; i++) {
      final a = i * (pi / 6), len = r + 24 + sin(t * 0.008 + i) * 10;
      rayPaint.shader = LinearGradient(
        colors: [const Color(0xFFFFDC50).withOpacity(0.5), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, cos(a) * len, sin(a) * len));
      c.drawLine(Offset.zero, Offset(cos(a) * len, sin(a) * len), rayPaint);
    }
    c.drawCircle(
      Offset.zero,
      r,
      _radialPaint(
        Offset.zero,
        r,
        [const Color(0xFFFFF8C0), const Color(0xFFFFD040), Colors.transparent],
        [0, 0.5, 1],
      ),
    );
    c.restore();
  }

  void _drawStar(Canvas c) {
    final spin = t * 0.003, r = 22.0, ir = 9.0;
    _glow(c, r * 2.5, const Color(0xFFFFC850), 0.2);
    c.save();
    c.rotate(spin);
    final path = Path();
    for (int i = 0; i < 10; i++) {
      final a = i * pi / 5, rd = i.isEven ? r : ir;
      if (i == 0)
        path.moveTo(cos(a) * rd, sin(a) * rd);
      else
        path.lineTo(cos(a) * rd, sin(a) * rd);
    }
    path.close();
    c.drawPath(
      path,
      _radialPaint(
        Offset.zero,
        r,
        [
          const Color(0xFFFFF8E0),
          const Color(0xFFFFCC40),
          const Color(0xFFC07000),
        ],
        [0, 0.5, 1],
      ),
    );
    c.restore();
  }

  void _drawComet(Canvas c) {
    final dir = vx > 0 ? -1.0 : 1.0;
    for (int i = 3; i >= 1; i--) {
      final path = Path()
        ..moveTo(dir * 90 * i * 0.4, -8.0 * i)
        ..lineTo(0, 0)
        ..lineTo(dir * 90 * i * 0.4, 8.0 * i)
        ..close();
      c.drawPath(
        path,
        Paint()
          ..shader =
              LinearGradient(
                colors: [
                  const Color(0xFF87B7FF).withOpacity(0.15 / i),
                  Colors.transparent,
                ],
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
              ).createShader(
                Rect.fromLTWH(dir * 90 * i * 0.4, -8.0 * i, 90, 16.0 * i),
              ),
      );
    }
    _glow(c, 28, const Color(0xFFA0D2FF), 0.4);
    c.drawCircle(
      Offset.zero,
      18,
      _radialPaint(
        const Offset(-4, -4),
        18,
        [Colors.white, const Color(0xFF90CBFF), Colors.transparent],
        [0, 0.3, 1],
      ),
    );
  }

  void _drawGalaxy(Canvas c) {
    c.save();
    c.rotate(t * 0.002);
    _glow(c, 50, const Color(0xFFA078FF), 0.15);
    final armCols = [
      const Color(0xFFA078FF),
      const Color(0xFF64C8FF),
      const Color(0xFFC882FF),
    ];
    for (int arm = 0; arm < 3; arm++) {
      final aOff = arm * (pi * 2 / 3);
      for (int i = 0; i < 22; i++) {
        final r = i * 2.4, a = aOff + i * 0.42;
        final sr = max(0.4, 2.8 - i * 0.1);
        c.drawCircle(
          Offset(cos(a) * r, sin(a) * r),
          sr,
          Paint()
            ..color = armCols[arm].withOpacity((0.95 - i * 0.04).clamp(0, 1)),
        );
      }
    }
    c.drawCircle(
      Offset.zero,
      10,
      _radialPaint(
        Offset.zero,
        10,
        [
          Colors.white,
          const Color(0xFFDCC8FF).withOpacity(0.8),
          Colors.transparent,
        ],
        [0, 0.5, 1],
      ),
    );
    c.restore();
  }

  void _drawNebula(Canvas c) {
    c.save();
    c.scale(1 + 0.04 * sin(t * 0.003), 1 + 0.04 * sin(t * 0.003));
    final cols = [
      [const Color(0xFFFF64B4), 30.0],
      [const Color(0xFF64B4FF), 24.0],
      [const Color(0xFFB464FF), 20.0],
    ];
    for (int i = 0; i < cols.length; i++) {
      final col = cols[i][0] as Color, r = cols[i][1] as double;
      final ox = sin(t * 0.004 + i * 2) * 8, oy = cos(t * 0.003 + i * 2) * 6;
      c.drawCircle(
        Offset(ox, oy),
        r,
        _radialPaint(
          Offset(ox, oy),
          r,
          [col.withOpacity(0.5), col.withOpacity(0.2), Colors.transparent],
          [0, 0.6, 1],
        ),
      );
    }
    c.restore();
  }

  void _drawBlackhole(Canvas c) {
    c.save();
    c.rotate(t * 0.004);
    for (int i = 6; i >= 1; i--) {
      c.drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: 40.0 * i * 0.36,
          height: 20.0 * i * 0.36,
        ),
        Paint()
          ..color =
              (i.isEven ? const Color(0xFFB450FF) : const Color(0xFF50B4FF))
                  .withOpacity(0.35 / i)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );
    }
    c.drawCircle(Offset.zero, 14, Paint()..color = Colors.black);
    _glow(c, 16, const Color(0xFFA050FF), 0.8);
    c.restore();
  }

  void _drawButterfly(Canvas c) {
    final flap = sin(t * 0.014) * 0.55;
    for (final sx in [-1.0, 1.0]) {
      for (final sy in [-1.0, 1.0]) {
        c.save();
        c.scale(sx, sy);
        c.rotate(flap * (sy.abs() > 0.5 ? 0.8 : 0.4));
        c.drawOval(
          Rect.fromCenter(
            center: Offset(20, sy > 0 ? 9 : 16),
            width: 52,
            height: 32,
          ),
          _radialPaint(
            const Offset(20, 10),
            32,
            [
              const Color(0xFF78E6B4).withOpacity(0.95),
              const Color(0xFF32B482).withOpacity(0.7),
              Colors.transparent,
            ],
            [0, 0.5, 1],
          ),
        );
        c.drawCircle(
          const Offset(18, 12),
          4,
          Paint()..color = const Color(0xFFFFDC50).withOpacity(0.4),
        );
        c.restore();
      }
    }
    c.drawOval(
      const Rect.fromLTWH(-4, -16, 8, 32),
      Paint()..color = const Color(0xFF062820),
    );
  }

  void _drawLotus(Canvas c) {
    c.save();
    c.rotate(t * 0.0008);
    _glow(c, 40, const Color(0xFFDC64A0), 0.15);
    for (int i = 0; i < 8; i++) {
      c.save();
      c.rotate(i * pi * 2 / 8);
      c.drawOval(
        const Rect.fromLTWH(-7, -33, 14, 26),
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFF06496).withOpacity(0.95),
              const Color(0xFFC83C6E).withOpacity(0.7),
              const Color(0xFF8C2850).withOpacity(0.15),
            ],
          ).createShader(const Rect.fromLTWH(-7, -33, 14, 26)),
      );
      c.restore();
    }
    c.drawCircle(
      Offset.zero,
      11,
      _radialPaint(
        Offset.zero,
        11,
        [const Color(0xFFFFF8C0), const Color(0xFFFFCC40), Colors.transparent],
        [0, 0.6, 1],
      ),
    );
    c.restore();
  }

  void _drawFeather(Canvas c) {
    final sw = sin(t * 0.003) * 10;
    c.save();
    c.translate(0, sw);
    final path = Path()
      ..moveTo(0, 24)
      ..cubicTo(-16, -4, -22, -20, 0, -28)
      ..cubicTo(22, -20, 16, -4, 0, 24);
    c.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFC8E6FF).withOpacity(0.95),
            const Color(0xFF78B4F0).withOpacity(0.8),
            Colors.transparent,
          ],
        ).createShader(const Rect.fromLTWH(-22, -28, 44, 52)),
    );
    c.drawLine(
      const Offset(0, -28),
      const Offset(0, 24),
      Paint()
        ..color = const Color(0xFF508CDC).withOpacity(0.3)
        ..strokeWidth = 1,
    );
    c.restore();
  }

  void _drawFlame(Canvas c) {
    final w1 = sin(t * 0.007) * 7, w2 = sin(t * 0.011) * 5;
    for (int layer = 0; layer < 4; layer++) {
      c.save();
      final sc = 1 - layer * 0.18;
      c.scale(sc, sc);
      final path = Path()
        ..moveTo(0, 20)
        ..cubicTo(-16 + w1, -2, -12 + w2, -20, 0, -30)
        ..cubicTo(12 + w2, -20, 16 + w1, -2, 0, 20);
      final al = 0.85 - layer * 0.18;
      c.drawPath(
        path,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFFFFFB4).withOpacity(al),
              const Color(0xFFFFA01E).withOpacity(al),
              const Color(0xFFDC4614).withOpacity(al * 0.6),
              Colors.transparent,
            ],
            stops: const [0, 0.3, 0.75, 1],
          ).createShader(const Rect.fromLTWH(-16, -30, 32, 50)),
      );
      c.restore();
    }
    _glow(c, 20, const Color(0xFFFF8C28), 0.35);
  }

  void _drawSnowflake(Canvas c) {
    c.save();
    c.rotate(t * 0.002);
    _glow(c, 30, const Color(0xFFB4DCFF), 0.2);
    final p = Paint()
      ..color = const Color(0xFFC8E6FF).withOpacity(0.9)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    for (int arm = 0; arm < 6; arm++) {
      c.save();
      c.rotate(arm * pi / 3);
      c.drawLine(Offset.zero, const Offset(0, -26), p);
      for (int j = 1; j <= 3; j++) {
        c.drawLine(
          Offset(-5, -j * 8.0),
          Offset(5, -j * 8.0),
          Paint()
            ..color = const Color(0xFFB4DCFF).withOpacity(0.8 - j * 0.1)
            ..strokeWidth = 1.2
            ..style = PaintingStyle.stroke,
        );
      }
      c.restore();
    }
    c.drawCircle(
      Offset.zero,
      4,
      Paint()..color = const Color(0xFFF0F8FF).withOpacity(0.95),
    );
    c.restore();
  }

  void _drawLeaf(Canvas c) {
    final rock = sin(t * 0.004) * 0.25;
    c.save();
    c.rotate(rock);
    final path = Path()
      ..moveTo(0, -26)
      ..cubicTo(18, -16, 20, 8, 0, 26)
      ..cubicTo(-20, 8, -18, -16, 0, -26);
    c.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          colors: [
            const Color(0xFF50C864).withOpacity(0.95),
            const Color(0xFF28A046).withOpacity(0.8),
            const Color(0xFF146428).withOpacity(0.4),
          ],
        ).createShader(const Rect.fromLTWH(-20, -26, 40, 52)),
    );
    c.drawLine(
      const Offset(0, -26),
      const Offset(0, 26),
      Paint()
        ..color = const Color(0xFFB4FF96).withOpacity(0.4)
        ..strokeWidth = 1,
    );
    c.restore();
  }

  void _drawDandelion(Canvas c) {
    final drift = sin(t * 0.005) * 8;
    c.save();
    c.translate(0, drift);
    final linePaint = Paint()
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
    for (int i = 0; i < 16; i++) {
      final a = (i / 16) * pi * 2 + t * 0.002;
      final len = 20 + sin(t * 0.006 + i) * 4;
      linePaint.color = const Color(
        0xFFE6E6C8,
      ).withOpacity(0.7 + 0.2 * sin(i.toDouble()));
      c.drawLine(Offset.zero, Offset(cos(a) * len, sin(a) * len), linePaint);
      c.drawCircle(
        Offset(cos(a) * len, sin(a) * len),
        2.5,
        Paint()..color = const Color(0xFFFFFAC8).withOpacity(0.8),
      );
    }
    c.drawCircle(
      Offset.zero,
      4,
      Paint()..color = const Color(0xFFFFF08C).withOpacity(0.9),
    );
    c.restore();
  }

  void _drawCrystal(Canvas c) {
    c.save();
    c.rotate(t * 0.002);
    _glow(c, 36, const Color(0xFF5DCAA5), 0.2);
    final pts = [
      const Offset(0, -30),
      const Offset(13, -10),
      const Offset(24, 0),
      const Offset(11, 12),
      const Offset(0, 26),
      const Offset(-11, 12),
      const Offset(-24, 0),
      const Offset(-13, -10),
    ];
    final path = Path()..moveTo(pts[0].dx, pts[0].dy);
    for (int i = 1; i < pts.length; i++) path.lineTo(pts[i].dx, pts[i].dy);
    path.close();
    c.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFE6FFF5).withOpacity(0.95),
            const Color(0xFF5DCAA5).withOpacity(0.75),
            const Color(0xFF1E8C64).withOpacity(0.4),
          ],
        ).createShader(const Rect.fromLTWH(-24, -30, 48, 56)),
    );
    c.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF96FFD2).withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );
    c.restore();
  }

  void _drawDiamond(Canvas c) {
    final spin = t * 0.0015, pulse = 1 + 0.05 * sin(t * 0.004);
    c.save();
    c.rotate(spin);
    c.scale(pulse, pulse);
    _glow(c, 44, const Color(0xFF96BEFF), 0.2);
    final path = Path()
      ..moveTo(0, -28)
      ..lineTo(22, -8)
      ..lineTo(0, 32)
      ..lineTo(-22, -8)
      ..close();
    c.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFE6F5FF).withOpacity(0.98),
            const Color(0xFFA0C8FF).withOpacity(0.85),
            const Color(0xFF508CF0).withOpacity(0.6),
            const Color(0xFF2850C8).withOpacity(0.4),
          ],
        ).createShader(const Rect.fromLTWH(-22, -28, 44, 60)),
    );
    c.drawLine(
      const Offset(0, -28),
      const Offset(0, 32),
      Paint()
        ..color = const Color(0xFFDCF0FF).withOpacity(0.5)
        ..strokeWidth = 0.8,
    );
    c.restore();
  }

  void _drawPrism(Canvas c) {
    c.save();
    c.rotate(t * 0.003);
    final cols = [
      const Color(0xFFFF5050),
      const Color(0xFFFFB400),
      const Color(0xFF50FF50),
      const Color(0xFF00B4FF),
      const Color(0xFFB450FF),
    ];
    for (int i = 0; i < 5; i++) {
      final a = i * (pi * 2 / 5);
      final dist = 18 + sin(t * 0.006 + i) * 4;
      final ox = cos(a) * dist, oy = sin(a) * dist;
      c.drawCircle(
        Offset(ox, oy),
        10,
        _radialPaint(
          Offset(ox, oy),
          10,
          [cols[i].withOpacity(0.8), Colors.transparent],
          [0, 1],
        ),
      );
    }
    c.drawCircle(
      Offset.zero,
      10,
      _radialPaint(
        Offset.zero,
        10,
        [Colors.white.withOpacity(0.9), Colors.transparent],
        [0, 1],
      ),
    );
    c.restore();
  }

  void _drawGeode(Canvas c) {
    c.save();
    c.rotate(t * 0.001);
    _glow(c, 38, const Color(0xFFB450DC), 0.18);
    final layerCols = [
      const Color(0xFF641480),
      const Color(0xFF8C3CB4),
      const Color(0xFFB464DC),
      const Color(0xFFD296FF),
      const Color(0xFFF0C8FF),
    ];
    for (int i = 5; i >= 1; i--) {
      c.drawCircle(
        Offset.zero,
        i * 6.0,
        Paint()
          ..color = layerCols[5 - i]
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );
    }
    c.drawCircle(
      Offset.zero,
      7,
      Paint()..color = const Color(0xFFFFF0FF).withOpacity(0.9),
    );
    c.restore();
  }

  void _drawJellyfish(Canvas c) {
    final bob = sin(t * 0.007) * 12, pulse = 1 + 0.09 * sin(t * 0.012);
    c.save();
    c.translate(0, bob);
    _glow(c, 38, const Color(0xFFC88CFF), 0.2);
    c.save();
    c.scale(1, pulse);
    final path = Path()..addArc(const Rect.fromLTWH(-24, -28, 48, 48), pi, pi);
    path.close();
    c.drawPath(
      path,
      _radialPaint(
        const Offset(0, -8),
        24,
        [
          const Color(0xFFDCA0FF).withOpacity(0.9),
          const Color(0xFFA050DC).withOpacity(0.55),
          Colors.transparent,
        ],
        [0, 0.6, 1],
      ),
    );
    c.restore();
    final tp = Paint()
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    for (int i = 0; i < 8; i++) {
      final tx = -21.0 + i * 6, sw = sin(t * 0.006 + i * 1.2) * 10;
      tp.color = const Color(0xFFC88CFF).withOpacity(0.55 - i * 0.03);
      final tPath = Path()
        ..moveTo(tx, 16)
        ..quadraticBezierTo(tx + sw, 32, tx + sw * 0.5, 50);
      c.drawPath(tPath, tp);
    }
    c.restore();
  }

  void _drawDroplet(Canvas c) {
    final wobble = sin(t * 0.008) * 0.04;
    c.save();
    c.scale(1 + wobble, 1 - wobble);
    _glow(c, 30, const Color(0xFF50B4FF), 0.2);
    final path = Path()
      ..moveTo(0, -26)
      ..cubicTo(18, -10, 20, 10, 0, 22)
      ..cubicTo(-20, 10, -18, -10, 0, -26);
    c.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFC8EBFF).withOpacity(0.95),
            const Color(0xFF50B4FF).withOpacity(0.8),
            const Color(0xFF1450C8).withOpacity(0.5),
          ],
        ).createShader(const Rect.fromLTWH(-20, -26, 40, 48)),
    );
    c.drawOval(
      const Rect.fromLTWH(-14, -20, 10, 16),
      Paint()..color = Colors.white.withOpacity(0.35),
    );
    c.restore();
  }

  void _drawRipple(Canvas c) {
    for (int i = 4; i >= 1; i--) {
      final phase = (t * 0.006 + i * 0.8) % (pi * 2);
      final r = 8.0 + i * 8;
      c.drawOval(
        Rect.fromCenter(center: Offset.zero, width: r * 2, height: r * 0.8),
        Paint()
          ..color = const Color(
            0xFF50C8DC,
          ).withOpacity((0.5 * cos(phase).abs() / i).clamp(0, 1))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
    c.drawCircle(
      Offset.zero,
      8,
      _radialPaint(
        Offset.zero,
        8,
        [
          const Color(0xFFC8F0FF).withOpacity(0.9),
          const Color(0xFF50C8DC).withOpacity(0.4),
        ],
        [0, 1],
      ),
    );
  }

  void _drawBubble(Canvas c) {
    final r = 22.0 * (1 + 0.04 * sin(t * 0.005));
    _glow(c, r * 1.6, const Color(0xFF96C8FF), 0.12);
    c.drawCircle(
      Offset.zero,
      r,
      _radialPaint(
        const Offset(-8, -8),
        r,
        [
          const Color(0xFFF0F8FF).withOpacity(0.5),
          const Color(0xFF96C8FF).withOpacity(0.15),
          const Color(0xFFB496FF).withOpacity(0.2),
          const Color(0xFF96C8FF).withOpacity(0.1),
        ],
        [0, 0.4, 0.8, 1],
      ),
    );
    c.drawCircle(
      Offset.zero,
      r,
      Paint()
        ..color = const Color(0xFFC8DCFF).withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    c.drawOval(
      const Rect.fromLTWH(-16, -16, 16, 10),
      Paint()..color = Colors.white.withOpacity(0.45),
    );
  }

  void _drawAurora(Canvas c) {
    for (int i = 0; i < 5; i++) {
      final off = (i * 7 - 14).toDouble();
      final path = Path();
      final steps = 20;
      for (int step = 0; step <= steps; step++) {
        final px = -36.0 + step * (72.0 / steps);
        final py =
            off + sin(px * 0.08 + t * (0.006 + i * 0.001)) * (10 + i * 3.0);
        if (step == 0)
          path.moveTo(px, py);
        else
          path.lineTo(px, py);
      }
      c.drawPath(
        path,
        Paint()
          ..color =
              (i.isEven ? const Color(0xFF50DCB4) : const Color(0xFF78D2F0))
                  .withOpacity((0.28 - i * 0.04).clamp(0, 1))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.5 - i * 0.5,
      );
    }
  }

  void _drawMandala(Canvas c) {
    c.save();
    c.rotate(t * 0.0015);
    _glow(c, 40, const Color(0xFFC896FF), 0.15);
    final ringCols = [
      const Color(0xFFFF96C8),
      const Color(0xFF96B4FF),
      const Color(0xFFC896FF),
    ];
    for (int ring = 0; ring < 3; ring++) {
      final n = 6 + ring * 4, r = 10.0 + ring * 10;
      final iRot = ring.isEven ? t * 0.0015 : -t * 0.0015;
      for (int i = 0; i < n; i++) {
        final a = iRot + i * (pi * 2 / n);
        c.drawCircle(
          Offset(cos(a) * r, sin(a) * r),
          3.0 - ring * 0.5,
          Paint()..color = ringCols[ring].withOpacity(0.9 - ring * 0.1),
        );
      }
    }
    c.drawCircle(
      Offset.zero,
      5,
      Paint()..color = const Color(0xFFFFF0FF).withOpacity(0.95),
    );
    c.restore();
  }

  void _drawTorus(Canvas c) {
    c.save();
    c.rotate(t * 0.003);
    _glow(c, 38, const Color(0xFF64DCC8), 0.18);
    for (int i = 0; i < 24; i++) {
      final a = i * (pi * 2 / 24), r = 18.0;
      final px = cos(a) * r, py = sin(a) * r;
      final dot = 3.5 + 2.5 * sin(a);
      c.drawCircle(
        Offset(px, py),
        dot,
        Paint()
          ..color = Color.fromRGBO(
            100 + (120 * sin(a + t * 0.003)).toInt().clamp(0, 120),
            220,
            200,
            0.8,
          ),
      );
    }
    c.drawCircle(
      Offset.zero,
      7,
      _radialPaint(
        Offset.zero,
        7,
        [Colors.white, const Color(0xFF64DCC8).withOpacity(0)],
        [0, 1],
      ),
    );
    c.restore();
  }

  void _drawMerkaba(Canvas c) {
    final spin = t * 0.002;
    c.save();
    c.rotate(spin);
    _glow(c, 40, const Color(0xFFFFDC64), 0.2);
    for (int tri = 0; tri < 2; tri++) {
      c.save();
      c.rotate(tri * pi / 3 * 2);
      final path = Path()
        ..moveTo(0, -26)
        ..lineTo(22, 14)
        ..lineTo(-22, 14)
        ..close();
      c.drawPath(
        path,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: tri == 0
                ? [
                    const Color(0xFFFFDC50).withOpacity(0.7),
                    const Color(0xFFFFA01E).withOpacity(0.2),
                  ]
                : [
                    const Color(0xFFB478FF).withOpacity(0.7),
                    const Color(0xFF643CC8).withOpacity(0.2),
                  ],
          ).createShader(const Rect.fromLTWH(-22, -26, 44, 40)),
      );
      c.drawPath(
        path,
        Paint()
          ..color =
              (tri == 0 ? const Color(0xFFFFDC64) : const Color(0xFFC8A0FF))
                  .withOpacity(0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
      c.restore();
    }
    c.drawCircle(
      Offset.zero,
      6,
      Paint()..color = Colors.white.withOpacity(0.9),
    );
    c.restore();
  }

  @override
  bool shouldRepaint(ObjectPainter old) => true;
}
