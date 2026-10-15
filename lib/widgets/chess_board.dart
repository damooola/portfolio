import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_theme.dart';

/// Draws a chess position from FEN, with the classic "cburnett" vector
/// pieces (assets/chess/, CC BY-SA 3.0, see CREDITS.md). Vector pieces sit
/// exactly in the middle of each square, unlike font glyphs.
class ChessBoard extends StatelessWidget {
  final String fen;
  final double size;

  /// Draw from Black's side (my side when I played Black).
  final bool flipped;

  const ChessBoard({
    super.key,
    required this.fen,
    required this.size,
    this.flipped = false,
  });

  static const _light = Color(0xFFB9C6EA);
  static const _dark = Color(0xFF3A57A8);

  /// FEN letter to asset: uppercase is white, lowercase is black.
  static String _asset(String piece) {
    final colour = piece == piece.toUpperCase() ? 'w' : 'b';
    return 'assets/chess/$colour${piece.toUpperCase()}.svg';
  }

  /// Board rows from FEN, rank 8 first; each row has 8 entries, null = empty.
  static List<List<String?>> parse(String fen) {
    final rows = fen.split(' ').first.split('/');
    return [
      for (final row in rows)
        [
          for (final ch in row.split(''))
            ...(int.tryParse(ch) != null
                ? List<String?>.filled(int.parse(ch), null)
                : [ch]),
        ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    final board = parse(fen);
    final square = size / 8;
    const files = 'abcdefgh';

    Widget cell(int r, int c) {
      // Map display position to board position.
      final br = flipped ? 7 - r : r;
      final bc = flipped ? 7 - c : c;
      final piece = (br < board.length && bc < board[br].length)
          ? board[br][bc]
          : null;
      final light = (br + bc).isEven;
      final labelColor = light ? _dark : _light;

      return Container(
        width: square,
        height: square,
        color: light ? _light : _dark,
        child: Stack(
          children: [
            if (c == 0)
              Positioned(
                left: 2,
                top: 1,
                child: Text(
                  '${8 - br}',
                  style: AppText.mono.copyWith(
                    fontSize: square * 0.2,
                    color: labelColor,
                  ),
                ),
              ),
            if (r == 7)
              Positioned(
                right: 2,
                bottom: 0,
                child: Text(
                  files[bc],
                  style: AppText.mono.copyWith(
                    fontSize: square * 0.2,
                    color: labelColor,
                  ),
                ),
              ),
            if (piece != null)
              Center(
                child: SvgPicture.asset(
                  _asset(piece),
                  width: square * 0.88,
                  height: square * 0.88,
                ),
              ),
          ],
        ),
      );
    }

    return Semantics(
      label: 'Chess board showing the final position',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: size,
          height: size,
          child: Column(
            children: [
              for (var r = 0; r < 8; r++)
                Row(children: [for (var c = 0; c < 8; c++) cell(r, c)]),
            ],
          ),
        ),
      ),
    );
  }
}
