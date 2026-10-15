import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

double _progress(ScrollController controller) {
  if (!controller.hasClients) return 0;
  final position = controller.position;
  if (!position.hasContentDimensions || position.maxScrollExtent <= 0) return 0;
  return (position.pixels / position.maxScrollExtent).clamp(0.0, 1.0);
}

/// Live readout of how far down the page you are, styled like a ticker.
class ScrollMeter extends StatelessWidget {
  final ScrollController controller;

  const ScrollMeter({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobile(MediaQuery.of(context).size.width);

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final percent = (_progress(controller) * 100).round();
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.ink,
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: AppColors.ink.withValues(alpha: 0.25),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.sage,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              if (!isMobile) ...[
                Text(
                  'SCROLLED',
                  style: AppText.monoLabel.copyWith(
                    color: AppColors.cream.withValues(alpha: 0.6),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Text(
                '${percent.toString().padLeft(3, '0')}%',
                style: AppText.mono.copyWith(
                  color: AppColors.cream,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// A fixed ruler down the left edge, numbered in page pixels. The ticks
/// slide past a stationary marker that reads out the current offset.
class ScrollRuler extends StatelessWidget {
  static const width = 52.0;
  final ScrollController controller;

  const ScrollRuler({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final markerY = constraints.maxHeight / 2;
        return ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            final offset = controller.hasClients ? controller.offset : 0.0;
            return Container(
              width: width,
              decoration: BoxDecoration(
                color: AppColors.cream.withValues(alpha: 0.88),
                border: const Border(right: BorderSide(color: AppColors.hairline)),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _RulerPainter(offset: offset, markerY: markerY),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: markerY - 10,
                    child: Container(
                      height: 20,
                      alignment: Alignment.center,
                      color: AppColors.ink,
                      child: Text(
                        offset.round().toString().padLeft(4, '0'),
                        style: AppText.mono.copyWith(
                          color: AppColors.cream,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _RulerPainter extends CustomPainter {
  final double offset;
  final double markerY;

  _RulerPainter({required this.offset, required this.markerY});

  static const _step = 50;

  @override
  void paint(Canvas canvas, Size size) {
    final tick = Paint()
      ..color = AppColors.inkMuted.withValues(alpha: 0.55)
      ..strokeWidth = 1;
    final labelStyle = AppText.mono.copyWith(color: AppColors.inkMuted, fontSize: 9);

    final first = ((offset - markerY) / _step).floor() * _step;
    final last = offset + size.height - markerY;
    for (var v = first; v <= last; v += _step) {
      if (v < 0) continue;
      final y = markerY + (v - offset);
      final major = v % 500 == 0;
      final length = major ? 16.0 : (v % 100 == 0 ? 9.0 : 5.0);
      canvas.drawLine(Offset(size.width - length, y), Offset(size.width, y), tick);
      if (major) {
        final tp = TextPainter(
          text: TextSpan(text: '$v', style: labelStyle),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(6, y - tp.height / 2));
      }
    }
  }

  @override
  bool shouldRepaint(_RulerPainter old) =>
      old.offset != offset || old.markerY != markerY;
}

/// Thin sage line along the top edge that fills as you scroll.
class ScrollProgressBar extends StatelessWidget {
  final ScrollController controller;

  const ScrollProgressBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: _progress(controller),
          child: Container(height: 2, color: AppColors.sage),
        ),
      ),
    );
  }
}
