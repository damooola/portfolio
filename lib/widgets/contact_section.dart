import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/portfolio_data.dart';
import '../theme/app_theme.dart';
import 'ledger_lines.dart';
import 'responsive_section.dart';
import 'section_header.dart';

class ContactSection extends StatelessWidget {
  const ContactSection({super.key});

  Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, webOnlyWindowName: '_blank');
    }
  }

  @override
  Widget build(BuildContext context) {
    final faded = AppColors.night.withValues(alpha: 0.5);

    return ResponsiveSection(
      background: AppColors.text,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            index: '05',
            title: 'Let\'s talk',
            caption:
                'Always happy to talk mobile engineering, fintech, or Go — '
                'reach out however\'s easiest.',
            onDark: true,
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              children: [
                _ContactRow(
                  label: 'EMAIL',
                  value: ProfileData.email,
                  onTap: () => _open('mailto:${ProfileData.email}'),
                ),
                _ContactRow(
                  label: 'GITHUB',
                  value: '@${ProfileData.githubHandle} ↗',
                  onTap: () => _open(ProfileData.githubUrl),
                ),
                _ContactRow(
                  label: 'LINKEDIN',
                  value: 'Connect ↗',
                  onTap: () => _open(ProfileData.linkedinUrl),
                ),
                _ContactRow(
                  label: 'RESUME',
                  value: 'Download PDF ↓',
                  onTap: () => _open('assets/${ProfileData.resumeAssetPath}'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.xs,
            children: [
              Text(
                '© ${DateTime.now().year} ${ProfileData.name.toUpperCase()}',
                style: AppText.monoLabel.copyWith(color: faded, fontSize: 11),
              ),
              Text(
                'BUILT WITH FLUTTER WEB · LAGOS',
                style: AppText.monoLabel.copyWith(color: faded, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContactRow extends StatefulWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _ContactRow({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  State<_ContactRow> createState() => _ContactRowState();
}

class _ContactRowState extends State<_ContactRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: DotLeaderRow(
          label: widget.label,
          value: widget.value,
          labelStyle: AppText.monoLabel.copyWith(color: AppColors.blue),
          dotColor: AppColors.night.withValues(alpha: _hover ? 0.5 : 0.2),
          valueStyle: AppText.body.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: _hover ? AppColors.blue : AppColors.night,
          ),
        ),
      ),
    );
  }
}
