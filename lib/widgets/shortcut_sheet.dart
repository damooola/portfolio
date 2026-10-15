import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

/// Controller-style key cap.
class KeyCap extends StatelessWidget {
  final String label;
  final double size;

  const KeyCap(this.label, {super.key, this.size = 13});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minWidth: size * 2.4),
      padding: EdgeInsets.symmetric(
        horizontal: size * 0.6,
        vertical: size * 0.3,
      ),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.raised,
        borderRadius: BorderRadius.circular(size * 0.5),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        // Key depth: a hard shadow under the cap, like a real keyboard.
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            offset: const Offset(0, 2.5),
          ),
        ],
      ),
      child: Text(
        label,
        style: AppText.mono.copyWith(
          fontSize: size,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

const _shortcuts = <(List<String>, String)>[
  (['←', '→'], 'Switch project'),
  (['Enter'], 'Jump to the demo'),
  (['E'], 'Email me'),
  (['S'], 'Sound on / off'),
  (['?'], 'This sheet'),
  (['Esc'], 'Close'),
];

Future<void> showShortcutSheet(BuildContext context) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close shortcuts',
    barrierColor: AppColors.night.withValues(alpha: 0.7),
    transitionDuration: AppMotion.big,
    transitionBuilder: (context, a, _, child) => FadeTransition(
      opacity: a,
      child: ScaleTransition(
        scale: Tween(
          begin: 0.92,
          end: 1.0,
        ).animate(CurvedAnimation(parent: a, curve: AppMotion.spring)),
        child: child,
      ),
    ),
    pageBuilder: (context, _, _) => Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 380,
          margin: const EdgeInsets.all(AppSpacing.sm),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.line),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 60,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.sports_esports_outlined,
                    color: AppColors.blue,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Controls',
                    style: AppText.heading.copyWith(fontSize: 22),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              for (var i = 0; i < _shortcuts.length; i++)
                Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _shortcuts[i].$2,
                              style: AppText.body.copyWith(fontSize: 15),
                            ),
                          ),
                          for (final k in _shortcuts[i].$1) ...[
                            const SizedBox(width: 6),
                            KeyCap(k),
                          ],
                        ],
                      ),
                    )
                    .animate()
                    .fadeIn(delay: (40 * i).ms, duration: 200.ms)
                    .slideX(begin: 0.1, end: 0, delay: (40 * i).ms),
              const SizedBox(height: AppSpacing.sm),
              Container(height: 1, color: AppColors.line),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'There\'s one more. If you grew up with a controller, you know it.',
                style: AppText.bodyMuted.copyWith(fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
