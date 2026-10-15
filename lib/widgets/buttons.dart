import 'package:flutter/material.dart';
import '../services/sfx.dart';
import '../theme/app_theme.dart';

/// Shared hover/press feedback: a slight lift on hover, a squish on press.
class Pressable extends StatefulWidget {
  final Widget Function(bool hover) builder;
  final VoidCallback onTap;
  final String? semanticLabel;

  const Pressable({
    super.key,
    required this.builder,
    required this.onTap,
    this.semanticLabel,
  });

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _hover = false;
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final scale = _down ? 0.96 : (_hover ? 1.02 : 1.0);
    return Semantics(
      button: true,
      label: widget.semanticLabel,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _down = true),
          onTapCancel: () => setState(() => _down = false),
          onTapUp: (_) => setState(() => _down = false),
          onTap: () {
            Sfx.play(Sound.click);
            widget.onTap();
          },
          child: AnimatedScale(
            scale: scale,
            duration: AppMotion.hover,
            curve: AppMotion.spring,
            child: widget.builder(_hover),
          ),
        ),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;

  const PrimaryButton({
    super.key,
    required this.label,
    this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      builder: (hover) => AnimatedContainer(
        duration: AppMotion.hover,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.blue,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: AppColors.blue.withValues(alpha: hover ? 0.55 : 0.3),
              blurRadius: hover ? 28 : 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppText.body.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 8),
              Icon(icon, size: 18, color: Colors.white),
            ],
          ],
        ),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;

  const SecondaryButton({
    super.key,
    required this.label,
    this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      builder: (hover) => AnimatedContainer(
        duration: AppMotion.hover,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: hover ? AppColors.raised : Colors.transparent,
          border: Border.all(
            color: hover ? AppColors.blue : AppColors.line,
            width: 1.2,
          ),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: AppColors.text),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: AppText.body.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
