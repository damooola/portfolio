import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../theme/app_theme.dart';

/// Royal-blue confetti burst over the whole page. Removes itself.
void showConfetti(BuildContext context) {
  final overlay = Overlay.maybeOf(context);
  if (overlay == null) return;
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _ConfettiBurst(onDone: () => entry.remove()),
  );
  overlay.insert(entry);
}

class _Piece {
  Offset position;
  Offset velocity;
  double angle;
  final double spin;
  final Color color;
  final Size size;

  _Piece(
    this.position,
    this.velocity,
    this.angle,
    this.spin,
    this.color,
    this.size,
  );
}

class _ConfettiBurst extends StatefulWidget {
  final VoidCallback onDone;

  const _ConfettiBurst({required this.onDone});

  @override
  State<_ConfettiBurst> createState() => _ConfettiBurstState();
}

class _ConfettiBurstState extends State<_ConfettiBurst>
    with SingleTickerProviderStateMixin {
  static const _life = Duration(milliseconds: 3200);
  static const _colors = [
    AppColors.blue,
    AppColors.blueDeep,
    Colors.white,
    Color(0xFF6E92FF),
  ];

  late final Ticker _ticker;
  final _pieces = <_Piece>[];
  Duration _last = Duration.zero;
  double _elapsed = 0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick)..start();
  }

  void _spawn(Size size) {
    final r = math.Random();
    for (var i = 0; i < 160; i++) {
      // Two cannons, bottom-left and bottom-right, firing inward and up.
      final left = i.isEven;
      final angle =
          (left ? -math.pi / 3 : -2 * math.pi / 3) +
          (r.nextDouble() - 0.5) * 0.6;
      final speed = 900 + r.nextDouble() * 700;
      _pieces.add(
        _Piece(
          Offset(left ? 0 : size.width, size.height),
          Offset(math.cos(angle) * speed, math.sin(angle) * speed),
          r.nextDouble() * math.pi,
          (r.nextDouble() - 0.5) * 14,
          _colors[r.nextInt(_colors.length)],
          Size(6 + r.nextDouble() * 6, 10 + r.nextDouble() * 8),
        ),
      );
    }
  }

  void _tick(Duration now) {
    final dt = (now - _last).inMicroseconds / 1e6;
    _last = now;
    _elapsed = now.inMilliseconds / _life.inMilliseconds;
    if (_elapsed >= 1) {
      _ticker.stop();
      widget.onDone();
      return;
    }
    for (final p in _pieces) {
      p.velocity = Offset(
        p.velocity.dx * (1 - 1.6 * dt),
        p.velocity.dy * (1 - 1.6 * dt) + 1400 * dt,
      );
      p.position += p.velocity * dt;
      p.angle += p.spin * dt;
    }
    setState(() {});
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_pieces.isEmpty) _spawn(MediaQuery.sizeOf(context));
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size.infinite,
          painter: _ConfettiPainter(_pieces, opacity: (1 - _elapsed) * 1.5),
        ),
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<_Piece> pieces;
  final double opacity;

  _ConfettiPainter(this.pieces, {required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final p in pieces) {
      paint.color = p.color.withValues(alpha: opacity.clamp(0, 1));
      canvas
        ..save()
        ..translate(p.position.dx, p.position.dy)
        ..rotate(p.angle)
        // Fake a 3D flutter by squashing the width as it spins.
        ..scale(math.cos(p.angle * 2).abs() * 0.8 + 0.2, 1)
        ..drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset.zero,
              width: p.size.width,
              height: p.size.height,
            ),
            const Radius.circular(1.5),
          ),
          paint,
        )
        ..restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => true;
}
