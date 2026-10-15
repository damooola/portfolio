import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Receipt-style perforation: a row of short dashes.
class DashedDivider extends StatelessWidget {
  final Color color;

  const DashedDivider({super.key, this.color = AppColors.line});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1,
      width: double.infinity,
      child: CustomPaint(painter: _DashPainter(color)),
    );
  }
}

class _DashPainter extends CustomPainter {
  final Color color;

  _DashPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    const dash = 6.0;
    const gap = 4.0;
    for (var x = 0.0; x < size.width; x += dash + gap) {
      canvas.drawLine(Offset(x, 0), Offset(x + dash, 0), paint);
    }
  }

  @override
  bool shouldRepaint(_DashPainter old) => old.color != color;
}

/// A bank-statement line item: `LABEL ........ value`.
class DotLeaderRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;
  final Color dotColor;

  const DotLeaderRow({
    super.key,
    required this.label,
    required this.value,
    this.labelStyle,
    this.valueStyle,
    this.dotColor = AppColors.line,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: LayoutBuilder(
        builder: (context, constraints) => Row(
          children: [
            Flexible(child: Text(label, style: labelStyle ?? AppText.monoLabel)),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 2,
                child: CustomPaint(painter: _DotPainter(dotColor)),
              ),
            ),
            const SizedBox(width: 10),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.6),
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: valueStyle ??
                    AppText.body.copyWith(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DotPainter extends CustomPainter {
  final Color color;

  _DotPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    for (var x = 1.0; x < size.width; x += 5) {
      canvas.drawCircle(Offset(x, size.height / 2), 1, paint);
    }
  }

  @override
  bool shouldRepaint(_DotPainter old) => old.color != color;
}
