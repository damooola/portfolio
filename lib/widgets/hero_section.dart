import 'package:flutter/material.dart';
import '../data/portfolio_data.dart';
import '../theme/app_theme.dart';
import 'identity_card.dart';
import 'responsive_section.dart';

class HeroSection extends StatelessWidget {
  final VoidCallback onViewWork;
  final VoidCallback onContact;

  const HeroSection({
    super.key,
    required this.onViewWork,
    required this.onContact,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = AppBreakpoints.isMobile(width);
    final sideBySide = width >= AppBreakpoints.tablet;

    final intro = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(ProfileData.heroEyebrow, style: AppText.monoLabel),
        const SizedBox(height: AppSpacing.md),
        Text(
          ProfileData.heroGreeting,
          style: AppText.display.copyWith(
            fontSize: isMobile ? 52 : 88,
            height: 0.95,
            letterSpacing: isMobile ? -1.5 : -2.5,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Text(
            ProfileData.tagline,
            style: AppText.body.copyWith(fontSize: isMobile ? 18 : 21, height: 1.5),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            _PrimaryButton(label: 'See the receipts  ↓', onTap: onViewWork),
            _SecondaryButton(label: 'Say hello', onTap: onContact),
          ],
        ),
      ],
    );

    return ResponsiveSection(
      child: sideBySide
          ? Row(
              children: [
                Expanded(child: intro),
                const SizedBox(width: AppSpacing.xl),
                const IdentityCard(),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                intro,
                const SizedBox(height: AppSpacing.xl),
                const IdentityCard(),
              ],
            ),
    );
  }
}

class _PrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _PrimaryButton({required this.label, required this.onTap});

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          decoration: BoxDecoration(
            color: _hover ? AppColors.text : AppColors.blue,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            widget.label,
            style: AppText.body.copyWith(
              color: _hover ? AppColors.night : AppColors.text,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _SecondaryButton({required this.label, required this.onTap});

  @override
  State<_SecondaryButton> createState() => _SecondaryButtonState();
}

class _SecondaryButtonState extends State<_SecondaryButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(
              color: _hover ? AppColors.text : AppColors.textMuted,
            ),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            widget.label,
            style: AppText.body.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
