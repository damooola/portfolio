// Pulls my articles from each platform and writes them to
// assets/articles.json for the Writing section.
//
// Medium and Hashnode block cross-origin requests from a browser, so the
// site can't fetch these live. Run this whenever you publish something:
//
//   dart run tool/fetch_articles.dart
//
// then rebuild the site. Any source that fails is skipped with a warning,
// and the existing file is left alone if every source fails.
//
// The same article cross-posted to several platforms becomes one card that
// lists every platform (first source below wins as the main link).

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

/// Platforms with an RSS feed, in priority order. Medium is left out on
/// purpose: it's personal essays, and the few I show are hand-picked in
/// `PersonalPostsData` (lib/data/portfolio_data.dart).
const feeds = <String, String>{
  'Hashnode': 'https://daily-flutters.hashnode.dev/rss.xml',
};

/// Coder Legion has no per-user feed, so read the profile page for post
/// links, then each post's Open Graph tags.
const coderLegionProfile = 'https://coderlegion.com/user/damolanelson';

const _outPath = 'assets/articles.json';
const _wordsPerMinute = 220;
const _snippetLength = 180;
const _headers = {'User-Agent': 'Mozilla/5.0 (portfolio article fetcher)'};

typedef ArticleJson = Map<String, Object>;

Future<void> main() async {
  final sources = <String, Future<List<ArticleJson>> Function()>{
    for (final MapEntry(key: platform, value: url) in feeds.entries)
      platform: () => _fromFeed(platform, url),
    'Coder Legion': () => _fromCoderLegion(coderLegionProfile),
  };

  final all = <ArticleJson>[];
  var failures = 0;
  for (final MapEntry(key: platform, value: load) in sources.entries) {
    try {
      final found = await load();
      all.addAll(found);
      stdout.writeln('$platform: ${found.length} articles');
    } catch (e) {
      failures++;
      stderr.writeln('$platform: skipped ($e)');
    }
  }

  if (failures == sources.length) {
    stderr.writeln('Every source failed; leaving $_outPath unchanged.');
    exitCode = 1;
    return;
  }

  final articles = _mergeCrossPosts(all)
    ..sort((a, b) => (b['date'] as String).compareTo(a['date'] as String));
  await File(
    _outPath,
  ).writeAsString('${const JsonEncoder.withIndent('  ').convert(articles)}\n');
  stdout.writeln('Wrote ${articles.length} articles to $_outPath');
}

Future<String> _get(String url) async {
  final response = await http.get(Uri.parse(url), headers: _headers);
  if (response.statusCode != 200) {
    throw HttpException('HTTP ${response.statusCode} for $url');
  }
  return utf8.decode(response.bodyBytes);
}

Future<List<ArticleJson>> _fromFeed(String platform, String url) async {
  final items = XmlDocument.parse(await _get(url)).findAllElements('item');
  return [
    for (final item in items)
      _article(
        title: _text(item, 'title') ?? 'Untitled',
        url: _text(item, 'link') ?? url,
        platform: platform,
        html:
            _text(item, 'content:encoded') ?? _text(item, 'description') ?? '',
        date: _rssDate(_text(item, 'pubDate')),
      ),
  ];
}

Future<List<ArticleJson>> _fromCoderLegion(String profileUrl) async {
  final profile = await _get(profileUrl);
  final links = RegExp(
    r'https://coderlegion\.com/\d+/[a-z0-9-]+',
  ).allMatches(profile).map((m) => m.group(0)!).toSet();

  final articles = <ArticleJson>[];
  for (final link in links) {
    final page = await _get(link);
    // Skip anything that isn't by me (e.g. "read next" suggestions).
    if (_meta(page, 'og:article:author') != profileUrl.split('/').last) {
      continue;
    }
    final start = page.indexOf('qa-q-view-content qa-post-content');
    final end = page.indexOf('qa-q-view-buttons', start);
    final body = start < 0
        ? ''
        : page.substring(start, end < 0 ? page.length : end);
    final description = _meta(page, 'og:description') ?? '';
    articles.add(
      _article(
        title: _decode(_meta(page, 'og:title') ?? 'Untitled'),
        url: link,
        platform: 'Coder Legion',
        html: body,
        date:
            RegExp(
              r'datetime="(\d{4}-\d{2}-\d{2})',
            ).firstMatch(page)?.group(1) ??
            '',
        snippetOverride: _decode(description),
      ),
    );
  }
  return articles;
}

ArticleJson _article({
  required String title,
  required String url,
  required String platform,
  required String html,
  required String date,
  String? snippetOverride,
}) {
  final plain = _stripHtml(html);
  final words = plain.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
  return {
    'title': title,
    'url': url,
    'platform': platform,
    'alsoOn': <String>[],
    'snippet': _snippet(snippetOverride ?? plain),
    'readMinutes': (words / _wordsPerMinute).ceil().clamp(1, 99),
    'date': date,
  };
}

/// One card per article: later sources become "also on" entries.
List<ArticleJson> _mergeCrossPosts(List<ArticleJson> all) {
  String key(ArticleJson a) =>
      (a['title'] as String).toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  final merged = <String, ArticleJson>{};
  for (final a in all) {
    final existing = merged[key(a)];
    if (existing == null) {
      merged[key(a)] = a;
    } else if (existing['platform'] != a['platform']) {
      (existing['alsoOn'] as List<String>).add(a['platform'] as String);
    }
  }
  return merged.values.toList();
}

String? _text(XmlElement item, String name) {
  final el = item.findElements(name).firstOrNull;
  final text = el?.innerText.trim();
  return (text == null || text.isEmpty) ? null : text;
}

String? _meta(String html, String property) => RegExp(
  '<meta (?:property|name)="${RegExp.escape(property)}" content="([^"]*)"',
).firstMatch(html)?.group(1)?.trim();

String _decode(String s) => s
    .replaceAll('&amp;', '&')
    .replaceAll('&quot;', '"')
    .replaceAll('&#39;', "'")
    .replaceAll('&#039;', "'")
    .replaceAll('&lt;', '<')
    .replaceAll('&gt;', '>')
    .replaceAll('&nbsp;', ' ');

String _stripHtml(String html) => _decode(
  html
      .replaceAll(
        RegExp(r'<(script|style|pre|code)[^>]*>.*?</\1>', dotAll: true),
        ' ',
      )
      .replaceAll(RegExp(r'<[^>]+>'), ' '),
).replaceAll(RegExp(r'\s+'), ' ').trim();

String _snippet(String plain) {
  final text = plain.replaceAll(RegExp(r'\.{3}$|…$'), '').trim();
  if (text.length <= _snippetLength) return text;
  final cut = text.substring(0, _snippetLength);
  final lastSpace = cut.lastIndexOf(' ');
  return '${cut.substring(0, lastSpace > 0 ? lastSpace : cut.length)}…';
}

/// RSS dates look like "Tue, 14 Oct 2026 09:00:00 GMT".
String _rssDate(String? rss) {
  if (rss == null) return '';
  try {
    return HttpDate.parse(rss).toIso8601String().substring(0, 10);
  } catch (_) {
    final m = RegExp(r'(\d{1,2}) (\w{3}) (\d{4})').firstMatch(rss);
    if (m == null) return '';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final month = months.indexOf(m.group(2)!) + 1;
    return '${m.group(3)}-${month.toString().padLeft(2, '0')}-${m.group(1)!.padLeft(2, '0')}';
  }
}
