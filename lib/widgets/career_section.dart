import 'package:flutter/material.dart';
import '../data/portfolio_data.dart';
import '../theme/app_theme.dart';
import 'hero_section.dart' show PulsingDot;
import 'responsive_section.dart';
import 'reveal.dart';
import 'section_header.dart';

/// Work history as a vertical log, newest first. The current role gets a
/// live green node.
class CareerSection extends StatelessWidget {
  const CareerSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobile(MediaQuery.sizeOf(context).width);
    const roles = CareerData.roles;

    return ResponsiveSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            index: '02',
            label: 'Career',
            title: 'Career log',
            caption:
                'Every save file so far, newest first. Dates match my LinkedIn.',
          ),
          for (var i = 0; i < roles.length; i++)
            Reveal(
              delay: Duration(milliseconds: 40 * (i % 3)),
              child: _RoleRow(
                role: roles[i],
                last: i == roles.length - 1,
                compact: isMobile,
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          Reveal(
            child: Row(
              children: [
                const Icon(
                  Icons.school_outlined,
                  size: 18,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    CareerData.education,
                    style: AppText.bodyMuted.copyWith(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleRow extends StatefulWidget {
  final Role role;
  final bool last;
  final bool compact;

  const _RoleRow({
    required this.role,
    required this.last,
    required this.compact,
  });

  @override
  State<_RoleRow> createState() => _RoleRowState();
}

class _RoleRowState extends State<_RoleRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final r = widget.role;
    final dates = '${r.start} — ${r.end}'.toUpperCase();

    final card = AnimatedContainer(
      duration: AppMotion.hover,
      padding: EdgeInsets.all(widget.compact ? AppSpacing.sm : 20),
      decoration: BoxDecoration(
        color: _hover ? AppColors.raised : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: r.current
              ? AppColors.blue.withValues(alpha: 0.6)
              : (_hover
                    ? AppColors.blue.withValues(alpha: 0.35)
                    : AppColors.line),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.compact) ...[
            Text(dates, style: AppText.monoLabel.copyWith(fontSize: 10)),
            const SizedBox(height: 4),
          ],
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              Text(r.title, style: AppText.heading.copyWith(fontSize: 19)),
              Text(
                '@ ${r.company}',
                style: AppText.heading.copyWith(
                  fontSize: 19,
                  color: AppColors.blue,
                ),
              ),
              if (r.current)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.online.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'NOW',
                    style: AppText.mono.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.online,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            [?r.product, r.place].join(' · '),
            style: AppText.monoLabel.copyWith(fontSize: 11),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            r.summary,
            style: AppText.bodyMuted.copyWith(fontSize: 15, height: 1.55),
          ),
          if (r.tags.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final t in r.tags)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.night,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: Text(
                      t,
                      style: AppText.mono.copyWith(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );

    // Timeline rail: a node per role joined by a line.
    final rail = SizedBox(
      width: 28,
      child: Column(
        children: [
          const SizedBox(height: 22),
          if (r.current)
            const SizedBox(
              width: 12,
              height: 12,
              child: Center(child: PulsingDot()),
            )
          else
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: AppColors.night,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.textMuted, width: 2),
              ),
            ),
          if (!widget.last)
            Expanded(
              child: Container(
                width: 2,
                margin: const EdgeInsets.only(top: 6),
                color: AppColors.line,
              ),
            ),
        ],
      ),
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!widget.compact)
              SizedBox(
                width: 170,
                child: Padding(
                  padding: const EdgeInsets.only(top: 20, right: AppSpacing.sm),
                  child: Text(
                    dates,
                    textAlign: TextAlign.right,
                    style: AppText.monoLabel.copyWith(
                      fontSize: 11,
                      color: r.current ? AppColors.text : AppColors.textMuted,
                    ),
                  ),
                ),
              ),
            rail,
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: card,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
