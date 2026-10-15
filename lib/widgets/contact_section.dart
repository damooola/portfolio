import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/portfolio_data.dart';
import '../services/sfx.dart';
import '../theme/app_theme.dart';
import 'responsive_section.dart';
import 'reveal.dart';
import 'section_header.dart';
import 'toast.dart';

class ContactSection extends StatelessWidget {
  const ContactSection({super.key});

  static Future<void> open(String url) async {
    await launchUrl(Uri.parse(url), webOnlyWindowName: '_blank');
  }

  static void email() => open('mailto:${ProfileData.email}');

  static Future<void> copyEmail(BuildContext context) async {
    await Clipboard.setData(const ClipboardData(text: ProfileData.email));
    Sfx.play(Sound.click);
    if (context.mounted) showToast(context, 'Email copied');
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobile(MediaQuery.sizeOf(context).width);

    return ResponsiveSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            index: '06',
            label: 'Contact',
            title: 'Let\'s talk',
            caption:
                'Hiring, building something, or just want to argue about '
                'state management? My inbox is open.',
          ),
          Reveal(child: _EmailCard(isMobile: isMobile)),
          const SizedBox(height: AppSpacing.md),
          Reveal(
            delay: const Duration(milliseconds: 80),
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                _LinkChip(
                  icon: Icons.code,
                  label: 'GitHub',
                  detail: '@${ProfileData.githubHandle}',
                  onTap: () => open(ProfileData.githubUrl),
                ),
                _LinkChip(
                  icon: Icons.work_outline,
                  label: 'LinkedIn',
                  detail: 'Connect',
                  onTap: () => open(ProfileData.linkedinUrl),
                ),
                _LinkChip(
                  icon: Icons.edit_note,
                  label: 'Blog',
                  detail: 'Hashnode',
                  onTap: () => open(ProfileData.blogUrl),
                ),
                _LinkChip(
                  icon: Icons.palette_outlined,
                  label: 'Behance',
                  detail: 'Design',
                  onTap: () => open(ProfileData.behanceUrl),
                ),
                _LinkChip(
                  icon: Icons.description_outlined,
                  label: 'Resume',
                  detail: 'PDF',
                  onTap: () => open('assets/${ProfileData.resumeAssetPath}'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Container(height: 1, color: AppColors.line),
          const SizedBox(height: AppSpacing.md),
          Flex(
            direction: isMobile ? Axis.vertical : Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Built in Flutter, after hours.',
                style: AppText.monoLabel.copyWith(fontSize: 11),
              ),
              if (isMobile) const SizedBox(height: AppSpacing.xs),
              Text(
                '© ${DateTime.now().year} ${ProfileData.name.toUpperCase()}',
                style: AppText.monoLabel.copyWith(fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmailCard extends StatefulWidget {
  final bool isMobile;

  const _EmailCard({required this.isMobile});

  @override
  State<_EmailCard> createState() => _EmailCardState();
}

class _EmailCardState extends State<_EmailCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Copy email address ${ProfileData.email}',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: () => ContactSection.copyEmail(context),
          child: AnimatedContainer(
            duration: AppMotion.hover,
            width: double.infinity,
            padding: EdgeInsets.all(
              widget.isMobile ? AppSpacing.md : AppSpacing.lg,
            ),
            decoration: BoxDecoration(
              color: _hover ? AppColors.blueDeep : AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: _hover ? AppColors.blue : AppColors.line,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'EMAIL · CLICK TO COPY',
                      style: AppText.monoLabel.copyWith(fontSize: 11),
                    ),
                    const Spacer(),
                    AnimatedRotation(
                      turns: _hover ? 0 : -0.04,
                      duration: AppMotion.hover,
                      child: Icon(
                        Icons.copy_rounded,
                        size: 18,
                        color: _hover ? AppColors.text : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    ProfileData.email,
                    style: AppText.display.copyWith(
                      fontSize: widget.isMobile ? 30 : 52,
                      letterSpacing: -1,
                    ),
                  ),
                ),
                if (!widget.isMobile) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(text: 'or press '),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.night,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: AppColors.line),
                            ),
                            child: Text(
                              'E',
                              style: AppText.mono.copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const TextSpan(text: ' to open your mail app'),
                      ],
                    ),
                    style: AppText.bodyMuted.copyWith(fontSize: 14),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LinkChip extends StatefulWidget {
  final IconData icon;
  final String label;
  final String detail;
  final VoidCallback onTap;

  const _LinkChip({
    required this.icon,
    required this.label,
    required this.detail,
    required this.onTap,
  });

  @override
  State<_LinkChip> createState() => _LinkChipState();
}

class _LinkChipState extends State<_LinkChip> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      link: true,
      label: widget.label,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: () {
            Sfx.play(Sound.click);
            widget.onTap();
          },
          child: AnimatedContainer(
            duration: AppMotion.hover,
            padding: const EdgeInsets.fromLTRB(16, 14, 20, 14),
            decoration: BoxDecoration(
              color: _hover ? AppColors.raised : AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _hover ? AppColors.blue : AppColors.line,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.icon,
                  size: 20,
                  color: _hover ? AppColors.blue : AppColors.text,
                ),
                const SizedBox(width: 12),
                Text(
                  widget.label,
                  style: AppText.body.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.detail,
                  style: AppText.mono.copyWith(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
                AnimatedSlide(
                  offset: Offset(_hover ? 0.3 : 0, 0),
                  duration: AppMotion.hover,
                  curve: AppMotion.spring,
                  child: const Padding(
                    padding: EdgeInsets.only(left: 6),
                    child: Icon(
                      Icons.north_east,
                      size: 14,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
