import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/services/chess.dart';
import 'package:portfolio/widgets/chess_board.dart';

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

  test('FEN parses into an 8x8 board with pieces in place', () {
    final board = ChessBoard.parse(
      '4Q3/1k2r1Rp/2n5/1p2B3/1n6/8/6PP/7K w - - 11 39',
    );
    expect(board.length, 8);
    expect(board.every((row) => row.length == 8), isTrue);
    expect(board[0][4], 'Q'); // e8: white queen
    expect(board[1][1], 'k'); // b7: black king
    expect(board[7][7], 'K'); // h1: white king
    expect(board[5].every((sq) => sq == null), isTrue); // rank 3 empty
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
