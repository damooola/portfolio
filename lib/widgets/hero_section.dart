import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../data/portfolio_data.dart';
import '../services/sfx.dart';
import '../theme/app_theme.dart';
import 'buttons.dart';
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

class _NowPlayingStripState extends State<NowPlayingStrip> {
  bool _player = false;

  static final _hasPlaylist =
      SpotifyEmbed.embedUrl(NowPlayingData.spotifyPlaylistUrl) != null;

  void _togglePlayer() {
    Sfx.play(Sound.click);
    setState(() => _player = !_player);
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
                        child: _NowTile(
                          item: items[i],
                          compact: columns == 2,
                          playing: _player,
                          onPlay:
                              items[i].$3 == Icons.music_note_outlined &&
                                  _hasPlaylist
                              ? _togglePlayer
                              : null,
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
              child: _player
                  ? ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: const Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: SpotifyEmbed(
                          shareUrl: NowPlayingData.spotifyPlaylistUrl,
                        ),
                      ),
                    )
                  : const SizedBox(width: 0),
            ),
          ],
        );
      },
    );
  }
}

class _NowTile extends StatefulWidget {
  final (String, String, IconData) item;
  final bool compact;
  final bool playing;

  /// Set on the song tile when a playlist is configured.
  final VoidCallback? onPlay;

  const _NowTile({
    required this.item,
    required this.compact,
    required this.playing,
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
            child: Icon(
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
                Text(
                  value,
                  maxLines: widget.compact ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.body.copyWith(
                    fontSize: widget.compact ? 12.5 : 14,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
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
                widget.playing ? Icons.close_rounded : Icons.play_arrow_rounded,
                size: 18,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );

    // Only the song tile is clickable (it toggles the player).
    if (onPlay == null) {
      return MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: tile,
      );
    }
    return Tooltip(
      message: widget.playing ? 'Hide player' : 'Play on Spotify',
      child: Semantics(
        button: true,
        label: widget.playing
            ? 'Hide Spotify player'
            : 'Play my playlist on Spotify',
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _hover = true),
          onExit: (_) => setState(() => _hover = false),
          child: GestureDetector(onTap: onPlay, child: tile),
        ),
      ),
    );
  }
}
