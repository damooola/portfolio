import 'dart:convert';

import 'package:http/http.dart' as http;

/// My current Chess.com form, read live from their public API (no key; it
/// allows browser requests). One fetch per page load.
class ChessSnapshot {
  final String timeClass;
  final int rating;

  /// 'won', 'lost' or 'drew', from my most recent game.
  final String? lastResult;

  /// My most recent win, for the board panel.
  final ChessWin? lastWin;

  const ChessSnapshot({
    required this.timeClass,
    required this.rating,
    this.lastResult,
    this.lastWin,
  });

  String get summary {
    final mode = '${timeClass[0].toUpperCase()}${timeClass.substring(1)}';
    final last = lastResult == null ? '' : ' · $lastResult last game';
    return '$mode $rating$last';
  }
}

/// A won game: enough to draw the final position and say how it ended.
class ChessWin {
  /// Final position, as FEN.
  final String fen;
  final bool playedWhite;
  final String opponent;
  final int opponentRating;

  /// How the opponent's side ended: 'checkmated', 'resigned', 'timeout'…
  final String opponentResult;
  final String timeClass;
  final DateTime endedAt;
  final String url;

  const ChessWin({
    required this.fen,
    required this.playedWhite,
    required this.opponent,
    required this.opponentRating,
    required this.opponentResult,
    required this.timeClass,
    required this.endedAt,
    required this.url,
  });

  String get wonBy => switch (opponentResult) {
    'checkmated' => 'checkmate',
    'resigned' => 'resignation',
    'timeout' => 'time',
    'abandoned' => 'abandonment',
    _ => opponentResult,
  };
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

      // "Now playing": the mode of my most recent game, with its result,
      // plus my latest win (looking back up to two months for one).
      try {
        final archives =
            (await _json('$base/games/archives'))['archives'] as List;
        final recent = <Map<String, dynamic>>[];
        for (final url in archives.reversed.take(2)) {
          final games = (await _json(url as String))['games'] as List;
          recent.insertAll(0, games.cast<Map<String, dynamic>>());
          if (recent.any((g) => _resultFor(g, username) == 'won')) break;
        }
        if (recent.isNotEmpty) {
          final last = recent.last;
          final mode = last['time_class'] as String;
          final rating = ratingFor(mode);
          final win = recent.lastWhere(
            (g) => _resultFor(g, username) == 'won',
            orElse: () => const {},
          );
          if (rating != null) {
            return ChessSnapshot(
              timeClass: mode,
              rating: rating,
              lastResult: _resultFor(last, username),
              lastWin: win.isEmpty ? null : _winFrom(win, username),
            );
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

  static ChessWin _winFrom(Map<String, dynamic> game, String username) {
    final white = game['white'] as Map<String, dynamic>;
    final playedWhite =
        (white['username'] as String).toLowerCase() == username.toLowerCase();
    final them = (playedWhite ? game['black'] : white) as Map<String, dynamic>;
    return ChessWin(
      fen: game['fen'] as String,
      playedWhite: playedWhite,
      opponent: them['username'] as String,
      opponentRating: them['rating'] as int,
      opponentResult: them['result'] as String,
      timeClass: game['time_class'] as String,
      endedAt: DateTime.fromMillisecondsSinceEpoch(
        (game['end_time'] as int) * 1000,
      ),
      url: game['url'] as String,
    );
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
