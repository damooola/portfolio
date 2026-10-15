import 'dart:math' as math;
import 'package:flutter/material.dart';

/// The fine interlaced wave pattern printed on banknotes, cheques and cards
/// as an anti-counterfeit measure. Two bands of phase-shifted curves.
class GuillochePainter extends CustomPainter {
  final Color color;
  final int lines;

  const GuillochePainter({required this.color, this.lines = 16});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;

    _band(canvas, size, paint, centerY: size.height * 0.34, cycles: 2.5);
    _band(canvas, size, paint, centerY: size.height * 0.74, cycles: 3.5);
  }

  void _band(
    Canvas canvas,
    Size size,
    Paint paint, {
    required double centerY,
    required double cycles,
  }) {
    final amp = size.height * 0.16;
    for (var i = 0; i < lines; i++) {
      final phase = i * 2 * math.pi / lines;
      final path = Path();
      for (var x = 0.0; x <= size.width; x += 3) {
        final t = x / size.width * 2 * math.pi * cycles;
        final y = centerY +
            amp * (0.6 * math.sin(t + phase) + 0.4 * math.sin(2 * t - phase));
        x == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(GuillochePainter old) =>
      old.color != color || old.lines != lines;
}
