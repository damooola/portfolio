import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../data/portfolio_data.dart';
import '../theme/app_theme.dart';
import 'guilloche_painter.dart';

/// A debit-card-proportioned "ID card" for the hero. Sits slightly tilted
/// and straightens up on hover.
class IdentityCard extends StatefulWidget {
  const IdentityCard({super.key});

  @override
  State<IdentityCard> createState() => _IdentityCardState();
}

class _IdentityCardState extends State<IdentityCard> {
  static const _aspect = 1.586; // ISO/IEC 7810 ID-1, the standard card shape
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size.width;
    final width = math.min(380.0, screen - AppSpacing.sm * 2);
    final height = width / _aspect;
    final pad = width * 0.07;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedRotation(
        turns: _hover ? 0 : -0.012,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutBack,
        child: AnimatedScale(
          scale: _hover ? 1.03 : 1,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOutBack,
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.text, AppColors.textMuted, AppColors.blue],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.text.withValues(alpha: 0.35),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: RepaintBoundary(
                      child: CustomPaint(
                        painter: GuillochePainter(
                          color: AppColors.night.withValues(alpha: 0.13),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(pad),
                    child: _CardFace(width: width),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CardFace extends StatelessWidget {
  final double width;

  const _CardFace({required this.width});

  @override
  Widget build(BuildContext context) {
    final cream = AppColors.night;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'DN',
              style: AppText.display.copyWith(color: cream, fontSize: 22),
            ),
            const Spacer(),
            Icon(
              Icons.contactless_outlined,
              color: cream.withValues(alpha: 0.85),
              size: 24,
            ),
          ],
        ),
        const Spacer(),
        const _Chip(),
        const SizedBox(height: 12),
        Text(
          '••••  ••••  ••••  2024',
          style: AppText.mono.copyWith(
            color: cream,
            fontSize: width * 0.052,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              flex: 4, // gets most of the free space; the Spacer takes the rest
              child: _CardField(label: 'CARDHOLDER', value: ProfileData.name.toUpperCase()),
            ),
            const SizedBox(width: 16),
            const _CardField(label: 'SINCE', value: '08/24'),
            const Spacer(),
            Text(
              'FLUTTER',
              style: AppText.mono.copyWith(
                color: AppColors.blue,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CardField extends StatelessWidget {
  final String label;
  final String value;

  const _CardField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppText.monoLabel.copyWith(
            color: AppColors.night.withValues(alpha: 0.55),
            fontSize: 8,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppText.mono.copyWith(color: AppColors.night, fontSize: 12),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 32,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: LinearGradient(
          colors: [AppColors.blue, AppColors.blue.withValues(alpha: 0.7)],
        ),
      ),
      child: CustomPaint(painter: _ChipLinesPainter()),
    );
  }
}

class _ChipLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.text.withValues(alpha: 0.3)
      ..strokeWidth = 1;
    final w = size.width, h = size.height;
    canvas.drawLine(Offset(0, h / 3), Offset(w * 0.35, h / 3), paint);
    canvas.drawLine(Offset(0, h * 2 / 3), Offset(w * 0.35, h * 2 / 3), paint);
    canvas.drawLine(Offset(w * 0.65, h / 3), Offset(w, h / 3), paint);
    canvas.drawLine(Offset(w * 0.65, h * 2 / 3), Offset(w, h * 2 / 3), paint);
    canvas.drawRect(
      Rect.fromLTRB(w * 0.35, h * 0.2, w * 0.65, h * 0.8),
      paint..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(_ChipLinesPainter old) => false;
}
