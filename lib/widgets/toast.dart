import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

OverlayEntry? _current;

/// A small toast that pops up from the bottom and leaves on its own.
void showToast(
  BuildContext context,
  String message, {
  IconData icon = Icons.check_circle,
  Color color = AppColors.online,
}) {
  final overlay = Overlay.maybeOf(context);
  if (overlay == null) return;
  _current?.remove();

  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) => Positioned(
      left: 0,
      right: 0,
      bottom: 32,
      child: IgnorePointer(
        child: Center(
          child: Material(
            color: Colors.transparent,
            child:
                Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.raised,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppColors.line),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 24,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon, size: 18, color: color),
                          const SizedBox(width: 10),
                          Text(
                            message,
                            style: AppText.body.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                    .animate(
                      onComplete: (_) {
                        if (_current == entry) {
                          entry.remove();
                          _current = null;
                        }
                      },
                    )
                    .slideY(
                      begin: 1,
                      end: 0,
                      duration: AppMotion.big,
                      curve: AppMotion.spring,
                    )
                    .fadeIn(duration: 150.ms)
                    .then(delay: 1800.ms)
                    .fadeOut(duration: 250.ms)
                    .slideY(begin: 0, end: 0.5, duration: 250.ms),
          ),
        ),
      ),
    ),
  );
  _current = entry;
  overlay.insert(entry);
}
