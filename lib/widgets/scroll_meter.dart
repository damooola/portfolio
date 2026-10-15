import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

double scrollProgress(ScrollController controller) {
  if (!controller.hasClients) return 0;
  final position = controller.position;
  if (!position.hasContentDimensions || position.maxScrollExtent <= 0) return 0;
  return (position.pixels / position.maxScrollExtent).clamp(0.0, 1.0);
}

/// Thin blue line along the top edge that fills as you scroll.
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
          widthFactor: scrollProgress(controller),
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              color: AppColors.blue,
              boxShadow: [
                BoxShadow(
                  color: AppColors.blue.withValues(alpha: 0.6),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
