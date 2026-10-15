import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../data/portfolio_data.dart';
import '../services/sfx.dart';
import '../theme/app_theme.dart';
import 'responsive_section.dart';
import 'reveal.dart';
import 'section_header.dart';

/// Resume stats as console-style achievements. Each one slides in like a
/// notification the first time it scrolls into view.
class TrophiesSection extends StatelessWidget {
  const TrophiesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final columns = width >= AppBreakpoints.tablet ? 2 : 1;
    final trophies = TrophiesData.trophies;

    return ResponsiveSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            index: '04',
            label: 'Trophies',
            title: 'Achievements unlocked',
            caption:
                '${trophies.length} of ${trophies.length} unlocked. Every number here is on my resume.',
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              const gap = AppSpacing.md;
              final tileWidth =
                  (constraints.maxWidth - gap * (columns - 1)) / columns;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (var i = 0; i < trophies.length; i++)
                    SizedBox(
                      width: tileWidth,
                      child: Reveal(
                        sideways: true,
                        slide: 0.25,
                        delay: Duration(milliseconds: 120 * (i % columns)),
                        onReveal: () => Future.delayed(
                          Duration(milliseconds: 250 + 120 * (i % columns)),
                          () => Sfx.play(Sound.ding),
                        ),
                        child: _TrophyToast(trophy: trophies[i]),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TrophyToast extends StatefulWidget {
  final Trophy trophy;

  const _TrophyToast({required this.trophy});

  @override
  State<_TrophyToast> createState() => _TrophyToastState();
}

class _TrophyToastState extends State<_TrophyToast> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.trophy;
    final isMobile = AppBreakpoints.isMobile(MediaQuery.sizeOf(context).width);

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: AppMotion.hover,
        padding: EdgeInsets.all(isMobile ? AppSpacing.sm : AppSpacing.md),
        decoration: BoxDecoration(
          color: _hover ? AppColors.raised : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _hover
                ? AppColors.gold.withValues(alpha: 0.5)
                : AppColors.line,
          ),
        ),
        child: Row(
          children: [
            // Gold trophy medallion, with a shimmer as it lands.
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [
                    Color(0xFFFFE08A),
                    AppColors.gold,
                    Color(0xFFB8862B),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withValues(
                      alpha: _hover ? 0.5 : 0.25,
                    ),
                    blurRadius: 18,
                  ),
                ],
              ),
              child: const Icon(
                Icons.emoji_events,
                color: Color(0xFF5A3D00),
                size: 26,
              ),
            ).animate().shimmer(
              delay: 500.ms,
              duration: 900.ms,
              color: Colors.white.withValues(alpha: 0.7),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ACHIEVEMENT UNLOCKED',
                    style: AppText.monoLabel.copyWith(
                      fontSize: 10,
                      color: AppColors.gold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(t.title, style: AppText.heading.copyWith(fontSize: 19)),
                  const SizedBox(height: 2),
                  Text(
                    t.detail,
                    style: AppText.bodyMuted.copyWith(
                      fontSize: 14,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              t.value,
              style: AppText.display.copyWith(
                fontSize: isMobile ? 30 : 40,
                color: AppColors.gold,
                letterSpacing: -1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
