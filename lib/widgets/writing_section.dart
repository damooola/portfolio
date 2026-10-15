import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/portfolio_data.dart';
import '../services/sfx.dart';
import '../theme/app_theme.dart';
import 'responsive_section.dart';
import 'reveal.dart';
import 'section_header.dart';

class Article {
  final String title;
  final String url;
  final String platform;

  /// Other platforms the same piece is cross-posted to.
  final List<String> alsoOn;
  final String snippet;
  final int readMinutes;
  final String date;

  const Article({
    required this.title,
    required this.url,
    required this.platform,
    this.alsoOn = const [],
    required this.snippet,
    required this.readMinutes,
    required this.date,
  });

  factory Article.fromJson(Map<String, dynamic> json) => Article(
    title: json['title'] as String,
    url: json['url'] as String,
    platform: json['platform'] as String,
    alsoOn: [for (final p in json['alsoOn'] as List? ?? const []) p as String],
    snippet: json['snippet'] as String? ?? '',
    readMinutes: json['readMinutes'] as int? ?? 1,
    date: json['date'] as String? ?? '',
  );

  bool isOn(String p) => platform == p || alsoOn.contains(p);

  /// Articles come from assets/articles.json, written at build time by
  /// tool/fetch_articles.dart.
  static Future<List<Article>> load() async {
    final raw = await rootBundle.loadString('assets/articles.json');
    final list = jsonDecode(raw) as List<dynamic>;
    return [
      for (final item in list) Article.fromJson(item as Map<String, dynamic>),
    ];
  }
}

/// Technical articles in a horizontal row you can drag or flick, like a
/// game library, with filter chips by platform. Below them, a few personal
/// essays shown as phone screenshots.
class WritingSection extends StatefulWidget {
  const WritingSection({super.key});

  @override
  State<WritingSection> createState() => _WritingSectionState();
}

class _WritingSectionState extends State<WritingSection> {
  late final Future<List<Article>> _articles = Article.load();
  final _scroll = ScrollController();
  String? _platform;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _filter(String? platform) {
    if (platform == _platform) return;
    Sfx.play(Sound.click);
    setState(() => _platform = platform);
    if (_scroll.hasClients) {
      _scroll.animateTo(0, duration: AppMotion.big, curve: AppMotion.settle);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _articles,
      builder: (context, snapshot) {
        final articles = snapshot.data ?? const <Article>[];
        const personal = PersonalPostsData.posts;
        if (articles.isEmpty && personal.isEmpty) {
          return const SizedBox.shrink();
        }

        final platforms = {
          for (final a in articles) ...[a.platform, ...a.alsoOn],
        }.toList();
        final shown = _platform == null
            ? articles
            : articles.where((a) => a.isOn(_platform!)).toList();
        final isMobile = AppBreakpoints.isMobile(
          MediaQuery.sizeOf(context).width,
        );

        return ResponsiveSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(
                index: '04',
                label: 'Writing',
                title: 'Notes from the desk',
                caption:
                    'Things I figured out the hard way, written down so you don\'t have to.',
              ),
              if (articles.isNotEmpty)
                _RowLabel(
                  'On the record',
                  '${articles.length} technical posts · Flutter, mostly',
                ),
              if (platforms.length > 1) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _FilterChip(
                      label: 'All',
                      count: articles.length,
                      selected: _platform == null,
                      onTap: () => _filter(null),
                    ),
                    for (final p in platforms)
                      _FilterChip(
                        label: p,
                        count: articles.where((a) => a.isOn(p)).length,
                        selected: _platform == p,
                        onTap: () => _filter(p),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              if (articles.isNotEmpty)
                Reveal(
                  child: SizedBox(
                    height: 280,
                    // Mouse drag scrolls the row too, like flicking a library.
                    child: ScrollConfiguration(
                      behavior: const _DragEverywhere(),
                      child: ListView.separated(
                        controller: _scroll,
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        clipBehavior: Clip.none,
                        itemCount: shown.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(width: AppSpacing.sm),
                        itemBuilder: (context, i) => _ArticleCard(
                          key: ValueKey(shown[i].url),
                          article: shown[i],
                          width: isMobile ? 280 : 340,
                        ),
                      ),
                    ),
                  ),
                ),
              if (shown.length > 2) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'DRAG OR SCROLL SIDEWAYS →',
                  style: AppText.monoLabel.copyWith(fontSize: 10),
                ),
              ],
              if (personal.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xl),
                const _RowLabel(
                  'Off the clock',
                  'Personal essays on Medium · not about code at all',
                ),
                Reveal(
                  child: Wrap(
                    spacing: AppSpacing.lg,
                    runSpacing: AppSpacing.lg,
                    alignment: isMobile
                        ? WrapAlignment.center
                        : WrapAlignment.start,
                    children: [
                      for (var i = 0; i < personal.length; i++)
                        _PersonalPhone(post: personal[i], index: i),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _DragEverywhere extends MaterialScrollBehavior {
  const _DragEverywhere();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
  };
}

class _FilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: AppMotion.hover,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: selected ? AppColors.blue : AppColors.surface,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: selected ? AppColors.blue : AppColors.line,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: AppText.body.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : AppColors.text,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '$count',
                  style: AppText.mono.copyWith(
                    fontSize: 11,
                    color: selected ? Colors.white70 : AppColors.textMuted,
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

class _ArticleCard extends StatefulWidget {
  final Article article;
  final double width;

  const _ArticleCard({super.key, required this.article, required this.width});

  @override
  State<_ArticleCard> createState() => _ArticleCardState();
}

class _ArticleCardState extends State<_ArticleCard> {
  bool _hover = false;

  String get _date {
    final parts = widget.article.date.split('-');
    if (parts.length != 3) return '';
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    final m = int.tryParse(parts[1]);
    if (m == null || m < 1 || m > 12) return '';
    return '${months[m - 1]} ${parts[0]}';
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.article;

    return Semantics(
      link: true,
      label: '${a.title}, on ${a.platform}',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: () {
            Sfx.play(Sound.click);
            launchUrl(Uri.parse(a.url), webOnlyWindowName: '_blank');
          },
          child: AnimatedSlide(
            offset: Offset(0, _hover ? -0.02 : 0),
            duration: AppMotion.hover,
            curve: AppMotion.spring,
            child: AnimatedContainer(
              duration: AppMotion.hover,
              width: widget.width,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: _hover ? AppColors.raised : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _hover ? AppColors.blue : AppColors.line,
                ),
                boxShadow: _hover
                    ? [
                        BoxShadow(
                          color: AppColors.blue.withValues(alpha: 0.15),
                          blurRadius: 30,
                        ),
                      ]
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.blueDeep,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          a.platform.toUpperCase(),
                          style: AppText.mono.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      for (final other in a.alsoOn)
                        Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.line),
                            ),
                            child: Text(
                              '+ ${other.toUpperCase()}',
                              style: AppText.mono.copyWith(
                                fontSize: 10,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                        ),
                      const Spacer(),
                      Text(
                        _date,
                        style: AppText.monoLabel.copyWith(fontSize: 10),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    a.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.heading.copyWith(fontSize: 20, height: 1.2),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      a.snippet,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.bodyMuted.copyWith(
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        '${a.readMinutes} MIN READ',
                        style: AppText.monoLabel.copyWith(fontSize: 10),
                      ),
                      const Spacer(),
                      AnimatedSlide(
                        offset: Offset(_hover ? 0.2 : 0, 0),
                        duration: AppMotion.hover,
                        curve: AppMotion.spring,
                        child: Icon(
                          Icons.arrow_forward,
                          size: 18,
                          color: _hover ? AppColors.blue : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RowLabel extends StatelessWidget {
  final String title;
  final String detail;

  const _RowLabel(this.title, this.detail);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: AppSpacing.sm,
        runSpacing: 4,
        children: [
          Text(title, style: AppText.heading.copyWith(fontSize: 24)),
          Text(detail, style: AppText.monoLabel.copyWith(fontSize: 11)),
        ],
      ),
    );
  }
}

/// A personal Medium essay, shown as a screenshot of the article on a
/// phone. Fanned out like phones left on a desk; straightens and lifts on
/// hover, and a click opens the post.
class _PersonalPhone extends StatefulWidget {
  final PersonalPost post;
  final int index;

  const _PersonalPhone({required this.post, required this.index});

  @override
  State<_PersonalPhone> createState() => _PersonalPhoneState();
}

class _PersonalPhoneState extends State<_PersonalPhone> {
  static const _width = 220.0;
  static const _height = 400.0;
  static const _tilts = [-0.006, 0.004, -0.003]; // in turns

  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.post;
    final reduced = AppMotion.reduced(context);

    return Semantics(
      link: true,
      label: '${p.title}, personal essay on Medium',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: () {
            Sfx.play(Sound.click);
            launchUrl(Uri.parse(p.url), webOnlyWindowName: '_blank');
          },
          child: SizedBox(
            width: _width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedRotation(
                  turns: _hover || reduced ? 0 : _tilts[widget.index % 3],
                  duration: AppMotion.big,
                  curve: AppMotion.spring,
                  child: AnimatedSlide(
                    offset: Offset(0, _hover && !reduced ? -0.03 : 0),
                    duration: AppMotion.hover,
                    curve: AppMotion.spring,
                    child: _phone(p),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  p.title,
                  style: AppText.heading.copyWith(fontSize: 17, height: 1.25),
                ),
                const SizedBox(height: 2),
                Text(
                  '${p.date} · ${p.readMinutes} MIN READ',
                  style: AppText.monoLabel.copyWith(fontSize: 10),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _phone(PersonalPost p) {
    return AnimatedContainer(
      duration: AppMotion.hover,
      width: _width,
      height: _height,
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: _hover ? AppColors.blue : Colors.white.withValues(alpha: 0.14),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: _hover ? 40 : 24,
            offset: Offset(0, _hover ? 22 : 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              p.image,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              semanticLabel: 'Screenshot of ${p.title} on Medium',
            ),
            // Fade the bottom so the article reads as "keep going".
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(0, 0.35),
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, AppColors.night],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 14,
              child: Center(
                child: AnimatedContainer(
                  duration: AppMotion.hover,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _hover ? AppColors.blue : AppColors.raised,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Read on Medium ↗',
                    style: AppText.body.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
