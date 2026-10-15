import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A soft blue glow that follows the cursor across the navy background.
/// On touch screens (no hover) it rests near the top right of the viewport.
class CursorSpotlight extends StatefulWidget {
  final Widget child;

  const CursorSpotlight({super.key, required this.child});

  @override
  State<CursorSpotlight> createState() => _CursorSpotlightState();
}

class _CursorSpotlightState extends State<CursorSpotlight> {
  final _cursor = ValueNotifier<Offset?>(null);

  @override
  void dispose() {
    _cursor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (e) => _cursor.value = e.localPosition,
      onExit: (_) => _cursor.value = null,
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: RepaintBoundary(
                child: CustomPaint(painter: _SpotlightPainter(_cursor)),
              ),
            ),
          ),
          widget.child,
        ],
      ),
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  final ValueNotifier<Offset?> cursor;

  _SpotlightPainter(this.cursor) : super(repaint: cursor);

  @override
  void paint(Canvas canvas, Size size) {
    final center = cursor.value ?? Offset(size.width * 0.8, size.height * 0.15);
    final radius = cursor.value == null ? 520.0 : 380.0;
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.blue.withValues(alpha: 0.16),
          AppColors.blue.withValues(alpha: 0.05),
          AppColors.blue.withValues(alpha: 0),
        ],
        stops: const [0, 0.45, 1],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(_SpotlightPainter old) => old.cursor != cursor;
}
