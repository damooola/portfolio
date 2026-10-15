import 'dart:convert';

import 'package:http/http.dart' as http;

/// My current Chess.com form, read live from their public API (no key; it
/// allows browser requests). One fetch per page load.
class ChessSnapshot {
  final String timeClass;
  final int rating;

  /// 'won', 'lost' or 'drew', from my most recent game.
  final String? lastResult;

  const ChessSnapshot({
    required this.timeClass,
    required this.rating,
    this.lastResult,
  });

  String get summary {
    final mode = '${timeClass[0].toUpperCase()}${timeClass.substring(1)}';
    final last = lastResult == null ? '' : ' · $lastResult last game';
    return '$mode $rating$last';
  }
}

class Chess {
  Chess._();

  static Future<ChessSnapshot?>? _cached;

  static Future<ChessSnapshot?> load(String username) =>
      _cached ??= _fetch(username);

  static Future<ChessSnapshot?> _fetch(String username) async {
    try {
      final base = 'https://api.chess.com/pub/player/${username.toLowerCase()}';
      final stats = await _json('$base/stats');

      int? ratingFor(String mode) =>
          ((stats['chess_$mode'] as Map?)?['last'] as Map?)?['rating'] as int?;

      // "Now playing": the mode of my most recent game, with its result.
      try {
        final archives =
            (await _json('$base/games/archives'))['archives'] as List;
        if (archives.isNotEmpty) {
          final games = (await _json(archives.last as String))['games'] as List;
          if (games.isNotEmpty) {
            final last = games.last as Map<String, dynamic>;
            final mode = last['time_class'] as String;
            final rating = ratingFor(mode);
            if (rating != null) {
              return ChessSnapshot(
                timeClass: mode,
                rating: rating,
                lastResult: _resultFor(last, username),
              );
            }
          }
        }
      } catch (_) {
        // Fall back to the overall stats below.
      }

      // No recent games: show the mode I've played most.
      String? best;
      var bestGames = -1;
      for (final mode in const ['rapid', 'blitz', 'bullet', 'daily']) {
        final record =
            (stats['chess_$mode'] as Map?)?['record'] as Map<String, dynamic>?;
        if (record == null) continue;
        final games =
            (record['win'] as int) +
            (record['loss'] as int) +
            (record['draw'] as int);
        if (games > bestGames) {
          best = mode;
          bestGames = games;
        }
      }
      if (best == null) return null;
      return ChessSnapshot(timeClass: best, rating: ratingFor(best)!);
    } catch (_) {
      return null;
    }
  }

  static Future<Map<String, dynamic>> _json(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw StateError('HTTP ${response.statusCode}');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// Chess.com results: 'win', or how the game ended for that side
  /// ('checkmated', 'resigned', 'timeout'…), or a draw type.
  static String _resultFor(Map<String, dynamic> game, String username) {
    final white = game['white'] as Map<String, dynamic>;
    final black = game['black'] as Map<String, dynamic>;
    final me =
        (white['username'] as String).toLowerCase() == username.toLowerCase()
        ? white
        : black;
    final result = me['result'] as String;
    if (result == 'win') return 'won';
    const draws = {
      'agreed',
      'repetition',
      'stalemate',
      'insufficient',
      '50move',
      'timevsinsufficient',
    };
    return draws.contains(result) ? 'drew' : 'lost';
  }
}
