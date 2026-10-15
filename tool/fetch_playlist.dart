// Saves my Spotify playlist (tracks + 30-second previews) to
// assets/playlist.json, so the site can show it in its own player instead
// of Spotify's iframe.
//
// The playlist link lives in lib/data/portfolio_data.dart
// (NowPlayingData.spotifyPlaylistUrl). Re-run after changing the playlist:
//
//   dart run tool/fetch_playlist.dart
//
// No Spotify API key needed: this reads the data Spotify's public embed
// page already ships.

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

const _outPath = 'assets/playlist.json';
const _dataFile = 'lib/data/portfolio_data.dart';

Future<void> main() async {
  final source = await File(_dataFile).readAsString();
  final link = RegExp(
    r"spotifyPlaylistUrl\s*=\s*'([^']+)'",
  ).firstMatch(source)?.group(1);
  final id = link == null
      ? null
      : RegExp(r'playlist/([A-Za-z0-9]+)').firstMatch(link)?.group(1);
  if (id == null) {
    stderr.writeln('No playlist link found in $_dataFile.');
    exitCode = 1;
    return;
  }

  final response = await http.get(
    Uri.parse('https://open.spotify.com/embed/playlist/$id'),
    headers: {'User-Agent': 'Mozilla/5.0 (portfolio playlist fetcher)'},
  );
  if (response.statusCode != 200) {
    stderr.writeln(
      'Spotify returned HTTP ${response.statusCode}; leaving $_outPath unchanged.',
    );
    exitCode = 1;
    return;
  }

  final json = RegExp(
    r'<script id="__NEXT_DATA__" type="application/json">(.*?)</script>',
    dotAll: true,
  ).firstMatch(utf8.decode(response.bodyBytes))?.group(1);
  if (json == null) {
    stderr.writeln(
      'Spotify changed their embed page; leaving $_outPath unchanged.',
    );
    exitCode = 1;
    return;
  }

  final entity =
      jsonDecode(json)['props']['pageProps']['state']['data']['entity']
          as Map<String, dynamic>;
  final sources =
      (entity['coverArt']?['sources'] as List? ?? const [])
          .cast<Map<String, dynamic>>()
        ..sort(
          (a, b) =>
              ((b['width'] as int?) ?? 0).compareTo((a['width'] as int?) ?? 0),
        );

  final playlist = {
    'name': entity['name'],
    'owner': entity['subtitle'],
    'url': 'https://open.spotify.com/playlist/$id',
    'cover': sources.isEmpty ? null : sources.first['url'],
    'tracks': [
      for (final t
          in (entity['trackList'] as List).cast<Map<String, dynamic>>())
        {
          'title': t['title'],
          'artist': (t['subtitle'] as String).replaceAll(' ', ' '),
          'durationMs': t['duration'],
          'preview': t['audioPreview']?['url'],
          'url':
              'https://open.spotify.com/track/${(t['uri'] as String).split(':').last}',
        },
    ],
  };

  await File(
    _outPath,
  ).writeAsString('${const JsonEncoder.withIndent('  ').convert(playlist)}\n');
  stdout.writeln(
    'Wrote "${playlist['name']}" (${(playlist['tracks'] as List).length} tracks) to $_outPath',
  );
}
