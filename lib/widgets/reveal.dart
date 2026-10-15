import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../theme/app_theme.dart';

/// Reveals its child the first time it scrolls into view, then leaves it
/// alone. With reduced motion on, it fades instead of sliding.
class Reveal extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final double slide;

  const Reveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.slide = 0.15,
  });

  @override
  State<Reveal> createState() => _RevealState();
}

class _RevealState extends State<Reveal> {
  final _key = UniqueKey();
  bool _shown = false;

  @override
  Widget build(BuildContext context) {
    if (!_shown) {
      return VisibilityDetector(
        key: _key,
        onVisibilityChanged: (info) {
          if (info.visibleFraction > 0.1 && mounted && !_shown) {
            setState(() => _shown = true);
          }
        },
        child: Opacity(opacity: 0, child: widget.child),
      );
    }
    final a = widget.child
        .animate(delay: widget.delay)
        .fadeIn(duration: 400.ms, curve: AppMotion.settle);
    if (AppMotion.reduced(context)) return a;
    return a.slideY(
      begin: widget.slide,
      end: 0,
      duration: AppMotion.big,
      curve: AppMotion.settle,
    );
  }
}
