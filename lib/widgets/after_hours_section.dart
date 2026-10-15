import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'now_playing.dart';
import 'responsive_section.dart';
import 'reveal.dart';
import 'section_header.dart';

/// The personal side, kept out of the way of the pitch: what I'm learning,
/// my chess form, my playlist and Chelsea's last result.
class AfterHoursSection extends StatelessWidget {
  const AfterHoursSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            index: '04',
            label: 'After hours',
            title: 'After hours',
            caption:
                'What I\'m up to when the laptop closes (mostly). Hover a tile '
                'to peek inside, click to pin it open.',
          ),
          Reveal(child: NowPlayingStrip()),
          SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}
