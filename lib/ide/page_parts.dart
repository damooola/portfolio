import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';

import 'controller.dart';
import 'tokens.dart';

/// Every inspectable widget registers its key here, so the shell can scroll
/// to whatever a hovered code line builds.
final inspectKeys = <String, GlobalKey>{};

/// Wraps a page widget so it can be outlined from the code (like Flutter
/// DevTools' select-widget mode) and lights its code lines up on hover.
class Inspectable extends StatefulWidget {
  final String id;

  /// The label shown on the outline, e.g. `Text(name)`.
  final String label;
  final Widget child;

  const Inspectable({
    super.key,
    required this.id,
    required this.label,
    required this.child,
  });

  @override
  State<Inspectable> createState() => _InspectableState();
}

class _InspectableState extends State<Inspectable> {
  final _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    inspectKeys[widget.id] = _key;
  }

  @override
  void didUpdateWidget(Inspectable old) {
    super.didUpdateWidget(old);
    if (old.id != widget.id) {
      if (inspectKeys[old.id] == _key) inspectKeys.remove(old.id);
      inspectKeys[widget.id] = _key;
    }
  }

  @override
  void dispose() {
    if (inspectKeys[widget.id] == _key) inspectKeys.remove(widget.id);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = IdeScope.of(context);
    final on = c.inspecting == widget.id;
    final d = Motion.of(context, Motion.fast);
    return MouseRegion(
      key: _key,
      onEnter: (_) => IdeScope.read(context).hoverPage(widget.id),
      onExit: (_) {
        final ide = IdeScope.read(context);
        if (ide.pageHover == widget.id) ide.hoverPage(null);
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          widget.child,
          Positioned(
            left: -8,
            top: -8,
            right: -8,
            bottom: -8,
            child: IgnorePointer(
              child: AnimatedOpacity(
                duration: d,
                opacity: on ? 1 : 0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Ide.flutter.withValues(alpha: 0.05),
                    border: Border.all(color: Ide.flutter, width: 1.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: -8,
            top: -32,
            child: IgnorePointer(
              child: AnimatedOpacity(
                duration: d,
                opacity: on ? 1 : 0,
                child: AnimatedSlide(
                  duration: d,
                  offset: on ? Offset.zero : const Offset(0, 0.3),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Ide.flutter,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      widget.label,
                      style: Txt.mono(
                        11,
                        color: Colors.white,
                        medium: true,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Cross-fades a value when it changes (texts the code can edit).
class Swap extends StatelessWidget {
  final Object id;
  final Widget child;
  final Alignment alignment;

  const Swap({
    super.key,
    required this.id,
    required this.child,
    this.alignment = Alignment.topLeft,
  });

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
    duration: Motion.of(context, Motion.medium),
    switchInCurve: Motion.ease,
    switchOutCurve: Curves.easeIn,
    layoutBuilder: (current, previous) =>
        Stack(alignment: alignment, children: [...previous, ?current]),
    transitionBuilder: (child, anim) => FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(anim),
        child: child,
      ),
    ),
    child: KeyedSubtree(key: ValueKey(id), child: child),
  );
}

/// Section label like "01 · WORK".
class Kicker extends StatelessWidget {
  final String text;

  const Kicker(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: Txt.label(PageThemeScope.of(context).accent, size: 12),
  );
}

class SectionTitle extends StatelessWidget {
  final String text;
  final double size;

  const SectionTitle(this.text, {super.key, this.size = 38});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 14),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 680),
      child: Text(
        text,
        style: Txt.display(
          size,
          color: PageThemeScope.of(context).fg,
          height: 1.08,
          tracking: -0.04,
        ),
      ),
    ),
  );
}

class Lede extends StatelessWidget {
  final String text;

  const Lede(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 14),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 560),
      child: Text(
        text,
        style: Txt.sans(16.5, color: PageThemeScope.of(context).muted),
      ),
    ),
  );
}

/// The page's button: filled (primary) or outlined, lifts on hover.
class PageButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final bool primary;
  final IconData? icon;

  const PageButton({
    super.key,
    required this.label,
    required this.onTap,
    this.primary = false,
    this.icon,
  });

  @override
  State<PageButton> createState() => _PageButtonState();
}

class _PageButtonState extends State<PageButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final t = PageThemeScope.of(context);
    final fg = widget.primary ? t.bg : t.fg;
    return Semantics(
      button: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: Motion.fast,
            curve: Motion.ease,
            transform: Matrix4.translationValues(0, _hover ? -1.5 : 0, 0),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
            decoration: BoxDecoration(
              color: widget.primary ? t.fg : t.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: widget.primary
                    ? t.fg
                    : (_hover ? t.muted.withValues(alpha: 0.5) : t.line),
              ),
              boxShadow: _hover
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.10),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : const [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, size: 16, color: fg),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    widget.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Txt.sans(14.5, color: fg, weight: 500, height: 1),
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

/// Small outlined chip ("Android", "Flutter").
class Chip2 extends StatelessWidget {
  final String text;
  final bool accent;

  const Chip2(this.text, {super.key, this.accent = false});

  @override
  Widget build(BuildContext context) {
    final t = PageThemeScope.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: accent ? t.accentSoft : t.surface,
        borderRadius: BorderRadius.circular(7),
        border: accent ? null : Border.all(color: t.line),
      ),
      child: Text(
        text,
        style: Txt.mono(12, color: accent ? t.accent : t.fg, height: 1),
      ),
    );
  }
}

/// Lets mouse users drag horizontal rows, as on touch.
class DragScroll extends MaterialScrollBehavior {
  const DragScroll();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
  };
}

/// A horizontal row with arrow buttons on wide screens.
class SwipeRow extends StatefulWidget {
  final double height;
  final int count;
  final double itemWidth;
  final double gap;
  final IndexedWidgetBuilder builder;

  const SwipeRow({
    super.key,
    required this.height,
    required this.count,
    required this.itemWidth,
    required this.builder,
    this.gap = 14,
  });

  @override
  State<SwipeRow> createState() => _SwipeRowState();
}

class _SwipeRowState extends State<SwipeRow> {
  final _scroll = ScrollController();
  bool _atStart = true;
  bool _atEnd = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_update);
    WidgetsBinding.instance.addPostFrameCallback((_) => _update());
  }

  void _update() {
    if (!_scroll.hasClients || !mounted) return;
    final p = _scroll.position;
    final start = p.pixels <= 2;
    final end = p.pixels >= p.maxScrollExtent - 2;
    if (start != _atStart || end != _atEnd) {
      setState(() {
        _atStart = start;
        _atEnd = end;
      });
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _page(int dir) {
    final p = _scroll.position;
    _scroll.animateTo(
      (p.pixels + dir * (widget.itemWidth + widget.gap) * 2).clamp(
        0,
        p.maxScrollExtent,
      ),
      duration: Motion.slow,
      curve: Motion.ease,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = PageThemeScope.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: widget.height,
          child: ScrollConfiguration(
            behavior: const DragScroll(),
            child: ListView.separated(
              controller: _scroll,
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              itemCount: widget.count,
              separatorBuilder: (_, _) => SizedBox(width: widget.gap),
              itemBuilder: (context, i) => SizedBox(
                width: widget.itemWidth,
                child: widget.builder(context, i),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            _Arrow(
              icon: Icons.arrow_back_rounded,
              enabled: !_atStart,
              onTap: () => _page(-1),
              theme: t,
            ),
            const SizedBox(width: 8),
            _Arrow(
              icon: Icons.arrow_forward_rounded,
              enabled: !_atEnd,
              onTap: () => _page(1),
              theme: t,
            ),
          ],
        ),
      ],
    );
  }
}

class _Arrow extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  final PageTheme theme;

  const _Arrow({
    required this.icon,
    required this.enabled,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
    child: GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(
        duration: Motion.fast,
        opacity: enabled ? 1 : 0.35,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.surface,
            border: Border.all(color: theme.line),
          ),
          child: Icon(icon, size: 17, color: theme.fg),
        ),
      ),
    ),
  );
}
