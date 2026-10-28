import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Centers content, caps its width on large screens, and scales padding
/// by breakpoint. Wrap every top-level section in this for consistent
/// rhythm down the page.
class ResponsiveSection extends StatelessWidget {
  final Widget child;
  final Color? background;

  const ResponsiveSection({super.key, required this.child, this.background});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = AppBreakpoints.isMobile(width);
    final contentWidth = AppBreakpoints.contentWidth(width);

    return Container(
      width: double.infinity,
      color: background,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? AppSpacing.sm : AppSpacing.xl,
        // Phones get tighter rhythm: 2 × xl left ~150px gaps that read as the
        // end of the page.
        vertical: isMobile ? AppSpacing.lg : AppSpacing.xxl,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: contentWidth),
          child: SizedBox(width: double.infinity, child: child),
        ),
      ),
    );
  }
}
