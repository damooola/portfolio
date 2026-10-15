import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Oversized all-caps section title with a ledger-style rule above it:
/// `(03) ───────────── ₦`
class SectionHeader extends StatelessWidget {
  final String index;
  final String title;
  final String? caption;
  final bool onDark;

  const SectionHeader({
    super.key,
    required this.index,
    required this.title,
    this.caption,
    this.onDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final size = AppBreakpoints.isMobile(width)
        ? 56.0
        : AppBreakpoints.isDesktop(width)
            ? 128.0
            : 88.0;
    final ink = onDark ? AppColors.cream : AppColors.ink;
    final rule = onDark ? AppColors.cream.withValues(alpha: 0.25) : AppColors.hairline;
    final accent = onDark ? AppColors.sage : AppColors.rose;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('($index)', style: AppText.monoLabel.copyWith(color: accent)),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Container(height: 1, color: rule)),
            const SizedBox(width: AppSpacing.sm),
            Text('₦', style: AppText.mono.copyWith(color: accent, fontSize: 14)),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            title.toUpperCase(),
            style: AppText.display.copyWith(
              color: ink,
              fontSize: size,
              height: 0.95,
              letterSpacing: -size * 0.03,
            ),
          ),
        ),
        if (caption != null) ...[
          const SizedBox(height: AppSpacing.sm),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Text(
              caption!,
              style: AppText.body.copyWith(
                fontSize: 17,
                color: onDark ? AppColors.cream.withValues(alpha: 0.8) : AppColors.inkMuted,
              ),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}
