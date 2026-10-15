import 'package:flutter/material.dart';
import '../data/portfolio_data.dart';
import '../theme/app_theme.dart';
import 'responsive_section.dart';
import 'section_header.dart';

class SkillsSection extends StatelessWidget {
  const SkillsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            index: '04',
            title: 'Stack',
            caption: 'What I reach for every day, and what I\'m still learning.',
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final cols = w >= 900 ? 4 : (w >= 440 ? 2 : 1);
              const gap = AppSpacing.lg;
              final colWidth = (w - gap * (cols - 1)) / cols;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final group in SkillsData.groups)
                    SizedBox(width: colWidth, child: _SkillGroupColumn(group: group)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SkillGroupColumn extends StatelessWidget {
  final SkillGroup group;

  const _SkillGroupColumn({required this.group});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          group.label.toUpperCase(),
          style: AppText.monoLabel.copyWith(color: AppColors.blue),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(height: 1, color: AppColors.text),
        for (final item in group.items)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.line)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    item,
                    style: AppText.body.copyWith(fontSize: 17, fontWeight: FontWeight.w500),
                  ),
                ),
                if (SkillsData.learning.contains(item))
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.blue.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'LEARNING',
                      style: AppText.monoLabel.copyWith(
                        fontSize: 10,
                        color: AppColors.blue,
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
