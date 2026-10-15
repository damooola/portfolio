import 'package:flutter/material.dart';
import '../data/portfolio_data.dart';
import '../theme/app_theme.dart';
import 'ledger_lines.dart';
import 'responsive_section.dart';
import 'section_header.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = AppBreakpoints.isMobile(width);
    final sideBySide = width >= AppBreakpoints.tablet;

    final bio = Text(
      ProfileData.about,
      style: AppText.heading.copyWith(
        fontSize: isMobile ? 22 : 28,
        fontWeight: FontWeight.w400,
        height: 1.4,
      ),
    );

    final facts = Column(
      children: [
        for (final (label, value) in ProfileData.facts)
          DotLeaderRow(label: label, value: value),
      ],
    );

    return ResponsiveSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(index: '02', title: 'About'),
          if (sideBySide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: bio),
                const SizedBox(width: AppSpacing.xl),
                Expanded(flex: 2, child: facts),
              ],
            )
          else ...[
            bio,
            const SizedBox(height: AppSpacing.lg),
            facts,
          ],
        ],
      ),
    );
  }
}
