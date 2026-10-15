// Pulls my articles from each platform's RSS feed and writes them to
// assets/articles.json for the Writing section.
//
// Medium and Hashnode block cross-origin requests from a browser, so the
// site can't fetch these live. Run this whenever you publish something:
//
//   dart run tool/fetch_articles.dart
//
// then rebuild the site. Any feed that fails is skipped with a warning,
// and the existing file is left alone if every feed fails.

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

// TODO: fill in your real feed URLs. Leave a platform out if you don't use it.
const feeds = <String, String>{
  // 'Hashnode': 'https://YOUR-BLOG.hashnode.dev/rss.xml',
  // 'Medium': 'https://medium.com/feed/@YOUR-HANDLE',
  // 'Coder Legion': 'https://coderlegion.com/feed/YOUR-HANDLE',
};

const _outPath = 'assets/articles.json';
const _wordsPerMinute = 220;
const _snippetLength = 180;

Future<void> main() async {
  if (feeds.isEmpty) {
    stderr.writeln(
      'No feeds configured. Add your feed URLs at the top of tool/fetch_articles.dart.',
    );
    exitCode = 1;
    return;
  }

  final articles = <Map<String, Object>>[];
  var failures = 0;

  for (final MapEntry(key: platform, value: url) in feeds.entries) {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        throw HttpException('HTTP ${response.statusCode}');
      }
      final items = XmlDocument.parse(response.body).findAllElements('item');
      for (final item in items) {
        final html =
            _text(item, 'content:encoded') ?? _text(item, 'description') ?? '';
        final plain = _stripHtml(html);
        final words = plain
            .split(RegExp(r'\s+'))
            .where((w) => w.isNotEmpty)
            .length;
        articles.add({
          'title': _text(item, 'title') ?? 'Untitled',
          'url': _text(item, 'link') ?? url,
          'platform': platform,
          'snippet': _snippet(plain),
          'readMinutes': (words / _wordsPerMinute).ceil().clamp(1, 99),
          'date': _isoDate(_text(item, 'pubDate')),
        });
      }
      stdout.writeln('$platform: ${items.length} articles');
    } catch (e) {
      failures++;
      stderr.writeln('$platform: skipped ($e)');
    }
  }

  if (failures == feeds.length) {
    stderr.writeln('Every feed failed; leaving $_outPath unchanged.');
    exitCode = 1;
    return;
  }

  articles.sort((a, b) => (b['date'] as String).compareTo(a['date'] as String));
  await File(
    _outPath,
  ).writeAsString('${const JsonEncoder.withIndent('  ').convert(articles)}\n');
  stdout.writeln('Wrote ${articles.length} articles to $_outPath');
}

String? _text(XmlElement item, String name) {
  final el = item.findElements(name).firstOrNull;
  final text = el?.innerText.trim();
  return (text == null || text.isEmpty) ? null : text;
}

String _stripHtml(String html) => html
    .replaceAll(
      RegExp(r'<(script|style|pre|code)[^>]*>.*?</\1>', dotAll: true),
      ' ',
    )
    .replaceAll(RegExp(r'<[^>]+>'), ' ')
    .replaceAll('&nbsp;', ' ')
    .replaceAll('&amp;', '&')
    .replaceAll('&quot;', '"')
    .replaceAll('&#39;', "'")
    .replaceAll('&lt;', '<')
    .replaceAll('&gt;', '>')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();

String _snippet(String plain) {
  if (plain.length <= _snippetLength) return plain;
  final cut = plain.substring(0, _snippetLength);
  final lastSpace = cut.lastIndexOf(' ');
  return '${cut.substring(0, lastSpace > 0 ? lastSpace : cut.length)}…';
}

/// RSS dates look like "Tue, 14 Oct 2026 09:00:00 GMT".
String _isoDate(String? rss) {
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
