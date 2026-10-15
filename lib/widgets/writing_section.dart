import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/sfx.dart';
import '../theme/app_theme.dart';
import 'responsive_section.dart';
import 'reveal.dart';
import 'section_header.dart';

class Article {
  final String title;
  final String url;
  final String platform;
  final String snippet;
  final int readMinutes;
  final String date;

  const Article({
    required this.title,
    required this.url,
    required this.platform,
    required this.snippet,
    required this.readMinutes,
    required this.date,
  });

  factory Article.fromJson(Map<String, dynamic> json) => Article(
    title: json['title'] as String,
    url: json['url'] as String,
    platform: json['platform'] as String,
    snippet: json['snippet'] as String? ?? '',
    readMinutes: json['readMinutes'] as int? ?? 1,
    date: json['date'] as String? ?? '',
  );

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

/// Article cards in a horizontal row you can drag or flick, like a game
/// library, with filter chips by platform. Hidden until there's something
/// in assets/articles.json.
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
        if (articles.isEmpty) return const SizedBox.shrink();

        final platforms = {for (final a in articles) a.platform}.toList();
        final shown = _platform == null
            ? articles
            : articles.where((a) => a.platform == _platform).toList();
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
                        count: articles.where((a) => a.platform == p).length,
                        selected: _platform == p,
                        onTap: () => _filter(p),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
              ],
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
