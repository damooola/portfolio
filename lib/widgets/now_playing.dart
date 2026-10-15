import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/portfolio_data.dart';
import '../services/chess.dart';
import '../services/football.dart';
import '../services/sfx.dart';
import '../theme/app_theme.dart';
import 'chess_board.dart';

enum NowPanel { chess, music, chelsea, learning }

/// Four "now playing" tiles: chess, music, Chelsea, learning. Hovering a
/// tile previews its panel underneath; clicking pins it open (on touch
/// screens, tap toggles). Music keeps playing while you look around.
class NowPlayingStrip extends StatefulWidget {
  const NowPlayingStrip({super.key});

  @override
  State<NowPlayingStrip> createState() => _NowPlayingStripState();
}

class _NowPlayingStripState extends State<NowPlayingStrip> {
  final _music = PlaylistController();
  NowPanel? _hovered;
  NowPanel? _pinned;

  NowPanel? get _shown => _hovered ?? _pinned;

  @override
  void initState() {
    super.initState();
    _music.load();
  }

  @override
  void dispose() {
    _music.dispose();
    super.dispose();
  }

  void _tap(NowPanel panel) {
    Sfx.play(Sound.click);
    setState(() {
      if (_pinned == panel) {
        _pinned = null;
        _hovered = null;
      } else {
        _pinned = panel;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const gap = 10.0;

    return MouseRegion(
      // Leaving the tiles and panel ends the preview; a pinned panel stays.
      onExit: (_) => setState(() => _hovered = null),
      child: LayoutBuilder(
        builder: (context, constraints) {
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
                  for (final (i, panel) in NowPanel.values.indexed)
                    SizedBox(
                          width: tileWidth,
                          child: _NowTile(
                            panel: panel,
                            music: _music,
                            compact: columns == 2,
                            open: _shown == panel,
                            pinned: _pinned == panel,
                            onHover: (on) => setState(
                              () => _hovered = on ? panel : _hovered,
                            ),
                            onTap: () => _tap(panel),
                          ),
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
                child: _shown == null
                    ? const SizedBox(width: double.infinity)
                    : Padding(
                        padding: const EdgeInsets.only(top: gap),
                        child: AnimatedSwitcher(
                          duration: AppMotion.hover,
                          layoutBuilder: (current, previous) => Stack(
                            alignment: Alignment.topLeft,
                            children: [...previous, ?current],
                          ),
                          child: KeyedSubtree(
                            key: ValueKey(_shown),
                            child: switch (_shown!) {
                              NowPanel.chess => const _LastWinPanel(),
                              NowPanel.music => _PlaylistPanel(music: _music),
                              NowPanel.chelsea => const _MatchPanel(),
                              NowPanel.learning => const _LearningPanel(),
                            },
                          ),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Tiles ──────────────────────────────────────────────────────────────

class _NowTile extends StatefulWidget {
  final NowPanel panel;
  final PlaylistController music;
  final bool compact;
  final bool open;
  final bool pinned;
  final ValueChanged<bool> onHover;
  final VoidCallback onTap;

  const _NowTile({
    required this.panel,
    required this.music,
    required this.compact,
    required this.open,
    required this.pinned,
    required this.onHover,
    required this.onTap,
  });

  @override
  State<_NowTile> createState() => _NowTileState();
}

class _NowTileState extends State<_NowTile> {
  bool _hover = false;

  String get _label => switch (widget.panel) {
    NowPanel.chess => 'CHESS',
    NowPanel.music => 'ON REPEAT',
    NowPanel.chelsea => 'CHELSEA',
    NowPanel.learning => 'LEARNING',
  };

  /// What a click does, shown in place of the label while hovering.
  String get _hint => switch (widget.panel) {
    NowPanel.chess => 'MY LAST WIN',
    NowPanel.music => 'PLAY THE PLAYLIST',
    NowPanel.chelsea => 'SCORE + NEXT GAME',
    NowPanel.learning => 'WHAT I\'M BUILDING',
  };

  Widget get _glyph => switch (widget.panel) {
    NowPanel.chess => const Text(
      '♞',
      style: TextStyle(fontSize: 20, height: 1, color: AppColors.text),
    ),
    NowPanel.music => ListenableBuilder(
      listenable: widget.music,
      builder: (context, _) => widget.music.playing
          ? const EqualizerBars(size: 16)
          : const Icon(
              Icons.music_note_outlined,
              size: 18,
              color: AppColors.text,
            ),
    ),
    NowPanel.chelsea => const Icon(
      Icons.sports_soccer_outlined,
      size: 18,
      color: AppColors.text,
    ),
    NowPanel.learning => const Icon(
      Icons.school_outlined,
      size: 18,
      color: AppColors.text,
    ),
  };

  Widget _value() => switch (widget.panel) {
    NowPanel.chess => FutureBuilder(
      future: Chess.load(NowPlayingData.chessUsername),
      builder: (context, snap) => _text(snap.data?.summary ?? 'On Chess.com'),
    ),
    NowPanel.music => ListenableBuilder(
      listenable: widget.music,
      builder: (context, _) {
        final m = widget.music;
        final track = m.current;
        if (m.playing && track != null) return _text(track.title);
        final count = m.playlist?.tracks.length;
        return _text(
          count == null ? 'My playlist' : 'My playlist · $count tracks',
        );
      },
    ),
    NowPanel.chelsea => FutureBuilder(
      future: Football.load(NowPlayingData.chelseaTeamId),
      builder: (context, snap) {
        final last = snap.data?.last;
        return _text(
          last != null && last.played
              ? last.shortFor(Football.team)
              : 'Chelsea FC',
        );
      },
    ),
    NowPanel.learning => _text(NowPlayingData.learning),
  };

  Widget _text(String text) => AnimatedSwitcher(
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

  @override
  Widget build(BuildContext context) {
    final open = widget.open;
    final hinting = _hover && !widget.pinned;
    final label = widget.pinned && _hover
        ? 'CLICK TO CLOSE'
        : hinting
        ? '↓ $_hint'
        : (widget.compact ? _label : 'NOW · $_label');

    final tile = AnimatedContainer(
      duration: AppMotion.hover,
      padding: EdgeInsets.all(widget.compact ? 10 : 12),
      decoration: BoxDecoration(
        color: open || _hover ? AppColors.raised : AppColors.surface,
        border: Border.all(
          color: widget.pinned
              ? AppColors.blue
              : (open || _hover
                    ? AppColors.blue.withValues(alpha: 0.5)
                    : AppColors.line),
          width: widget.pinned ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: widget.compact ? 30 : 36,
            height: widget.compact ? 30 : 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.blueDeep,
              borderRadius: BorderRadius.circular(10),
            ),
            child: _glyph,
          ),
          SizedBox(width: widget.compact ? 8 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: AppMotion.hover,
                  child: Text(
                    label,
                    key: ValueKey(label),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.monoLabel.copyWith(
                      fontSize: widget.compact ? 9 : 10,
                      color: hinting || (widget.pinned && _hover)
                          ? AppColors.blue
                          : AppColors.textMuted,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                _value(),
              ],
            ),
          ),
          const SizedBox(width: 6),
          // Always visible, so touch users can tell it opens something too.
          AnimatedRotation(
            turns: open ? 0.5 : 0,
            duration: AppMotion.big,
            curve: AppMotion.spring,
            child: Icon(
              Icons.expand_more_rounded,
              size: 20,
              color: open || _hover ? AppColors.blue : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );

    return Semantics(
      button: true,
      expanded: widget.pinned,
      label: '$_label: ${_hint.toLowerCase()}',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) {
          setState(() => _hover = true);
          widget.onHover(true);
        },
        onExit: (_) {
          setState(() => _hover = false);
          widget.onHover(false);
        },
        child: GestureDetector(onTap: widget.onTap, child: tile),
      ),
    );
  }
}

/// Three bouncing bars: "something is playing".
class EqualizerBars extends StatelessWidget {
  final double size;

  const EqualizerBars({super.key, this.size = 14});

  @override
  Widget build(BuildContext context) {
    final reduced = AppMotion.reduced(context);
    return SizedBox(
      width: size,
      height: size,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final (i, ms) in const [520, 380, 640].indexed)
            Container(
                  width: size / 4.5,
                  height: size,
                  decoration: BoxDecoration(
                    color: AppColors.online,
                    borderRadius: BorderRadius.circular(1),
                  ),
                )
                .animate(
                  onPlay: reduced ? null : (c) => c.repeat(reverse: true),
                )
                .scaleY(
                  begin: reduced ? 0.6 : 0.25,
                  end: reduced ? 0.6 : 1,
                  alignment: Alignment.bottomCenter,
                  delay: (90 * i).ms,
                  duration: ms.ms,
                  curve: Curves.easeInOut,
                ),
        ],
      ),
    );
  }
}

// ── Shared panel pieces ───────────────────────────────────────────────

class _PanelCard extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const _PanelCard({required this.child, this.maxWidth = 640});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.line),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

class _PanelLink extends StatelessWidget {
  final String label;
  final String url;
  final bool primary;

  const _PanelLink({
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

Widget _loading() => const SizedBox(
  height: 60,
  child: Center(
    child: SizedBox(
      width: 18,
      height: 18,
      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.blue),
    ),
  ),
);

const _months = [
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
const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

String _day(DateTime d) =>
    '${_days[d.weekday - 1]} ${d.day} ${_months[d.month - 1]}';
String _time(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

// ── Chess: last win ───────────────────────────────────────────────────

class _LastWinPanel extends StatelessWidget {
  const _LastWinPanel();

  @override
  Widget build(BuildContext context) {
    const profile =
        'https://www.chess.com/member/${NowPlayingData.chessUsername}';
    final isMobile = AppBreakpoints.isMobile(MediaQuery.sizeOf(context).width);

    return FutureBuilder(
      future: Chess.load(NowPlayingData.chessUsername),
      builder: (context, snap) {
        final win = snap.data?.lastWin;
        if (snap.connectionState != ConnectionState.done) {
          return _PanelCard(child: _loading());
        }
        if (win == null) {
          return const _PanelCard(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'No recent win to show. The board is a tough place.',
                  ),
                ),
                _PanelLink(label: 'My games', url: profile),
              ],
            ),
          );
        }

        final mode =
            '${win.timeClass[0].toUpperCase()}${win.timeClass.substring(1)}';
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
              'Won by ${win.wonBy}, playing ${win.playedWhite ? 'White' : 'Black'}.',
              style: AppText.body.copyWith(fontSize: 14, height: 1.4),
            ),
            Text(
              '$mode · ${_day(win.endedAt)} ${win.endedAt.year}',
              style: AppText.bodyMuted.copyWith(fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _PanelLink(label: 'View game', url: win.url, primary: true),
                const _PanelLink(label: 'Profile', url: profile),
              ],
            ),
          ],
        );
        final board = ChessBoard(
          fen: win.fen,
          size: isMobile ? 220 : 200,
          flipped: !win.playedWhite,
        );

        return _PanelCard(
          maxWidth: 560,
          child: isMobile
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
                ),
        );
      },
    );
  }
}

// ── Music: our own player for the playlist ────────────────────────────

class Track {
  final String title;
  final String artist;
  final Duration length;
  final String? preview;
  final String url;

  const Track(this.title, this.artist, this.length, this.preview, this.url);
}

class Playlist {
  final String name;
  final String owner;
  final String url;
  final String? cover;
  final List<Track> tracks;

  const Playlist(this.name, this.owner, this.url, this.cover, this.tracks);

  /// From assets/playlist.json, written by tool/fetch_playlist.dart.
  static Future<Playlist?> load() async {
    try {
      final json =
          jsonDecode(await rootBundle.loadString('assets/playlist.json'))
              as Map<String, dynamic>;
      return Playlist(
        json['name'] as String,
        json['owner'] as String? ?? '',
        json['url'] as String,
        json['cover'] as String?,
        [
          for (final t in (json['tracks'] as List).cast<Map<String, dynamic>>())
            Track(
              t['title'] as String,
              t['artist'] as String,
              Duration(milliseconds: t['durationMs'] as int? ?? 0),
              t['preview'] as String?,
              t['url'] as String,
            ),
        ],
      );
    } catch (_) {
      return null;
    }
  }
}

/// Plays 30-second Spotify previews in order. Lives above the panels so the
/// music keeps going while the visitor looks at other tiles.
class PlaylistController extends ChangeNotifier {
  Playlist? playlist;
  int index = 0;
  bool playing = false;
  Duration position = Duration.zero;
  Duration duration = const Duration(seconds: 30);

  AudioPlayer? _player;
  final _subs = <StreamSubscription<Object?>>[];
  bool _disposed = false;

  /// Async work (asset load, audio events) can finish after the hero is
  /// gone; drop those updates instead of notifying a disposed controller.
  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  Track? get current => playlist?.tracks.elementAtOrNull(index);

  Future<void> load() async {
    playlist = await Playlist.load();
    notifyListeners();
  }

  AudioPlayer _ensurePlayer() {
    final existing = _player;
    if (existing != null) return existing;
    final player = AudioPlayer();
    _subs.addAll([
      player.onPositionChanged.listen((p) {
        position = p;
        notifyListeners();
      }),
      player.onDurationChanged.listen((d) {
        if (d > Duration.zero) duration = d;
        notifyListeners();
      }),
      player.onPlayerComplete.listen((_) => next()),
    ]);
    return _player = player;
  }

  Future<void> playAt(int i) async {
    final tracks = playlist?.tracks;
    if (tracks == null || tracks.isEmpty) return;
    index = i % tracks.length;
    final url = tracks[index].preview;
    if (url == null) return next();
    position = Duration.zero;
    playing = true;
    notifyListeners();
    try {
      await _ensurePlayer().play(UrlSource(url));
    } catch (_) {
      playing = false;
      notifyListeners();
    }
  }

  Future<void> toggle() async {
    if (playing) {
      playing = false;
      notifyListeners();
      await _player?.pause();
    } else if (_player != null && position > Duration.zero) {
      playing = true;
      notifyListeners();
      await _player!.resume();
    } else {
      await playAt(index);
    }
  }

  Future<void> next() => playAt(index + 1);
  Future<void> previous() => playAt(index - 1);

  @override
  void dispose() {
    _disposed = true;
    for (final s in _subs) {
      s.cancel();
    }
    _player?.dispose();
    super.dispose();
  }
}

class _PlaylistPanel extends StatelessWidget {
  final PlaylistController music;

  const _PlaylistPanel({required this.music});

  static String _mmss(Duration d) =>
      '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobile(MediaQuery.sizeOf(context).width);

    return ListenableBuilder(
      listenable: music,
      builder: (context, _) {
        final p = music.playlist;
        if (p == null) return _PanelCard(child: _loading());
        final track = music.current;
        final progress = music.duration.inMilliseconds == 0
            ? 0.0
            : (music.position.inMilliseconds / music.duration.inMilliseconds)
                  .clamp(0.0, 1.0);

        final cover = ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 112,
            height: 112,
            child: p.cover == null
                ? const ColoredBox(color: AppColors.blueDeep)
                : Image.network(
                    p.cover!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        const ColoredBox(color: AppColors.blueDeep),
                  ),
          ),
        );

        final header = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'PLAYLIST · ${p.tracks.length} TRACKS',
              style: AppText.monoLabel.copyWith(fontSize: 10),
            ),
            const SizedBox(height: 2),
            Text(p.name, style: AppText.heading.copyWith(fontSize: 22)),
            Text(
              track == null ? p.owner : '${track.title} · ${track.artist}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.bodyMuted.copyWith(fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _RoundButton(
                  icon: Icons.skip_previous_rounded,
                  label: 'Previous track',
                  onTap: music.previous,
                ),
                const SizedBox(width: 8),
                _RoundButton(
                  icon: music.playing
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  label: music.playing ? 'Pause' : 'Play',
                  primary: true,
                  onTap: music.toggle,
                ),
                const SizedBox(width: 8),
                _RoundButton(
                  icon: Icons.skip_next_rounded,
                  label: 'Next track',
                  onTap: music.next,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 3,
                          backgroundColor: AppColors.raised,
                          color: AppColors.blue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_mmss(music.position)} / ${_mmss(music.duration)} preview',
                        style: AppText.mono.copyWith(
                          fontSize: 10,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );

        final list = ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 216),
          child: ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: p.tracks.length,
            itemBuilder: (context, i) => _TrackRow(
              index: i,
              track: p.tracks[i],
              current:
                  i == music.index &&
                  (music.playing || music.position > Duration.zero),
              playing: i == music.index && music.playing,
              onTap: () => music.playAt(i),
            ),
          ),
        );

        return _PanelCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isMobile) ...[
                cover,
                const SizedBox(height: 12),
                header,
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    cover,
                    const SizedBox(width: 16),
                    Expanded(child: header),
                  ],
                ),
              const SizedBox(height: 14),
              Container(height: 1, color: AppColors.line),
              const SizedBox(height: 6),
              list,
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '30-second previews. Full songs on Spotify.',
                      style: AppText.bodyMuted.copyWith(fontSize: 12),
                    ),
                  ),
                  _PanelLink(label: 'Open in Spotify', url: p.url),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RoundButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool primary;
  final VoidCallback onTap;

  const _RoundButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.primary = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = primary ? 40.0 : 32.0;
    return Semantics(
      button: true,
      label: label,
      child: Tooltip(
        message: label,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: primary ? AppColors.blue : AppColors.raised,
                shape: BoxShape.circle,
                boxShadow: primary
                    ? [
                        BoxShadow(
                          color: AppColors.blue.withValues(alpha: 0.4),
                          blurRadius: 14,
                        ),
                      ]
                    : null,
              ),
              child: Icon(icon, size: primary ? 24 : 18, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

class _TrackRow extends StatefulWidget {
  final int index;
  final Track track;
  final bool current;
  final bool playing;
  final VoidCallback onTap;

  const _TrackRow({
    required this.index,
    required this.track,
    required this.current,
    required this.playing,
    required this.onTap,
  });

  @override
  State<_TrackRow> createState() => _TrackRowState();
}

class _TrackRowState extends State<_TrackRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.track;
    final length =
        '${t.length.inMinutes}:${(t.length.inSeconds % 60).toString().padLeft(2, '0')}';

    return Semantics(
      button: true,
      label: 'Play ${t.title} by ${t.artist}',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: AppMotion.hover,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: widget.current
                  ? AppColors.blue.withValues(alpha: 0.12)
                  : (_hover ? AppColors.raised : Colors.transparent),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 22,
                  child: widget.playing
                      ? const EqualizerBars(size: 12)
                      : _hover
                      ? const Icon(
                          Icons.play_arrow_rounded,
                          size: 16,
                          color: AppColors.text,
                        )
                      : Text(
                          '${widget.index + 1}',
                          style: AppText.mono.copyWith(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: t.title,
                          style: TextStyle(
                            color: widget.current
                                ? AppColors.blue
                                : AppColors.text,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(
                          text: '  ${t.artist}',
                          style: const TextStyle(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.body.copyWith(fontSize: 13, height: 1.3),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  length,
                  style: AppText.mono.copyWith(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Chelsea: last result and next fixture ─────────────────────────────

class _MatchPanel extends StatelessWidget {
  const _MatchPanel();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Football.load(NowPlayingData.chelseaTeamId),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return _PanelCard(maxWidth: 560, child: _loading());
        }
        final form = snap.data;
        if (form == null) {
          return _PanelCard(
            maxWidth: 560,
            child: Text(
              'Couldn\'t reach the scores right now. Up the Chels anyway.',
              style: AppText.bodyMuted.copyWith(fontSize: 14),
            ),
          );
        }
        final last = form.last;
        final next = form.next;

        return _PanelCard(
          maxWidth: 560,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (last != null && last.played) ...[
                Text(
                  'LAST RESULT',
                  style: AppText.monoLabel.copyWith(fontSize: 10),
                ),
                const SizedBox(height: 10),
                _Scoreline(match: last),
                const SizedBox(height: 8),
                Text(
                  '${last.competition} · ${last.venue} · ${_day(last.kickoff.toLocal())}',
                  style: AppText.bodyMuted.copyWith(fontSize: 13),
                ),
              ],
              if (next != null) ...[
                if (last != null) ...[
                  const SizedBox(height: 14),
                  Container(height: 1, color: AppColors.line),
                  const SizedBox(height: 14),
                ],
                Text(
                  'NEXT UP',
                  style: AppText.monoLabel.copyWith(fontSize: 10),
                ),
                const SizedBox(height: 6),
                Text(
                  '${next.home} vs ${next.away}',
                  style: AppText.heading.copyWith(fontSize: 18),
                ),
                Text(
                  '${_day(next.kickoff.toLocal())} · ${_time(next.kickoff.toLocal())} your time · ${next.competition}',
                  style: AppText.bodyMuted.copyWith(fontSize: 13, height: 1.5),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _Scoreline extends StatelessWidget {
  final Fixture match;

  const _Scoreline({required this.match});

  @override
  Widget build(BuildContext context) {
    final outcome = match.outcomeFor(Football.team);
    final color = switch (outcome) {
      'W' => AppColors.online,
      'D' => AppColors.textMuted,
      _ => const Color(0xFFFF5A5F),
    };

    Widget team(String name, {required bool end}) => Expanded(
      child: Text(
        name,
        textAlign: end ? TextAlign.end : TextAlign.start,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppText.heading.copyWith(
          fontSize: 17,
          color: name == Football.team ? AppColors.text : AppColors.textMuted,
        ),
      ),
    );

    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Text(
            outcome,
            style: AppText.mono.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ),
        const SizedBox(width: 12),
        team(match.home, end: true),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.blueDeep,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${match.homeScore} – ${match.awayScore}',
            style: AppText.display.copyWith(fontSize: 24, letterSpacing: 0),
          ),
        ),
        team(match.away, end: false),
      ],
    );
  }
}

// ── Learning ──────────────────────────────────────────────────────────

class _LearningPanel extends StatelessWidget {
  const _LearningPanel();

  @override
  Widget build(BuildContext context) {
    return _PanelCard(
      maxWidth: 560,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.blueDeep,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('Go', style: AppText.display.copyWith(fontSize: 18)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'CURRENTLY LEARNING',
                  style: AppText.monoLabel.copyWith(fontSize: 10),
                ),
                const SizedBox(height: 4),
                Text(
                  NowPlayingData.learning,
                  style: AppText.heading.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 6),
                Text(
                  NowPlayingData.learningDetail,
                  style: AppText.bodyMuted.copyWith(fontSize: 14, height: 1.5),
                ),
                const SizedBox(height: 12),
                const _PanelLink(
                  label: 'Follow along on GitHub',
                  url: NowPlayingData.learningUrl,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
