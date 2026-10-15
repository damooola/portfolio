import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'reveal.dart';

/// `01 / WORK ─────────` then a big display title and a short caption.
class SectionHeader extends StatelessWidget {
  final String index;
  final String label;
  final String title;
  final String? caption;

  const SectionHeader({
    super.key,
    required this.index,
    required this.label,
    required this.title,
    this.caption,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final size = AppBreakpoints.isMobile(width)
        ? 40.0
        : AppBreakpoints.isDesktop(width)
        ? 72.0
        : 56.0;

    return Reveal(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                index,
                style: AppText.monoLabel.copyWith(color: AppColors.blue),
              ),
              Text('  /  ', style: AppText.monoLabel),
              Text(
                label.toUpperCase(),
                style: AppText.monoLabel.copyWith(color: AppColors.text),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Container(height: 1, color: AppColors.line)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: AppText.display.copyWith(
              fontSize: size,
              height: 1.0,
              letterSpacing: -size * 0.02,
            ),
          ),
          if (caption != null) ...[
            const SizedBox(height: AppSpacing.sm),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Text(
                caption!,
                style: AppText.bodyMuted.copyWith(fontSize: 17),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}
