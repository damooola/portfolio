import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/services/chess.dart';

void main() {
  test('summary reads like the tile text', () {
    expect(
      const ChessSnapshot(
        timeClass: 'rapid',
        rating: 965,
        lastResult: 'won',
      ).summary,
      'Rapid 965 · won last game',
    );
    expect(
      const ChessSnapshot(timeClass: 'blitz', rating: 621).summary,
      'Blitz 621',
    );
  });

  test(
    'live fetch against Chess.com',
    () async {
      final snap = await Chess.load('ay0dam0la');
      // ignore: avoid_print
      print('live: ${snap?.summary}');
    },
    tags: 'network',
    skip: 'network: run with --run-skipped to hit Chess.com',
  );
}
