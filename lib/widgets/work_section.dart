import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/portfolio_data.dart';
import '../demos/offline_sync_demo.dart';
import '../demos/otp_demo.dart';
import '../demos/chat_demo.dart';
import '../demos/face_check_demo.dart';
import '../demos/loan_fix_demo.dart';
import '../demos/planner_demo.dart';
import '../demos/route_map_demo.dart';
import '../services/sfx.dart';
import '../theme/app_theme.dart';
import 'demo_phone.dart';
import 'responsive_section.dart';
import 'reveal.dart';
import 'section_header.dart';
import 'shortcut_sheet.dart';

/// Three projects, each paired with a live demo in a phone frame. The
/// phone tilts toward the cursor, and switching projects slides the screen
/// across like an app switcher.
///
/// [selected] is owned by the page so the arrow keys can drive it too.
class WorkSection extends StatelessWidget {
  final ValueNotifier<int> selected;

  const WorkSection({super.key, required this.selected});

  static void select(ValueNotifier<int> selected, int index) {
    final count = ProjectsData.projects.length;
    final next = index % count < 0 ? index % count + count : index % count;
    if (next == selected.value) return;
    Sfx.play(Sound.chime);
    selected.value = next;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final sideBySide = width >= AppBreakpoints.tablet;
    final isMobile = AppBreakpoints.isMobile(width);

    return ResponsiveSection(
      child: ValueListenableBuilder(
        valueListenable: selected,
        builder: (context, index, _) {
          final project = ProjectsData.projects[index];
          final list = _ProjectList(
            selected: index,
            onSelect: (i) => select(selected, i),
            compact: isMobile,
          );
          final phone = _PhoneColumn(index: index, project: project);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(
                index: '01',
                label: 'Work',
                title: 'Things I\'ve built',
                caption:
                    'The real apps belong to the companies I built them for, so '
                    'these are small working versions I rebuilt for this site. '
                    'Go ahead and poke them.',
              ),
              if (sideBySide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Reveal(child: list)),
                    const SizedBox(width: AppSpacing.xl),
                    Reveal(
                      delay: const Duration(milliseconds: 120),
                      child: phone,
                    ),
                  ],
                )
              else ...[
                Reveal(child: list),
                const SizedBox(height: AppSpacing.lg),
                Reveal(child: Center(child: phone)),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _ProjectList extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelect;
  final bool compact;

  const _ProjectList({
    required this.selected,
    required this.onSelect,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    final projects = ProjectsData.projects;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < projects.length; i++) ...[
          _ProjectTile(
            index: i,
            project: projects[i],
            selected: i == selected,
            compact: compact,
            onTap: () => onSelect(i),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        if (!compact) ...[
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              const KeyCap('←', size: 11),
              const SizedBox(width: 4),
              const KeyCap('→', size: 11),
              const SizedBox(width: 10),
              Text(
                'switch project',
                style: AppText.monoLabel.copyWith(fontSize: 11),
              ),
              const SizedBox(width: AppSpacing.md),
              const KeyCap('?', size: 11),
              const SizedBox(width: 10),
              Text(
                'all shortcuts',
                style: AppText.monoLabel.copyWith(fontSize: 11),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _ProjectTile extends StatefulWidget {
  final int index;
  final Project project;
  final bool selected;
  final bool compact;
  final VoidCallback onTap;

  const _ProjectTile({
    required this.index,
    required this.project,
    required this.selected,
    required this.compact,
    required this.onTap,
  });

  @override
  State<_ProjectTile> createState() => _ProjectTileState();
}

class _ProjectTileState extends State<_ProjectTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.project;
    final selected = widget.selected;

    return Semantics(
      button: true,
      selected: selected,
      label: 'Show ${p.name} demo',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: AppMotion.hover,
            curve: AppMotion.settle,
            padding: EdgeInsets.all(
              widget.compact ? AppSpacing.sm : AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: selected || _hover ? AppColors.raised : AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: selected ? AppColors.blue : AppColors.line,
                width: selected ? 1.5 : 1,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: AppColors.blue.withValues(alpha: 0.18),
                        blurRadius: 30,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      (widget.index + 1).toString().padLeft(2, '0'),
                      style: AppText.mono.copyWith(
                        fontSize: 13,
                        color: selected ? AppColors.blue : AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        p.name,
                        style: AppText.heading.copyWith(
                          fontSize: widget.compact ? 19 : 23,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: selected ? 0 : -0.125,
                      duration: AppMotion.big,
                      curve: AppMotion.spring,
                      child: Icon(
                        Icons.arrow_forward,
                        size: 18,
                        color: selected ? AppColors.blue : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: EdgeInsets.only(left: widget.compact ? 0 : 33),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${p.org.toUpperCase()} · ${p.period}',
                        style: AppText.monoLabel.copyWith(fontSize: 11),
                      ),
                      // Details only on the open project, to keep one idea on screen.
                      AnimatedSize(
                        duration: AppMotion.big,
                        curve: AppMotion.settle,
                        alignment: Alignment.topLeft,
                        child: selected
                            ? Padding(
                                padding: const EdgeInsets.only(
                                  top: AppSpacing.sm,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p.summary,
                                      style: AppText.bodyMuted.copyWith(
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      children: [
                                        for (final t in p.tags) _Tag(t),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox(width: double.infinity),
                      ),
                    ],
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

class _Tag extends StatelessWidget {
  final String label;

  const _Tag(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.night,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.line),
      ),
      child: Text(
        label,
        style: AppText.mono.copyWith(fontSize: 11, color: AppColors.textMuted),
      ),
    );
  }
}

/// The phone, plus the two lines under it.
class _PhoneColumn extends StatefulWidget {
  final int index;
  final Project project;

  const _PhoneColumn({required this.index, required this.project});

  @override
  State<_PhoneColumn> createState() => _PhoneColumnState();
}

class _PhoneColumnState extends State<_PhoneColumn> {
  /// Which of the project's demos is on screen.
  int _demo = 0;

  @override
  void didUpdateWidget(_PhoneColumn old) {
    super.didUpdateWidget(old);
    if (old.index != widget.index) _demo = 0;
  }

  void _pick(int i) {
    if (i == _demo) return;
    Sfx.play(Sound.chime);
    setState(() => _demo = i);
  }

  @override
  Widget build(BuildContext context) {
    final index = widget.index;
    final project = widget.project;
    final isMobile = AppBreakpoints.isMobile(MediaQuery.sizeOf(context).width);
    final kind = project.demos[_demo.clamp(0, project.demos.length - 1)];
    final demo = switch (kind) {
      DemoKind.loanFix => const LoanFixDemo(),
      DemoKind.faceCheck => const FaceCheckDemo(),
      DemoKind.offlineSync => const OfflineSyncDemo(),
      DemoKind.planner => const PlannerDemo(),
      DemoKind.chat => const ChatDemo(),
      DemoKind.routeMap => const RouteMapDemo(),
      DemoKind.otp => const OtpDemo(),
    };
    // One number per screen so the app switcher knows which way to slide.
    final screen = index * 10 + _demo;

    final phone = DemoPhone(
      screenId: screen,
      child: _AppSwitcher(
        index: screen,
        child: KeyedSubtree(key: ValueKey(screen), child: demo),
      ),
    );

    return SizedBox(
      width: isMobile ? double.infinity : DemoPhone.screenWidth + 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (project.demos.length > 1) ...[
            _DemoTabs(demos: project.demos, selected: _demo, onPick: _pick),
            const SizedBox(height: AppSpacing.sm),
          ],
          if (isMobile) phone else Center(child: _TiltOnHover(child: phone)),
          const SizedBox(height: AppSpacing.md),
          AnimatedSwitcher(
            duration: AppMotion.hover,
            child: Column(
              key: ValueKey(index),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.builtForReal,
                  style: AppText.body.copyWith(fontSize: 14, height: 1.5),
                ),
                const SizedBox(height: 6),
                Text(
                  project.result,
                  style: AppText.bodyMuted.copyWith(fontSize: 14, height: 1.5),
                ),
                if (project.linkUrl != null) ...[
                  const SizedBox(height: 6),
                  _TextLink(
                    label: '${project.linkLabel ?? 'Read more'} →',
                    url: project.linkUrl!,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Picks between a project's live demos.
class _DemoTabs extends StatelessWidget {
  final List<DemoKind> demos;
  final int selected;
  final ValueChanged<int> onPick;

  const _DemoTabs({
    required this.demos,
    required this.selected,
    required this.onPick,
  });

  static IconData _icon(DemoKind kind) => switch (kind) {
    DemoKind.planner => Icons.calendar_view_day_outlined,
    DemoKind.chat => Icons.chat_bubble_outline,
    DemoKind.routeMap => Icons.map_outlined,
    DemoKind.loanFix => Icons.fact_check_outlined,
    DemoKind.faceCheck => Icons.face_retouching_natural,
    DemoKind.offlineSync => Icons.sync,
    DemoKind.otp => Icons.pin_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.line),
            ),
            child: Row(
              children: [
                for (final (i, kind) in demos.indexed)
                  Expanded(
                    child: Semantics(
                      button: true,
                      selected: i == selected,
                      label: '${kind.label} demo',
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () => onPick(i),
                          child: AnimatedContainer(
                            duration: AppMotion.hover,
                            padding: const EdgeInsets.symmetric(vertical: 7),
                            decoration: BoxDecoration(
                              color: i == selected
                                  ? AppColors.blue
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            // Shrinks rather than overflowing on narrow phones.
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _icon(kind),
                                    size: 14,
                                    color: i == selected
                                        ? Colors.white
                                        : AppColors.textMuted,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    kind.label,
                                    style: AppText.body.copyWith(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: i == selected
                                          ? Colors.white
                                          : AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TextLink extends StatelessWidget {
  final String label;
  final String url;

  const _TextLink({required this.label, required this.url});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => launchUrl(Uri.parse(url)),
        child: Text(
          label,
          style: AppText.body.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.blue,
          ),
        ),
      ),
    );
  }
}

/// Slides the incoming screen in from the side it's coming from, while the
/// old one shrinks back and slides out — like an app switcher.
class _AppSwitcher extends StatefulWidget {
  final int index;
  final Widget child;

  const _AppSwitcher({required this.index, required this.child});

  @override
  State<_AppSwitcher> createState() => _AppSwitcherState();
}

class _AppSwitcherState extends State<_AppSwitcher> {
  int _direction = 1;

  @override
  void didUpdateWidget(_AppSwitcher old) {
    super.didUpdateWidget(old);
    if (old.index != widget.index) {
      _direction = widget.index > old.index ? 1 : -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final reduced = AppMotion.reduced(context);
    return ClipRect(
      child: AnimatedSwitcher(
        duration: AppMotion.big,
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        layoutBuilder: (current, previous) =>
            Stack(children: [...previous, ?current]),
        transitionBuilder: (child, animation) {
          if (reduced) return FadeTransition(opacity: animation, child: child);
          final incoming = child.key == widget.child.key;
          final from = Offset(
            incoming ? _direction.toDouble() : -_direction.toDouble(),
            0,
          );
          return SlideTransition(
            position: Tween(begin: from, end: Offset.zero).animate(animation),
            child: ScaleTransition(
              scale: Tween(begin: 0.88, end: 1.0).animate(animation),
              child: FadeTransition(opacity: animation, child: child),
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}

/// Tilts the phone in 3D toward the cursor.
class _TiltOnHover extends StatefulWidget {
  final Widget child;

  const _TiltOnHover({required this.child});

  @override
  State<_TiltOnHover> createState() => _TiltOnHoverState();
}

class _TiltOnHoverState extends State<_TiltOnHover> {
  Offset _tilt = Offset.zero;

  void _onHover(PointerHoverEvent e, Size size) {
    final dx = (e.localPosition.dx / size.width - 0.5) * 2;
    final dy = (e.localPosition.dy / size.height - 0.5) * 2;
    setState(() => _tilt = Offset(dx.clamp(-1, 1), dy.clamp(-1, 1)));
  }

  @override
  Widget build(BuildContext context) {
    if (AppMotion.reduced(context)) return widget.child;
    const maxAngle = 0.12; // ~7 degrees

    return LayoutBuilder(
      builder: (context, constraints) {
        return MouseRegion(
          onHover: (e) => _onHover(e, context.size ?? Size.zero),
          onExit: (_) => setState(() => _tilt = Offset.zero),
          child: RepaintBoundary(
            child: TweenAnimationBuilder<Offset>(
              tween: Tween(end: _tilt),
              duration: const Duration(milliseconds: 220),
              curve: AppMotion.settle,
              builder: (context, t, child) => Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0012)
                  ..rotateX(-t.dy * maxAngle)
                  ..rotateY(t.dx * maxAngle),
                child: child,
              ),
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}
