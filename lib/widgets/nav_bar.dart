import 'dart:ui';

import 'package:flutter/material.dart';
import '../data/portfolio_data.dart';
import '../services/music.dart';
import '../services/sfx.dart';
import '../theme/app_theme.dart';
import 'now_playing.dart';

class NavLink {
  final String label;
  final VoidCallback onTap;

  const NavLink(this.label, this.onTap);
}

class NavBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onHome;
  final List<NavLink> links;
  final List<Widget> trailing;

  const NavBar({
    super.key,
    required this.onHome,
    required this.links,
    this.trailing = const [],
  });

  @override
  Size get preferredSize => const Size.fromHeight(68);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = AppBreakpoints.isMobile(width);
    // Phones only get room for the two links recruiters need most.
    // Phones get the two links recruiters need most, tablets the main four,
    // desktops everything.
    const phoneLinks = {'Work', 'Contact'};
    const tabletLinks = {'Work', 'Career', 'Writing', 'Contact'};
    final shown = isMobile
        ? links.where((l) => phoneLinks.contains(l.label))
        : width < 1100
        ? links.where((l) => tabletLinks.contains(l.label))
        : links;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.night.withValues(alpha: 0.72),
            border: const Border(bottom: BorderSide(color: AppColors.line)),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? AppSpacing.sm : AppSpacing.xl,
          ),
          child: SafeArea(
            bottom: false,
            child: Center(
              heightFactor: 1,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: AppBreakpoints.contentWidth(width),
                ),
                child: SizedBox(
                  height: preferredSize.height,
                  child: Row(
                    children: [
                      _Monogram(onTap: onHome),
                      const Spacer(),
                      for (final link in shown) ...[
                        _NavText(link: link),
                        SizedBox(
                          width: isMobile ? AppSpacing.sm : AppSpacing.md,
                        ),
                      ],
                      ...trailing,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Monogram extends StatelessWidget {
  final VoidCallback onTap;

  const _Monogram({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Semantics(
          label: '${ProfileData.name}, back to top',
          button: true,
          child: Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.blueDeep,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.blue.withValues(alpha: 0.5)),
            ),
            child: Text(
              ProfileData.initials,
              style: AppText.display.copyWith(
                fontSize: 16,
                letterSpacing: -0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavText extends StatefulWidget {
  final NavLink link;

  const _NavText({required this.link});

  @override
  State<_NavText> createState() => _NavTextState();
}

class _NavTextState extends State<_NavText> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.link.onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.link.label,
              style: AppText.body.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _hover ? AppColors.text : AppColors.textMuted,
              ),
            ),
            AnimatedContainer(
              duration: AppMotion.hover,
              curve: AppMotion.settle,
              margin: const EdgeInsets.only(top: 3),
              height: 1.5,
              width: _hover ? 18 : 0,
              color: AppColors.blue,
            ),
          ],
        ),
      ),
    );
  }
}

/// Sound effects toggle (clicks, dings, the sync stamp). Off until the
/// visitor turns it on. Music is separate: it has its own play button.
class SoundToggle extends StatelessWidget {
  const SoundToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Sfx.enabled,
      builder: (context, on, _) => Tooltip(
        message: on ? 'Sound effects on (S)' : 'Sound effects off (S)',
        child: IconButton(
          onPressed: Sfx.toggle,
          visualDensity: VisualDensity.compact,
          style: IconButton.styleFrom(
            backgroundColor: on
                ? AppColors.blue.withValues(alpha: 0.18)
                : Colors.transparent,
            side: const BorderSide(color: AppColors.line),
          ),
          icon: AnimatedSwitcher(
            duration: AppMotion.hover,
            transitionBuilder: (child, a) =>
                ScaleTransition(scale: a, child: child),
            child: Icon(
              on ? Icons.volume_up_rounded : Icons.volume_off_rounded,
              key: ValueKey(on),
              size: 18,
              color: on ? AppColors.blue : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}

/// Shows up in the nav while music is playing (or paused mid-song), so the
/// visitor can stop it from anywhere on the page, not just the hero.
class NowPlayingPill extends StatelessWidget {
  const NowPlayingPill({super.key});

  @override
  Widget build(BuildContext context) {
    final music = PlaylistController.instance;
    final isMobile = AppBreakpoints.isMobile(MediaQuery.sizeOf(context).width);

    return ListenableBuilder(
      listenable: music,
      builder: (context, _) {
        final track = music.current;
        final show = music.active && track != null;

        return AnimatedSize(
          duration: AppMotion.big,
          curve: AppMotion.settle,
          child: !show
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Tooltip(
                    message: music.playing ? 'Pause music' : 'Resume music',
                    child: Semantics(
                      button: true,
                      label: music.playing
                          ? 'Pause ${track.title}'
                          : 'Resume ${track.title}',
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: music.toggle,
                          child: Container(
                            height: 34,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: AppColors.blue.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: AppColors.blue.withValues(alpha: 0.5),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (music.playing)
                                  const EqualizerBars(size: 12)
                                else
                                  const Icon(
                                    Icons.music_note_rounded,
                                    size: 14,
                                    color: AppColors.textMuted,
                                  ),
                                if (!isMobile) ...[
                                  const SizedBox(width: 8),
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 150,
                                    ),
                                    child: Text(
                                      track.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppText.body.copyWith(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                                const SizedBox(width: 6),
                                Icon(
                                  music.playing
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  size: 18,
                                  color: AppColors.text,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }
}
