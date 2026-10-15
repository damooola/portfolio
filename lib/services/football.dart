import 'dart:convert';

import 'package:http/http.dart' as http;

/// Chelsea's last result and next fixture, live from TheSportsDB. Their
/// free public key ("3") is meant for exactly this kind of use and allows
/// browser requests, so there's no secret to hide.
class Fixture {
  final String home;
  final String away;
  final int? homeScore;
  final int? awayScore;
  final String competition;
  final String venue;
  final DateTime kickoff;

  const Fixture({
    required this.home,
    required this.away,
    this.homeScore,
    this.awayScore,
    required this.competition,
    required this.venue,
    required this.kickoff,
  });

  factory Fixture.fromJson(Map<String, dynamic> e) => Fixture(
    home: e['strHomeTeam'] as String,
    away: e['strAwayTeam'] as String,
    homeScore: int.tryParse('${e['intHomeScore']}'),
    awayScore: int.tryParse('${e['intAwayScore']}'),
    competition: (e['strLeague'] as String? ?? '').replaceFirst('English ', ''),
    venue: e['strVenue'] as String? ?? '',
    // Timestamps are UTC without a zone marker.
    kickoff: DateTime.parse(
      '${e['strTimestamp'] ?? '${e['dateEvent']}T00:00:00'}Z',
    ),
  );

  bool get played => homeScore != null && awayScore != null;

  /// 'W', 'D' or 'L' from [team]'s point of view.
  String outcomeFor(String team) {
    final mine = home == team ? homeScore! : awayScore!;
    final theirs = home == team ? awayScore! : homeScore!;
    return mine > theirs ? 'W' : (mine == theirs ? 'D' : 'L');
  }

  String opponentOf(String team) => home == team ? away : home;

  /// e.g. "W 5–1 vs Bournemouth" or "L 0–2 at Arsenal".
  String shortFor(String team) {
    final mine = home == team ? homeScore : awayScore;
    final theirs = home == team ? awayScore : homeScore;
    final where = home == team ? 'vs' : 'at';
    return '${outcomeFor(team)} $mine–$theirs $where ${opponentOf(team)}';
  }
}

class ChelseaForm {
  final Fixture? last;
  final Fixture? next;

  const ChelseaForm({this.last, this.next});
}

class Football {
  Football._();

  static const team = 'Chelsea';
  static const _base = 'https://www.thesportsdb.com/api/v1/json/3';

  static Future<ChelseaForm?>? _cached;

  static Future<ChelseaForm?> load(String teamId) => _cached ??= _fetch(teamId);

  static Future<ChelseaForm?> _fetch(String teamId) async {
    Future<Fixture?> first(String endpoint, String key) async {
      try {
        final response = await http.get(
          Uri.parse('$_base/$endpoint.php?id=$teamId'),
        );
        if (response.statusCode != 200) return null;
        final list =
            (jsonDecode(response.body) as Map<String, dynamic>)[key] as List?;
        if (list == null || list.isEmpty) return null;
        return Fixture.fromJson(list.first as Map<String, dynamic>);
      } catch (_) {
        return null;
      }
    }

    final results = await Future.wait([
      first('eventslast', 'results'),
      first('eventsnext', 'events'),
    ]);
    if (results.every((m) => m == null)) return null;
    return ChelseaForm(last: results[0], next: results[1]);
  }
}
