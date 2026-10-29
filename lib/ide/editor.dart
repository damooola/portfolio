import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'controller.dart';
import 'source.dart';
import 'tokens.dart';

/// Tabs, breadcrumb and code for the open file.
class Editor extends StatelessWidget {
  const Editor({super.key});

  @override
  Widget build(BuildContext context) {
    final c = IdeScope.of(context);
    return ColoredBox(
      color: Ide.bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const FileTabs(),
          Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.centerLeft,
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Ide.line)),
            ),
            child: _Crumb(text: crumbFor(c.file)),
          ),
          Expanded(child: CodeView(file: c.file)),
        ],
      ),
    );
  }
}

class _Crumb extends StatelessWidget {
  final String text;

  const _Crumb({required this.text});

  @override
  Widget build(BuildContext context) {
    final parts = text.split(' › ');
    return Text.rich(
      TextSpan(
        children: [
          for (var i = 0; i < parts.length; i++) ...[
            if (i > 0) const TextSpan(text: '  ›  '),
            TextSpan(
              text: parts[i],
              style: TextStyle(
                color: i == parts.length - 1 && parts.length > 1
                    ? Ide.text
                    : null,
              ),
            ),
          ],
        ],
      ),
      style: Txt.mono(12, color: Ide.dim),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class FileTabs extends StatelessWidget {
  const FileTabs({super.key});

  @override
  Widget build(BuildContext context) {
    final c = IdeScope.of(context);
    return Container(
      height: 40,
      decoration: const BoxDecoration(
        color: Ide.panel,
        border: Border(bottom: BorderSide(color: Ide.line)),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final f in SourceFile.values)
            _Tab(file: f, selected: f == c.file),
        ],
      ),
    );
  }
}

class _Tab extends StatefulWidget {
  final SourceFile file;
  final bool selected;

  const _Tab({required this.file, required this.selected});

  @override
  State<_Tab> createState() => _TabState();
}

class _TabState extends State<_Tab> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final f = widget.file;
    final icon = f.label.endsWith('.log')
        ? Ide.warn
        : f.label.endsWith('.sh')
        ? Ide.live
        : const Color(0xFF42A5F5);
    final on = widget.selected;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () => IdeJump.of(context)?.openFile(f),
        child: AnimatedContainer(
          duration: Motion.fast,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: on ? Ide.bg : (_hover ? Ide.hover : null),
            border: Border(
              top: BorderSide(
                color: on ? Ide.flutter : Colors.transparent,
                width: 1.5,
              ),
              right: const BorderSide(color: Ide.line),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: icon,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 9),
              Text(
                f.label,
                style: Txt.mono(12.5, color: on ? Ide.bright : Ide.dim),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Lets the editor and tree ask the shell to open a file and scroll the page
/// to the section it builds.
class IdeJump extends InheritedWidget {
  final void Function(SourceFile file) openFile;
  final void Function(String section, [String? anchor]) jumpTo;

  const IdeJump({
    super.key,
    required this.openFile,
    required this.jumpTo,
    required super.child,
  });

  static IdeJump? of(BuildContext context) =>
      context.getInheritedWidgetOfExactType<IdeJump>();

  @override
  bool updateShouldNotify(IdeJump old) => false;
}

/// Syntax-highlighted lines with a gutter. Hovering a line outlines the
/// widget it builds; clicking an orange or green value changes it.
class CodeView extends StatelessWidget {
  final SourceFile file;
  final double fontSize;
  final bool compact;

  const CodeView({
    super.key,
    required this.file,
    this.fontSize = 13.5,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = IdeScope.of(context);
    final lines = linesFor(file, c);
    final gutter = compact ? 36.0 : 52.0;
    return LayoutBuilder(
      builder: (context, box) {
        // Lines never wrap; long ones scroll sideways, like an editor.
        final width = math.max(box.maxWidth, compact ? 560.0 : 720.0);
        return Scrollbar(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(top: compact ? 10 : 18, bottom: 40),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < lines.length; i++)
                      CodeLine(
                        key: ValueKey('${file.name}-$i'),
                        number: i + 1,
                        line: lines[i],
                        gutter: gutter,
                        fontSize: fontSize,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class CodeLine extends StatefulWidget {
  final int number;
  final SourceLine line;
  final double gutter;
  final double fontSize;

  const CodeLine({
    super.key,
    required this.number,
    required this.line,
    required this.gutter,
    required this.fontSize,
  });

  @override
  State<CodeLine> createState() => _CodeLineState();
}

class _CodeLineState extends State<CodeLine>
    with SingleTickerProviderStateMixin {
  bool _hover = false;
  late final _glow = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );
  int _seenReloads = -1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final c = IdeScope.of(context);
    if (_seenReloads == -1) {
      _seenReloads = c.reloads;
      return;
    }
    if (c.reloads != _seenReloads) {
      _seenReloads = c.reloads;
      final changed = c.lastChanged;
      if (changed != null && widget.line.spans.any((s) => s.key == changed)) {
        _glow.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _glow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = IdeScope.of(context);
    final target = widget.line.target;
    final lit = target != null && (_hover || c.pageHover == target);
    final style = Txt.mono(widget.fontSize, color: Ide.text, height: 1.85);

    return MouseRegion(
      onEnter: (_) {
        setState(() => _hover = true);
        if (target != null) IdeScope.read(context).inspect(target);
      },
      onExit: (_) {
        setState(() => _hover = false);
        final ide = IdeScope.read(context);
        if (ide.inspecting == target) ide.inspect(null);
      },
      child: AnimatedBuilder(
        animation: _glow,
        builder: (context, child) {
          final glow =
              Curves.easeOut.transform(1 - _glow.value) *
              (_glow.isAnimating ? 1 : 0);
          return Container(
            decoration: BoxDecoration(
              color: Color.lerp(
                lit ? const Color(0x123D8BFF) : Colors.transparent,
                const Color(0x2EF2C14E),
                glow,
              ),
              border: Border(
                left: BorderSide(
                  color: lit ? Ide.flutter : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
            child: child,
          );
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: widget.gutter,
              child: Padding(
                padding: const EdgeInsets.only(right: 18),
                child: Text(
                  '${widget.number}',
                  textAlign: TextAlign.right,
                  style: style.copyWith(color: lit ? Ide.flutter : Ide.gutter),
                ),
              ),
            ),
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    for (final s in widget.line.spans) _span(context, s),
                  ],
                ),
                style: style,
                softWrap: false,
                overflow: TextOverflow.visible,
              ),
            ),
          ],
        ),
      ),
    );
  }

  InlineSpan _span(BuildContext context, Span s) {
    final color = switch (s.kind) {
      Tok.plain => Ide.text,
      Tok.keyword => Ide.keyword,
      Tok.string => Ide.string,
      Tok.type => Ide.type,
      Tok.prop => Ide.prop,
      Tok.number => Ide.number,
      Tok.comment => Ide.comment,
      Tok.value => s.text.startsWith("'") ? Ide.string : Ide.value,
      Tok.link => Ide.type,
    };
    if (s.kind == Tok.value || s.kind == Tok.link) {
      return WidgetSpan(
        alignment: PlaceholderAlignment.baseline,
        baseline: TextBaseline.alphabetic,
        child: _Clickable(
          text: s.text,
          color: color,
          fontSize: widget.fontSize,
          dashed: s.kind == Tok.value,
          tooltip: s.kind == Tok.value ? 'Click to change' : 'Open ${s.text}',
          onTap: () {
            if (s.file != null) {
              IdeJump.of(context)?.openFile(s.file!);
            } else if (s.key != null) {
              IdeScope.read(context).cycle(s.key!);
            }
          },
        ),
      );
    }
    return TextSpan(
      text: s.text,
      style: TextStyle(
        color: color,
        fontStyle: s.kind == Tok.comment ? FontStyle.italic : FontStyle.normal,
      ),
    );
  }
}

class _Clickable extends StatefulWidget {
  final String text;
  final Color color;
  final double fontSize;
  final bool dashed;
  final String tooltip;
  final VoidCallback onTap;

  const _Clickable({
    required this.text,
    required this.color,
    required this.fontSize,
    required this.dashed,
    required this.tooltip,
    required this.onTap,
  });

  @override
  State<_Clickable> createState() => _ClickableState();
}

class _ClickableState extends State<_Clickable> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${widget.text}. ${widget.tooltip}',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: Motion.fast,
            decoration: BoxDecoration(
              color: _hover
                  ? widget.color.withValues(alpha: 0.14)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              widget.text,
              style: Txt.mono(widget.fontSize, color: widget.color, height: 1.4)
                  .copyWith(
                    decoration: TextDecoration.underline,
                    decorationStyle: widget.dashed
                        ? TextDecorationStyle.dashed
                        : TextDecorationStyle.solid,
                    decorationColor: widget.color.withValues(
                      alpha: _hover ? 0.9 : 0.45,
                    ),
                    decorationThickness: 1,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
