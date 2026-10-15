import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/portfolio_data.dart';
import '../services/chess.dart';
import '../services/sfx.dart';
import '../theme/app_theme.dart';
import 'buttons.dart';
import 'chess_board.dart';
import 'responsive_section.dart';
import 'spotify_embed.dart';

class HeroSection extends StatelessWidget {
  final VoidCallback onViewWork;
  final VoidCallback onContact;

  const HeroSection({
    super.key,
    required this.onViewWork,
    required this.onContact,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isMobile = AppBreakpoints.isMobile(size.width);
    final nameSize = isMobile
        ? 64.0
        : (AppBreakpoints.isDesktop(size.width) ? 148.0 : 104.0);
    final reduced = AppMotion.reduced(context);

    // Each line of the name fits its own row, so long names never overflow.
    Widget nameLine(String word, int offset) => FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < word.length; i++)
            _DropLetter(
              letter: word[i],
              index: offset + i,
              size: nameSize,
              reduced: reduced,
            ),
        ],
      ),
    );

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: isMobile ? 0 : size.height * 0.88),
      child: ResponsiveSection(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const _StatusPill(),
            const SizedBox(height: AppSpacing.lg),
            nameLine(ProfileData.firstName, 0),
            nameLine(ProfileData.lastName, ProfileData.firstName.length),
            const SizedBox(height: AppSpacing.md),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${ProfileData.role} ',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    TextSpan(
                      text: ProfileData.tagline,
                      style: const TextStyle(color: AppColors.textMuted),
                    ),
                  ],
                ),
                style: AppText.body.copyWith(
                  fontSize: isMobile ? 18 : 21,
                  height: 1.5,
                ),
              ),
            ).animate().fadeIn(delay: 600.ms, duration: 500.ms),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                PrimaryButton(
                  label: 'See the work',
                  icon: Icons.arrow_downward,
                  onTap: onViewWork,
                ),
                SecondaryButton(label: 'Say hello', onTap: onContact),
              ],
            ).animate().fadeIn(delay: 750.ms, duration: 500.ms),
            const SizedBox(height: AppSpacing.xl),
            const NowPlayingStrip().animate().fadeIn(
              delay: 900.ms,
              duration: 500.ms,
            ),
          ],
        ),
      ),
    );
  }
}

/// One letter of the hero name. Drops in on load with a spring, and hops
/// when the cursor passes over it.
class _DropLetter extends StatefulWidget {
  final String letter;
  final int index;
  final double size;
  final bool reduced;

  const _DropLetter({
    required this.letter,
    required this.index,
    required this.size,
    required this.reduced,
  });

  @override
  State<_DropLetter> createState() => _DropLetterState();
}

class _DropLetterState extends State<_DropLetter> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final letter = Text(
      widget.letter,
      style: AppText.display.copyWith(
        fontSize: widget.size,
        height: 0.92,
        letterSpacing: -widget.size * 0.02,
        color: _hover ? AppColors.blue : AppColors.text,
      ),
    );

    final hopping = MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedSlide(
        offset: Offset(0, _hover && !widget.reduced ? -0.08 : 0),
        duration: AppMotion.hover,
        curve: AppMotion.spring,
        child: letter,
      ),
    );

    final delay = AppMotion.stagger * widget.index;
    if (widget.reduced) {
      return hopping.animate().fadeIn(delay: delay, duration: 300.ms);
    }
    return hopping
        .animate()
        .fadeIn(delay: delay, duration: 200.ms)
        .slideY(
          begin: -0.6,
          end: 0,
          delay: delay,
          duration: AppMotion.big,
          curve: AppMotion.spring,
        );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const PulsingDot(),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              ProfileData.status,
              style: AppText.mono.copyWith(fontSize: 13, color: AppColors.text),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}

/// Green "online" dot with a soft ring that breathes.
class PulsingDot extends StatelessWidget {
  final Color color;

  const PulsingDot({super.key, this.color = AppColors.online});

  @override
  Widget build(BuildContext context) {
    final dot = Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
    if (AppMotion.reduced(context)) return dot;

    return SizedBox(
      width: 8,
      height: 8,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
              )
              .animate(onPlay: (c) => c.repeat())
              .scaleXY(
                begin: 1,
                end: 2.6,
                duration: 1600.ms,
                curve: Curves.easeOut,
              )
              .fadeOut(duration: 1600.ms),
          dot,
        ],
      ),
    );
  }
}

/// "Now playing" tiles laid out side by side: game, song, Chelsea,
/// learning. The song tile has a play button that opens the Spotify
/// playlist player under the row.
class NowPlayingStrip extends StatefulWidget {
  const NowPlayingStrip({super.key});

  @override
  State<NowPlayingStrip> createState() => _NowPlayingStripState();
}

enum _Panel { none, player, chess }

class _NowPlayingStripState extends State<NowPlayingStrip> {
  /// One panel at a time opens under the tiles: the Spotify player or my
  /// last chess win.
  _Panel _panel = _Panel.none;

  static final _hasPlaylist =
      SpotifyEmbed.embedUrl(NowPlayingData.spotifyPlaylistUrl) != null;

  void _toggle(_Panel panel) {
    Sfx.play(Sound.click);
    setState(() => _panel = _panel == panel ? _Panel.none : panel);
  }

  @override
  Widget build(BuildContext context) {
    const items = NowPlayingData.items;
    const gap = 10.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Four across when there's room, otherwise a 2x2 grid.
        final columns = constraints.maxWidth >= 860 ? 4 : 2;
        final tileWidth =
            (constraints.maxWidth - gap * (columns - 1)) / columns;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (var i = 0; i < items.length; i++)
                  SizedBox(
                        width: tileWidth,
                        child: _tile(items[i], compact: columns == 2),
                      )
                      .animate()
                      .fadeIn(delay: (60 * i).ms, duration: 300.ms)
                      .slideY(
                        begin: 0.3,
                        end: 0,
                        delay: (60 * i).ms,
                        duration: AppMotion.big,
                        curve: AppMotion.settle,
                      ),
              ],
            ),
            AnimatedSize(
              duration: AppMotion.big,
              curve: AppMotion.settle,
              alignment: Alignment.topLeft,
              child: switch (_panel) {
                _Panel.player => ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: const Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: SpotifyEmbed(
                      shareUrl: NowPlayingData.spotifyPlaylistUrl,
                    ),
                  ),
                ),
                _Panel.chess => const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: _LastWinPanel(),
                ),
                _Panel.none => const SizedBox(width: 0),
              },
            ),
          ],
        );
      },
    );
  }

  Widget _tile((String, String, IconData) item, {required bool compact}) {
    final isChess = item.$1 == 'CHESS';
    final isSong = item.$3 == Icons.music_note_outlined && _hasPlaylist;
    return _NowTile(
      item: item,
      isChess: isChess,
      compact: compact,
      playing: _panel == (isChess ? _Panel.chess : _Panel.player),
      onPlay: isChess
          ? () => _toggle(_Panel.chess)
          : isSong
          ? () => _toggle(_Panel.player)
          : null,
    );
  }
}

/// My most recent Chess.com win: the final position, who it was against
/// and how it ended, with a link to the full game.
class _LastWinPanel extends StatelessWidget {
  const _LastWinPanel();

  static String _date(DateTime d) {
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
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    const profile =
        'https://www.chess.com/member/${NowPlayingData.chessUsername}';
    final isMobile = AppBreakpoints.isMobile(MediaQuery.sizeOf(context).width);

    return FutureBuilder(
      future: Chess.load(NowPlayingData.chessUsername),
      builder: (context, snap) {
        final win = snap.data?.lastWin;
        final Widget body;
        if (snap.connectionState != ConnectionState.done) {
          body = const SizedBox(
            height: 60,
            child: Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.blue,
                ),
              ),
            ),
          );
        } else if (win == null) {
          body = Row(
            children: [
              Expanded(
                child: Text(
                  'No recent win to show. The board is a tough place.',
                  style: AppText.bodyMuted.copyWith(fontSize: 14),
                ),
              ),
              const _ChessLink(label: 'My games', url: profile),
            ],
          );
        } else {
          final mode =
              '${win.timeClass[0].toUpperCase()}${win.timeClass.substring(1)}';
          final side = win.playedWhite ? 'White' : 'Black';
          final details = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'LAST WIN',
                style: AppText.monoLabel.copyWith(
                  fontSize: 10,
                  color: AppColors.online,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'vs ${win.opponent}',
                style: AppText.heading.copyWith(fontSize: 20),
              ),
              Text(
                'rated ${win.opponentRating}',
                style: AppText.mono.copyWith(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Won by ${win.wonBy}, playing $side.',
                style: AppText.body.copyWith(fontSize: 14, height: 1.4),
              ),
              Text(
                '$mode · ${_date(win.endedAt)}',
                style: AppText.bodyMuted.copyWith(fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _ChessLink(label: 'View game', url: win.url, primary: true),
                  const _ChessLink(label: 'Profile', url: profile),
                ],
              ),
            ],
          );
          final board = ChessBoard(
            fen: win.fen,
            size: isMobile ? 220 : 200,
            flipped: !win.playedWhite,
          );
          body = isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [board, const SizedBox(height: 14), details],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    board,
                    const SizedBox(width: 20),
                    Flexible(child: details),
                  ],
                );
        }

        return ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Container(
            width: isMobile ? double.infinity : null,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.line),
            ),
            child: body,
          ),
        ).animate().fadeIn(duration: 200.ms);
      },
    );
  }
}

class _ChessLink extends StatelessWidget {
  final String label;
  final String url;
  final bool primary;

  const _ChessLink({
    required this.label,
    required this.url,
    this.primary = false,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Sfx.play(Sound.click);
          launchUrl(Uri.parse(url), webOnlyWindowName: '_blank');
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: primary ? AppColors.blue : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: primary ? AppColors.blue : AppColors.line,
            ),
          ),
          child: Text(
            '$label ↗',
            style: AppText.body.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _NowTile extends StatefulWidget {
  final (String, String, IconData) item;
  final bool compact;
  final bool playing;

  /// The chess tile: a knight glyph, a live rating, and a link to my
  /// Chess.com profile.
  final bool isChess;

  /// Set on the song tile when a playlist is configured.
  final VoidCallback? onPlay;

  const _NowTile({
    required this.item,
    required this.compact,
    required this.playing,
    this.isChess = false,
    this.onPlay,
  });

  @override
  State<_NowTile> createState() => _NowTileState();
}

class _NowTileState extends State<_NowTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final (label, value, icon) = widget.item;
    final onPlay = widget.onPlay;

    final tile = AnimatedContainer(
      duration: AppMotion.hover,
      padding: EdgeInsets.all(widget.compact ? 10 : 12),
      decoration: BoxDecoration(
        color: _hover ? AppColors.raised : AppColors.surface,
        border: Border.all(
          color: _hover
              ? AppColors.blue.withValues(alpha: 0.5)
              : AppColors.line,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: widget.compact ? 30 : 36,
            height: widget.compact ? 30 : 36,
            decoration: BoxDecoration(
              color: AppColors.blueDeep,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: widget.isChess
                ? Text(
                    '♞',
                    style: TextStyle(
                      fontSize: widget.compact ? 18 : 21,
                      height: 1,
                      color: AppColors.text,
                    ),
                  )
                : Icon(
                    icon,
                    size: widget.compact ? 16 : 18,
                    color: AppColors.text,
                  ),
          ),
          SizedBox(width: widget.compact ? 8 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.compact ? label : 'NOW · $label',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.monoLabel.copyWith(
                    fontSize: widget.compact ? 9 : 10,
                  ),
                ),
                const SizedBox(height: 2),
                if (widget.isChess)
                  FutureBuilder(
                    future: Chess.load(NowPlayingData.chessUsername),
                    builder: (context, snap) =>
                        _value(snap.data?.summary ?? value),
                  )
                else
                  _value(value),
              ],
            ),
          ),
          if (onPlay != null) ...[
            const SizedBox(width: 8),
            Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                color: AppColors.blue,
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.playing
                    ? Icons.close_rounded
                    : widget.isChess
                    ? Icons.expand_more_rounded
                    : Icons.play_arrow_rounded,
                size: 18,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );

    // The song and chess tiles open panels; the rest just react to hover.
    if (onPlay == null) {
      return MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: tile,
      );
    }
    return Tooltip(
      message: widget.isChess
          ? (widget.playing ? 'Hide board' : 'See my last win')
          : (widget.playing ? 'Hide player' : 'Play on Spotify'),
      child: Semantics(
        button: true,
        label: widget.isChess
            ? (widget.playing
                  ? 'Hide last chess win'
                  : 'Show my last chess win')
            : (widget.playing
                  ? 'Hide Spotify player'
                  : 'Play my playlist on Spotify'),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _hover = true),
          onExit: (_) => setState(() => _hover = false),
          child: GestureDetector(onTap: onPlay, child: tile),
        ),
      ),
    );
  }

  Widget _value(String text) => AnimatedSwitcher(
    duration: AppMotion.hover,
    child: Text(
      text,
      key: ValueKey(text),
      maxLines: widget.compact ? 2 : 1,
      overflow: TextOverflow.ellipsis,
      style: AppText.body.copyWith(
        fontSize: widget.compact ? 12.5 : 14,
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
    ),
  );
}
