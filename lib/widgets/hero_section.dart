import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../data/portfolio_data.dart';
import '../theme/app_theme.dart';
import 'buttons.dart';
import 'contact_section.dart';
import 'responsive_section.dart';

class HeroSection extends StatelessWidget {
  final VoidCallback onViewWork;
  final VoidCallback onContact;

  /// On the big name, so the nav can tell when it has scrolled away.
  final Key? nameKey;

  const HeroSection({
    super.key,
    required this.onViewWork,
    required this.onContact,
    this.nameKey,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isMobile = AppBreakpoints.isMobile(size.width);
    final nameSize = isMobile
        ? 64.0
        : (AppBreakpoints.isDesktop(size.width) ? 148.0 : 104.0);
    final reduced = AppMotion.reduced(context);

    // Each line of the name fits its own row, so long names never overflow.
    Widget nameLine(String word, int offset) => FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < word.length; i++)
            _DropLetter(
              letter: word[i],
              index: offset + i,
              size: nameSize,
              reduced: reduced,
            ),
        ],
      ),
    );

    // Wide screens put the numbers beside the name, in the empty right half,
    // so they're above the fold. Narrower screens stack them under the
    // buttons.
    final statsBeside = AppBreakpoints.isDesktop(size.width);

    final intro = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const _StatusPill(),
        const SizedBox(height: AppSpacing.lg),
        Column(
          key: nameKey,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            nameLine(ProfileData.firstName, 0),
            nameLine(ProfileData.lastName, ProfileData.firstName.length),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '${ProfileData.role} ',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                TextSpan(
                  text: ProfileData.tagline,
                  style: const TextStyle(color: AppColors.textMuted),
                ),
              ],
            ),
            style: AppText.body.copyWith(
              fontSize: isMobile ? 18 : 21,
              height: 1.5,
            ),
          ),
        ).animate().fadeIn(delay: 600.ms, duration: 500.ms),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            PrimaryButton(
              label: 'See the work',
              icon: Icons.arrow_downward,
              onTap: onViewWork,
            ),
            SecondaryButton(
              label: 'Resume',
              icon: Icons.download_rounded,
              onTap: () =>
                  ContactSection.open('assets/${ProfileData.resumeAssetPath}'),
            ),
            SecondaryButton(label: 'Say hello', onTap: onContact),
          ],
        ).animate().fadeIn(delay: 750.ms, duration: 500.ms),
        if (!statsBeside) ...[
          const SizedBox(height: AppSpacing.xl),
          const HeroStats().animate().fadeIn(delay: 900.ms, duration: 500.ms),
        ],
      ],
    );

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: isMobile ? 0 : size.height * 0.88),
      child: ResponsiveSection(
        child: statsBeside
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(child: intro),
                  const SizedBox(width: AppSpacing.xl),
                  const SizedBox(
                    width: 380,
                    child: HeroStats(columns: 2, beside: true),
                  ).animate().fadeIn(delay: 900.ms, duration: 500.ms),
                ],
              )
            : intro,
      ),
    );
  }
}

/// One letter of the hero name. Drops in on load with a spring, and hops
/// when the cursor passes over it.
class _DropLetter extends StatefulWidget {
  final String letter;
  final int index;
  final double size;
  final bool reduced;

  const _DropLetter({
    required this.letter,
    required this.index,
    required this.size,
    required this.reduced,
  });

  @override
  State<_DropLetter> createState() => _DropLetterState();
}

class _DropLetterState extends State<_DropLetter> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final letter = Text(
      widget.letter,
      style: AppText.display.copyWith(
        fontSize: widget.size,
        height: 0.92,
        letterSpacing: -widget.size * 0.02,
        color: _hover ? AppColors.blue : AppColors.text,
      ),
    );

    final hopping = MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedSlide(
        offset: Offset(0, _hover && !widget.reduced ? -0.08 : 0),
        duration: AppMotion.hover,
        curve: AppMotion.spring,
        child: letter,
      ),
    );

    final delay = AppMotion.stagger * widget.index;
    if (widget.reduced) {
      return hopping.animate().fadeIn(delay: delay, duration: 300.ms);
    }
    return hopping
        .animate()
        .fadeIn(delay: delay, duration: 200.ms)
        .slideY(
          begin: -0.6,
          end: 0,
          delay: delay,
          duration: AppMotion.big,
          curve: AppMotion.spring,
        );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const PulsingDot(),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              ProfileData.status,
              style: AppText.mono.copyWith(fontSize: 13, color: AppColors.text),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}

/// Green "online" dot with a soft ring that breathes.
class PulsingDot extends StatelessWidget {
  final Color color;

  const PulsingDot({super.key, this.color = AppColors.online});

  @override
  Widget build(BuildContext context) {
    final dot = Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
    if (AppMotion.reduced(context)) return dot;

    return SizedBox(
      width: 8,
      height: 8,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
              )
              .animate(onPlay: (c) => c.repeat())
              .scaleXY(
                begin: 1,
                end: 2.6,
                duration: 1600.ms,
                curve: Curves.easeOut,
              )
              .fadeOut(duration: 1600.ms),
          dot,
        ],
      ),
    );
  }
}

/// The headline numbers, compact: big gold figure, a few words under it.
/// Hover (or long-press) one for the full sentence. Every figure is from
/// the resume.
class HeroStats extends StatelessWidget {
  /// Fixed column count; otherwise it picks one from the width.
  final int? columns;

  /// Sitting beside the name: a left rule instead of a top one.
  final bool beside;

  const HeroStats({super.key, this.columns, this.beside = false});

  @override
  Widget build(BuildContext context) {
    const stats = TrophiesData.trophies;
    return LayoutBuilder(
      builder: (context, box) {
        final count =
            columns ??
            (box.maxWidth >= 980 ? 6 : (box.maxWidth >= 560 ? 3 : 2));
        // Leave room for the padding and the 1px divider, rounded down so
        // the last column never wraps over by a fraction.
        final width =
            ((box.maxWidth - (beside ? AppSpacing.md : 0) - 2) / count)
                .floorToDouble();
        return Container(
          padding: beside
              ? const EdgeInsets.only(left: AppSpacing.md)
              : const EdgeInsets.only(top: AppSpacing.md),
          decoration: BoxDecoration(
            border: beside
                ? const Border(left: BorderSide(color: AppColors.line))
                : const Border(top: BorderSide(color: AppColors.line)),
          ),
          child: Wrap(
            runSpacing: beside ? AppSpacing.lg : AppSpacing.md,
            children: [
              for (final (i, t) in stats.indexed)
                SizedBox(
                      width: width,
                      child: Tooltip(
                        message: t.detail,
                        waitDuration: const Duration(milliseconds: 250),
                        child: Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.sm),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t.value,
                                style: AppText.display.copyWith(
                                  fontSize: 30,
                                  color: AppColors.gold,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                t.label.toUpperCase(),
                                style: AppText.monoLabel.copyWith(
                                  fontSize: 10.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .animate()
                    .fadeIn(delay: (1000 + 60 * i).ms, duration: 300.ms)
                    .slideY(
                      begin: 0.3,
                      end: 0,
                      delay: (1000 + 60 * i).ms,
                      duration: AppMotion.big,
                      curve: AppMotion.settle,
                    ),
            ],
          ),
        );
      },
    );
  }
}
