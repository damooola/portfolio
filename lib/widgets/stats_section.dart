import 'package:flutter/material.dart';
import '../data/portfolio_data.dart';
import '../theme/app_theme.dart';
import 'responsive_section.dart';
import 'section_header.dart';

/// Dashboard-style KPI tiles, all figures taken from the resume.
class StatsSection extends StatelessWidget {
  const StatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            index: '01',
            title: 'Ledger',
            caption: 'A few figures from apps I\'ve shipped. Rounded, never inflated.',
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final cols = w >= 900 ? 4 : (w >= 440 ? 2 : 1);
              const gap = AppSpacing.sm;
              final tileWidth = (w - gap * (cols - 1)) / cols;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final stat in StatsData.stats)
                    SizedBox(width: tileWidth, child: _StatTile(stat: stat)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final Stat stat;

  const _StatTile({required this.stat});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 200),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(stat.label, style: AppText.monoLabel.copyWith(fontSize: 11)),
              const Spacer(),
              if (stat.trend != null) _TrendBadge(trend: stat.trend!),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              stat.value,
              style: AppText.mono.copyWith(fontSize: 52, height: 1, letterSpacing: -1),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            stat.caption,
            style: AppText.bodyMuted.copyWith(fontSize: 14, height: 1.45),
          ),
        ],
      ),
    );
  }
}

class _TrendBadge extends StatelessWidget {
  final StatTrend trend;

  const _TrendBadge({required this.trend});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.blue.withValues(alpha: 0.3),
        shape: BoxShape.circle,
      ),
      child: Icon(
        trend == StatTrend.up ? Icons.arrow_upward : Icons.arrow_downward,
        size: 14,
        color: AppColors.blue,
      ),
    );
  }
}
