import 'dart:ui';

import 'package:flutter/material.dart';
import '../data/portfolio_data.dart';
import '../theme/app_theme.dart';

class NavLink {
  final String label;
  final VoidCallback onTap;

  const NavLink(this.label, this.onTap);
}

class NavBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onHome;
  final List<NavLink> links;
  final List<Widget> trailing;

  const NavBar({
    super.key,
    required this.onHome,
    required this.links,
    this.trailing = const [],
  });

  @override
  Size get preferredSize => const Size.fromHeight(68);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = AppBreakpoints.isMobile(width);
    // Phones only get room for the two links recruiters need most.
    final shown = isMobile
        ? links.where((l) => l.label == 'Work' || l.label == 'Contact')
        : links;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.night.withValues(alpha: 0.72),
            border: const Border(bottom: BorderSide(color: AppColors.line)),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? AppSpacing.sm : AppSpacing.xl,
          ),
          child: SafeArea(
            bottom: false,
            child: Center(
              heightFactor: 1,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: AppBreakpoints.contentWidth(width),
                ),
                child: SizedBox(
                  height: preferredSize.height,
                  child: Row(
                    children: [
                      _Monogram(onTap: onHome),
                      const Spacer(),
                      for (final link in shown) ...[
                        _NavText(link: link),
                        SizedBox(
                          width: isMobile ? AppSpacing.sm : AppSpacing.md,
                        ),
                      ],
                      ...trailing,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Monogram extends StatelessWidget {
  final VoidCallback onTap;

  const _Monogram({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Semantics(
          label: '${ProfileData.name}, back to top',
          button: true,
          child: Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.blueDeep,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.blue.withValues(alpha: 0.5)),
            ),
            child: Text(
              ProfileData.initials,
              style: AppText.display.copyWith(
                fontSize: 16,
                letterSpacing: -0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavText extends StatefulWidget {
  final NavLink link;

  const _NavText({required this.link});

  @override
  State<_NavText> createState() => _NavTextState();
}

class _NavTextState extends State<_NavText> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.link.onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.link.label,
              style: AppText.body.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _hover ? AppColors.text : AppColors.textMuted,
              ),
            ),
            AnimatedContainer(
              duration: AppMotion.hover,
              curve: AppMotion.settle,
              margin: const EdgeInsets.only(top: 3),
              height: 1.5,
              width: _hover ? 18 : 0,
              color: AppColors.blue,
            ),
          ],
        ),
      ),
    );
  }
}
