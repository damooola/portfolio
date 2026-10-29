import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/portfolio_data.dart';
import 'chrome.dart';
import 'controller.dart';
import 'editor.dart';
import 'page.dart';
import 'page_parts.dart';
import 'tokens.dart';

const _sections = [
  'home',
  'work',
  'career',
  'writing',
  'afterhours',
  'contact',
];

/// The whole site. Desktop: a Flutter IDE (widget tree, editor, console)
/// around a live preview of the page. Phones: you're on the device, so you
/// get the page, with a button to slide the source up.
class IdeShell extends StatefulWidget {
  final IdeController? controller;

  const IdeShell({super.key, this.controller});

  @override
  State<IdeShell> createState() => _IdeShellState();
}

class _IdeShellState extends State<IdeShell> {
  late final IdeController _c = widget.controller ?? IdeController();
  final _scroll = ScrollController();
  final _keys = {for (final s in _sections) s: GlobalKey()};
  final _viewport = GlobalKey();
  final _boot = <Timer>[];

  /// True while a programmatic scroll runs, so passing sections don't flip
  /// the open tab on the way.
  bool _jumping = false;
  String? _lastInspected;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_syncSection);
    _c.addListener(_onController);
    HardwareKeyboard.instance.addHandler(_onKey);

    const boot = [
      (LogKind.plain, 'Launching lib/main.dart on Chrome in debug mode...'),
      (LogKind.ok, '✓ Built build/web'),
      (LogKind.plain, 'Debug service listening on ws://127.0.0.1:7357'),
      (LogKind.info, 'flutter: Hello. Hover any line to see what it builds.'),
      (
        LogKind.info,
        'flutter: Click an orange or green value to change it. r reloads, R restarts.',
      ),
    ];
    for (var i = 0; i < boot.length; i++) {
      _boot.add(
        Timer(Duration(milliseconds: 250 + i * 240), () {
          if (mounted) _c.log(boot[i].$1, boot[i].$2);
        }),
      );
    }

    // Deep links: /#work, /#career, /#writing, /#after-hours, /#contact.
    final fragment = Uri.base.fragment.replaceAll('/', '');
    final target = switch (fragment) {
      'after-hours' || 'afterhours' => 'afterhours',
      final f when _sections.contains(f) => f,
      _ => null,
    };
    if (target != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _jumpTo(target, null, animate: false),
      );
    }
  }

  @override
  void dispose() {
    for (final t in _boot) {
      t.cancel();
    }
    HardwareKeyboard.instance.removeHandler(_onKey);
    _c.removeListener(_onController);
    if (widget.controller == null) _c.dispose();
    _scroll.dispose();
    super.dispose();
  }

  // ── Keyboard ─────────────────────────────────────────────────────────────

  bool _onKey(KeyEvent event) {
    if (event is! KeyDownEvent || !mounted) return false;
    final typing =
        FocusManager.instance.primaryFocus?.context
            ?.findAncestorWidgetOfExactType<EditableText>() !=
        null;
    if (typing) return false;
    final ch = event.character;
    if (ch == 'r') {
      _c.hotReload();
      return true;
    }
    if (ch == 'R') {
      _c.hotRestart();
      return true;
    }
    return false;
  }

  // ── Scrolling ────────────────────────────────────────────────────────────

  void _syncSection() {
    if (_jumping || !_scroll.hasClients) return;
    final viewport = _scroll.position.viewportDimension;
    String current = _sections.first;
    for (final s in _sections) {
      final box = _keys[s]?.currentContext?.findRenderObject() as RenderBox?;
      if (box == null || !box.attached) continue;
      final top = _offsetInViewport(box);
      if (top != null && top <= viewport * 0.35) current = s;
    }
    _c.setSection(current);
  }

  /// A box's top relative to the preview viewport.
  double? _offsetInViewport(RenderBox box) {
    final vp = _viewport.currentContext?.findRenderObject() as RenderBox?;
    if (vp == null || !vp.attached) return null;
    return box.localToGlobal(Offset.zero, ancestor: vp).dy;
  }

  Future<void> _jumpTo(
    String section,
    String? anchor, {
    bool animate = true,
  }) async {
    final ctx =
        (anchor != null ? inspectKeys[anchor] : _keys[section])?.currentContext;
    if (ctx == null) return;
    _jumping = true;
    _c.setSection(section);
    await Scrollable.ensureVisible(
      ctx,
      alignment: anchor != null ? 0.08 : 0,
      duration: animate
          ? Motion.of(context, const Duration(milliseconds: 700))
          : Duration.zero,
      curve: Motion.ease,
    );
    _jumping = false;
    _syncSection();
  }

  void _openFile(SourceFile f) {
    _c.openFile(f);
    _jumpTo(f.section, null);
  }

  /// Hovering a line outlines its widget; scroll it into view if it's off
  /// screen, so the outline is never invisible.
  void _onController() {
    final id = _c.inspecting;
    if (id == _lastInspected) return;
    _lastInspected = id;
    if (id == null || id == 'page' || _jumping) return;
    final ctx = inspectKeys[id]?.currentContext;
    final box = ctx?.findRenderObject() as RenderBox?;
    if (ctx == null || box == null || !_scroll.hasClients) return;
    final top = _offsetInViewport(box);
    if (top == null) return;
    final viewport = _scroll.position.viewportDimension;
    final visible = top > 40 && top + 40 < viewport;
    if (!visible) {
      Scrollable.ensureVisible(
        ctx,
        alignment: 0.15,
        duration: Motion.of(context, Motion.slow),
        curve: Motion.ease,
      );
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return IdeScope(
      controller: _c,
      child: IdeJump(
        openFile: _openFile,
        jumpTo: (s, [a]) => _jumpTo(s, a),
        child: LayoutBuilder(
          builder: (context, box) => box.maxWidth < Shell.phone
              ? _phone(context)
              : _desktop(context, box.maxWidth),
        ),
      ),
    );
  }

  Widget _themedPage() {
    return _ThemedPage(
      child: Stack(
        children: [
          Positioned.fill(
            child: Scrollbar(
              key: _viewport,
              controller: _scroll,
              child: SingleChildScrollView(
                controller: _scroll,
                child: PortfolioPage(sectionKeys: _keys),
              ),
            ),
          ),
          const Positioned.fill(child: IgnorePointer(child: _ReloadFlash())),
        ],
      ),
    );
  }

  Widget _desktop(BuildContext context, double width) {
    final reading = _c.reading;
    final showTree = width >= Shell.tree;
    final treeW = showTree && !reading ? 236.0 : 0.0;
    final editorTarget = (width * 0.34).clamp(400.0, 580.0);
    final editorW = reading ? 0.0 : editorTarget;
    final d = Motion.of(context, Motion.slow);

    return Scaffold(
      backgroundColor: Ide.bg,
      body: Column(
        children: [
          const TitleBar(),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AnimatedContainer(
                  duration: d,
                  curve: Motion.ease,
                  width: treeW + editorW,
                  child: ClipRect(
                    child: OverflowBox(
                      alignment: Alignment.centerLeft,
                      minWidth: (showTree ? 236.0 : 0) + editorTarget,
                      maxWidth: (showTree ? 236.0 : 0) + editorTarget,
                      child: Column(
                        children: [
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (showTree)
                                  const SizedBox(
                                    width: 236,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        border: Border(
                                          right: BorderSide(color: Ide.line),
                                        ),
                                      ),
                                      child: WidgetTree(),
                                    ),
                                  ),
                                const Expanded(child: Editor()),
                              ],
                            ),
                          ),
                          const SizedBox(height: 176, child: DebugConsole()),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      border: Border(left: BorderSide(color: Ide.line)),
                    ),
                    child: LayoutBuilder(
                      builder: (context, box) => Column(
                        children: [
                          _PreviewBar(
                            size: Size(box.maxWidth, box.maxHeight - 40),
                          ),
                          Expanded(child: _themedPage()),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _phone(BuildContext context) {
    return Scaffold(
      backgroundColor: Ide.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: const BoxDecoration(
                color: Ide.bg,
                border: Border(bottom: BorderSide(color: Ide.line)),
              ),
              child: Row(
                children: [
                  const Mark(size: 28),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      ProfileData.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Txt.display(
                        16,
                        color: Ide.bright,
                        width: 85,
                        tracking: -0.02,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _SourceButton(onTap: () => _showSource(context)),
                ],
              ),
            ),
            Expanded(child: _themedPage()),
          ],
        ),
      ),
    );
  }

  void _showSource(BuildContext context) {
    _c.log(LogKind.info, 'flutter: Viewing ${_c.file.label} on the device.');
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Ide.panel,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.72,
      ),
      builder: (sheetContext) => IdeScope(
        controller: _c,
        child: IdeJump(
          openFile: (f) => _c.openFile(f),
          jumpTo: (s, [a]) {},
          child: const _SourceSheet(),
        ),
      ),
    );
  }
}

/// Animates the page between themes when `theme:` changes.
class _ThemedPage extends StatelessWidget {
  final Widget child;

  const _ThemedPage({required this.child});

  @override
  Widget build(BuildContext context) {
    final c = IdeScope.of(context);
    final target = PageTheme.all[c.value('theme')]!;
    return TweenAnimationBuilder<PageTheme>(
      tween: PageThemeTween(end: target),
      duration: Motion.of(context, const Duration(milliseconds: 520)),
      curve: Motion.ease,
      builder: (context, theme, child) => PageThemeScope(
        theme: theme,
        child: ColoredBox(color: theme.bg, child: child),
      ),
      child: child,
    );
  }
}

/// The blue wash that crosses the page on every hot reload.
class _ReloadFlash extends StatefulWidget {
  const _ReloadFlash();

  @override
  State<_ReloadFlash> createState() => _ReloadFlashState();
}

class _ReloadFlashState extends State<_ReloadFlash>
    with SingleTickerProviderStateMixin {
  late final _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  );
  int? _seen;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reloads = IdeScope.of(context).reloads;
    if (_seen != null && reloads != _seen && !Motion.reduced(context)) {
      _anim.forward(from: 0);
    }
    _seen = reloads;
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _anim,
    builder: (_, _) {
      final v = _anim.isAnimating
          ? 1 - Curves.easeOut.transform(_anim.value)
          : 0.0;
      return ColoredBox(color: Ide.flutter.withValues(alpha: 0.13 * v));
    },
  );
}

/// Browser-ish strip above the preview: URL follows the section on screen.
class _PreviewBar extends StatelessWidget {
  final Size size;

  const _PreviewBar({required this.size});

  @override
  Widget build(BuildContext context) {
    final c = IdeScope.of(context);
    final hash = switch (c.section) {
      'home' => '',
      'afterhours' => '/#after-hours',
      final s => '/#$s',
    };
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: const BoxDecoration(
        color: Ide.panel,
        border: Border(bottom: BorderSide(color: Ide.line)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < 3; i++)
            Container(
              margin: const EdgeInsets.only(right: 6),
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Color(0xFF2A303C),
                shape: BoxShape.circle,
              ),
            ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 26,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: Ide.bg,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                      text: 'damola-nelson.web.app',
                      style: TextStyle(color: Ide.text),
                    ),
                    TextSpan(
                      text: hash,
                      style: const TextStyle(color: Ide.dim),
                    ),
                  ],
                ),
                style: Txt.mono(12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${size.width.round()} × ${size.height.round()}',
            style: Txt.mono(11.5, color: Ide.dim),
          ),
        ],
      ),
    );
  }
}

class _SourceButton extends StatelessWidget {
  final VoidCallback onTap;

  const _SourceButton({required this.onTap});

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: 'View source',
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Ide.line),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Row(
          children: [
            const Icon(Icons.code_rounded, size: 16, color: Ide.text),
            const SizedBox(width: 7),
            Text(
              'Source',
              style: Txt.mono(12.5, color: Ide.text, medium: true),
            ),
          ],
        ),
      ),
    ),
  );
}

class _SourceSheet extends StatelessWidget {
  const _SourceSheet();

  @override
  Widget build(BuildContext context) {
    final c = IdeScope.of(context);
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.72,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF2A303C),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const FileTabs(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 2),
            child: Text(
              'Tap an orange or green value to change it. The page behind updates live.',
              style: Txt.mono(11.5, color: Ide.dim, height: 1.5),
            ),
          ),
          Flexible(child: CodeView(file: c.file, fontSize: 12, compact: true)),
        ],
      ),
    );
  }
}
