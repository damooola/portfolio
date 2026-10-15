import 'package:flutter/material.dart';
import '../data/portfolio_data.dart';
import '../theme/app_theme.dart';

class NavBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onAbout;
  final VoidCallback onWork;
  final VoidCallback onContact;

  const NavBar({
    super.key,
    required this.onAbout,
    required this.onWork,
    required this.onContact,
  });

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = AppBreakpoints.isMobile(width);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.night.withValues(alpha: 0.94),
        border: const Border(bottom: BorderSide(color: AppColors.line)),
      ),
      padding: EdgeInsets.symmetric(horizontal: isMobile ? AppSpacing.sm : AppSpacing.xl),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Flexible(
              child: Text(
                ProfileData.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.heading.copyWith(fontSize: 18),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            const Spacer(),
            if (!isMobile) ...[
              _NavLink(label: 'ABOUT', onTap: onAbout),
              const SizedBox(width: AppSpacing.md),
            ],
            _NavLink(label: 'WORK', onTap: onWork),
            SizedBox(width: isMobile ? AppSpacing.sm : AppSpacing.md),
            _NavLink(label: 'CONTACT', onTap: onContact),
          ],
        ),
      ),
    );
  }
}

class _NavLink extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _NavLink({required this.label, required this.onTap});

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Text(
          widget.label,
          style: AppText.monoLabel.copyWith(
            color: _hover ? AppColors.blue : AppColors.text,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
