import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/portfolio_data.dart';
import 'controller.dart';
import 'editor.dart';
import 'tokens.dart';

Future<void> openLink(String url) =>
    launchUrl(Uri.parse(url), webOnlyWindowName: '_blank');

/// The bundled resume, served next to the app.
const resumeUrl = 'assets/${ProfileData.resumeAssetPath}';

/// The DN mark: Flutter blue, condensed mono initials.
class Mark extends StatelessWidget {
  final double size;

  const Mark({super.key, this.size = 26});

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: Ide.flutter,
      borderRadius: BorderRadius.circular(size * 0.27),
    ),
    child: Text(
      ProfileData.initials,
      style: Txt.display(
        size * 0.42,
        color: Colors.white,
        weight: 600,
        width: 85,
        tracking: -0.02,
      ),
    ),
  );
}

// ── Title bar ─────────────────────────────────────────────────────────────

class TitleBar extends StatelessWidget {
  const TitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    final c = IdeScope.of(context);
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: const BoxDecoration(
        color: Ide.bg,
        border: Border(bottom: BorderSide(color: Ide.line)),
      ),
      child: Row(
        children: [
          const Mark(),
          const SizedBox(width: 12),
          Text(
            'damola_nelson',
            style: Txt.mono(12.5, color: Ide.bright, medium: true),
          ),
          const SizedBox(width: 12),
          Text('⎇ main', style: Txt.mono(12, color: Ide.dim)),
          const Spacer(),
          const _DeviceChip(),
          const SizedBox(width: 6),
          _IconAction(
            icon: Icons.bolt_rounded,
            color: Ide.warn,
            tooltip: 'Hot reload (r)',
            onTap: () => c.hotReload(),
          ),
          _IconAction(
            icon: Icons.restart_alt_rounded,
            color: Ide.live,
            tooltip: 'Hot restart (R)',
            onTap: c.hotRestart,
          ),
          const Spacer(),
          _TextAction(label: 'resume.pdf', onTap: () => openLink(resumeUrl)),
          const SizedBox(width: 18),
          _ReadToggle(on: c.reading, onTap: c.toggleReading),
        ],
      ),
    );
  }
}

class _DeviceChip extends StatelessWidget {
  const _DeviceChip();

  @override
  Widget build(BuildContext context) => Container(
    height: 30,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: Ide.panel,
      border: Border.all(color: Ide.line),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        const _LiveDot(),
        const SizedBox(width: 9),
        Text('Chrome (web)', style: Txt.mono(12, color: Ide.text)),
        const SizedBox(width: 8),
        const Icon(Icons.expand_more_rounded, size: 15, color: Ide.dim),
      ],
    ),
  );
}

class _LiveDot extends StatelessWidget {
  const _LiveDot();

  @override
  Widget build(BuildContext context) => Container(
    width: 7,
    height: 7,
    decoration: BoxDecoration(
      color: Ide.live,
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(color: Ide.live.withValues(alpha: 0.25), spreadRadius: 3),
      ],
    ),
  );
}

class _IconAction extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _IconAction({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  State<_IconAction> createState() => _IconActionState();
}

class _IconActionState extends State<_IconAction> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: widget.tooltip,
    waitDuration: const Duration(milliseconds: 400),
    child: MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: Motion.fast,
          width: 32,
          height: 30,
          decoration: BoxDecoration(
            color: _hover ? Ide.raised : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(widget.icon, size: 18, color: widget.color),
        ),
      ),
    ),
  );
}

class _TextAction extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _TextAction({required this.label, required this.onTap});

  @override
  State<_TextAction> createState() => _TextActionState();
}

class _TextActionState extends State<_TextAction> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: SystemMouseCursors.click,
    onEnter: (_) => setState(() => _hover = true),
    onExit: (_) => setState(() => _hover = false),
    child: GestureDetector(
      onTap: widget.onTap,
      child: Row(
        children: [
          Icon(
            Icons.description_outlined,
            size: 14,
            color: _hover ? Ide.bright : Ide.dim,
          ),
          const SizedBox(width: 6),
          Text(
            widget.label,
            style: Txt.mono(12.5, color: _hover ? Ide.bright : Ide.dim),
          ),
        ],
      ),
    ),
  );
}

class _ReadToggle extends StatelessWidget {
  final bool on;
  final VoidCallback onTap;

  const _ReadToggle({required this.on, required this.onTap});

  @override
  Widget build(BuildContext context) => Semantics(
    toggled: on,
    label: 'Read normally',
    child: MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          children: [
            Text(
              'Read normally',
              style: Txt.mono(12.5, color: Ide.text, medium: true),
            ),
            const SizedBox(width: 10),
            AnimatedContainer(
              duration: Motion.medium,
              curve: Motion.ease,
              width: 32,
              height: 18,
              padding: const EdgeInsets.all(2),
              alignment: on ? Alignment.centerRight : Alignment.centerLeft,
              decoration: BoxDecoration(
                color: on ? Ide.flutter : const Color(0xFF2A303C),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Container(
                width: 14,
                height: 14,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// ── Widget tree ───────────────────────────────────────────────────────────

class _Node {
  final String label;
  final int depth;
  final String section;
  final String? anchor;

  const _Node(this.label, this.depth, this.section, [this.anchor]);
}

const _nodes = [
  _Node('DamolaApp', 0, 'home'),
  _Node('Home', 1, 'home'),
  _Node('Work', 1, 'work'),
  _Node('FieldAgentApp', 2, 'work', 'project-field'),
  _Node('LoanApp', 2, 'work', 'project-loan'),
  _Node('Ajarra', 2, 'work', 'project-ajarra'),
  _Node('Career', 1, 'career'),
  _Node('Writing', 1, 'writing'),
  _Node('Hashnode', 2, 'writing', 'posts'),
  _Node('Medium', 2, 'writing', 'essays'),
  _Node('AfterHours', 1, 'afterhours'),
  _Node('Contact', 1, 'contact'),
];

class WidgetTree extends StatelessWidget {
  const WidgetTree({super.key});

  @override
  Widget build(BuildContext context) {
    final c = IdeScope.of(context);
    return Container(
      color: Ide.panel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Row(
              children: [
                Text('WIDGET TREE', style: Txt.label(Ide.dim, size: 11)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'click to jump',
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Txt.mono(11, color: Ide.gutter),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                for (final n in _nodes)
                  _TreeRow(
                    node: n,
                    selected: n.anchor == null
                        ? n.section == c.section && n.depth == 1
                        : false,
                    root: n.depth == 0,
                  ),
              ],
            ),
          ),
          const _Properties(),
        ],
      ),
    );
  }
}

class _TreeRow extends StatefulWidget {
  final _Node node;
  final bool selected;
  final bool root;

  const _TreeRow({
    required this.node,
    required this.selected,
    required this.root,
  });

  @override
  State<_TreeRow> createState() => _TreeRowState();
}

class _TreeRowState extends State<_TreeRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final n = widget.node;
    final on = widget.selected;
    final leaf = n.anchor != null;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() => _hover = true);
        if (n.anchor != null) IdeScope.read(context).inspect(n.anchor);
      },
      onExit: (_) {
        setState(() => _hover = false);
        final c = IdeScope.read(context);
        if (c.inspecting == n.anchor) c.inspect(null);
      },
      child: GestureDetector(
        onTap: () => IdeJump.of(context)?.jumpTo(n.section, n.anchor),
        child: AnimatedContainer(
          duration: Motion.fast,
          height: 30,
          color: on
              ? Ide.flutterSoft
              : (_hover ? Ide.hover : Colors.transparent),
          padding: EdgeInsets.only(left: 14.0 + n.depth * 16, right: 14),
          child: Row(
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: on ? Ide.flutter : null,
                  borderRadius: BorderRadius.circular(leaf ? 2 : 9),
                  border: Border.all(
                    color: on ? Ide.flutter : (leaf ? Ide.dim : Ide.type),
                    width: 1.5,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  n.label,
                  style: Txt.mono(
                    13,
                    color: on || _hover ? Ide.bright : Ide.text,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (widget.root)
                Text('root', style: Txt.mono(11, color: Ide.gutter)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Properties extends StatelessWidget {
  const _Properties();

  @override
  Widget build(BuildContext context) {
    final c = IdeScope.of(context);
    final props = switch (c.section) {
      'work' => [
        ('projects', '3'),
        ('liveDemos', '6'),
        ('airplaneMode', c.value('airplane')),
      ],
      'career' => [
        ('commits', '${CareerData.roles.length + 1}'),
        ('since', '2024'),
        ('view', c.flag('oneline') ? 'oneline' : 'stat'),
      ],
      'writing' => [
        ('posts', '27'),
        ('essays', '3'),
        ('sort', c.value('sort')),
      ],
      'afterhours' => [
        ('learning', c.value('learning')),
        ('playing', c.value('playing')),
        ('club', 'chelsea'),
      ],
      'contact' => [('replies', 'within a day'), ('timezone', 'WAT, UTC+1')],
      _ => [
        ('status', c.value('status')),
        ('theme', c.value('theme')),
        ('basedIn', c.value('basedIn')),
      ],
    };
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Ide.line)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('PROPERTIES', style: Txt.label(Ide.dim, size: 11)),
          const SizedBox(height: 10),
          for (final (k, v) in props)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: k,
                      style: const TextStyle(color: Ide.prop),
                    ),
                    const TextSpan(text: ': '),
                    TextSpan(
                      text: v,
                      style: const TextStyle(color: Ide.text),
                    ),
                  ],
                ),
                style: Txt.mono(12, color: Ide.dim, height: 1.6),
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }
}

// ── Console ───────────────────────────────────────────────────────────────

class DebugConsole extends StatefulWidget {
  const DebugConsole({super.key});

  @override
  State<DebugConsole> createState() => _DebugConsoleState();
}

class _DebugConsoleState extends State<DebugConsole> {
  final _scroll = ScrollController();
  int _seen = 0;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = IdeScope.of(context);
    if (c.logs.length != _seen) {
      _seen = c.logs.length;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) {
          _scroll.animateTo(
            _scroll.position.maxScrollExtent,
            duration: Motion.medium,
            curve: Motion.ease,
          );
        }
      });
    }
    return Container(
      decoration: const BoxDecoration(
        color: Ide.panel,
        border: Border(top: BorderSide(color: Ide.line)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Ide.line)),
            ),
            child: Row(
              children: [
                _ConsoleTab(
                  label: 'DEBUG CONSOLE',
                  on: c.consoleTab == 'debug',
                  onTap: () => c.showConsole('debug'),
                ),
                _ConsoleTab(
                  label: 'TERMINAL',
                  on: c.consoleTab == 'terminal',
                  onTap: () => c.showConsole('terminal'),
                ),
                const Spacer(),
                // Key hints go first when the panel is narrow.
                Flexible(
                  child: ClipRect(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      physics: const NeverScrollableScrollPhysics(),
                      child: Row(
                        children: [
                          const _Key('r'),
                          Text(
                            ' hot reload   ',
                            style: Txt.mono(11.5, color: Ide.dim),
                          ),
                          const _Key('R'),
                          Text(
                            ' restart',
                            style: Txt.mono(11.5, color: Ide.dim),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: c.consoleTab == 'debug'
                ? ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                    itemCount: c.logs.length,
                    itemBuilder: (_, i) => _LogText(line: c.logs[i]),
                  )
                : const _Terminal(),
          ),
        ],
      ),
    );
  }
}

class _ConsoleTab extends StatelessWidget {
  final String label;
  final bool on;
  final VoidCallback onTap;

  const _ConsoleTab({
    required this.label,
    required this.on,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: SystemMouseCursors.click,
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: on ? Ide.flutter : Colors.transparent,
              width: 1.5,
            ),
          ),
        ),
        child: Text(
          label,
          style: Txt.label(on ? Ide.bright : Ide.dim, size: 11),
        ),
      ),
    ),
  );
}

class _Key extends StatelessWidget {
  final String k;

  const _Key(this.k);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
    decoration: BoxDecoration(
      border: Border.all(color: const Color(0xFF2A303C)),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(k, style: Txt.mono(11, color: Ide.text, medium: true)),
  );
}

class _LogText extends StatelessWidget {
  final LogLine line;

  const _LogText({required this.line});

  @override
  Widget build(BuildContext context) {
    final color = switch (line.kind) {
      LogKind.plain => Ide.dim,
      LogKind.ok => Ide.ok,
      LogKind.info => Ide.text,
      LogKind.warn => Ide.warn,
    };
    return Text(line.text, style: Txt.mono(12.5, color: color, height: 1.75));
  }
}

class _Terminal extends StatelessWidget {
  const _Terminal();

  @override
  Widget build(BuildContext context) {
    final c = IdeScope.read(context);
    final commands = <(String, VoidCallback)>[
      (
        'copy email',
        () async {
          await Clipboard.setData(const ClipboardData(text: ProfileData.email));
          c.log(LogKind.ok, 'Copied ${ProfileData.email} to the clipboard.');
          c.showConsole('debug');
        },
      ),
      (
        'mail ${ProfileData.email}',
        () => openLink('mailto:${ProfileData.email}'),
      ),
      ('open resume.pdf', () => openLink(resumeUrl)),
      (
        'open github.com/${ProfileData.githubHandle}',
        () => openLink(ProfileData.githubUrl),
      ),
      ('open linkedin', () => openLink(ProfileData.linkedinUrl)),
      ('open daily-flutters.hashnode.dev', () => openLink(ProfileData.blogUrl)),
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      children: [
        for (final (label, run) in commands) _Command(label: label, onTap: run),
      ],
    );
  }
}

class _Command extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _Command({required this.label, required this.onTap});

  @override
  State<_Command> createState() => _CommandState();
}

class _CommandState extends State<_Command> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: SystemMouseCursors.click,
    onEnter: (_) => setState(() => _hover = true),
    onExit: (_) => setState(() => _hover = false),
    child: GestureDetector(
      onTap: widget.onTap,
      child: Text.rich(
        TextSpan(
          children: [
            const TextSpan(
              text: 'damola@lagos',
              style: TextStyle(color: Ide.live),
            ),
            const TextSpan(text: ' ~ \$ '),
            TextSpan(
              text: widget.label,
              style: TextStyle(
                color: Ide.type,
                decoration: _hover ? TextDecoration.underline : null,
                decorationColor: Ide.type,
              ),
            ),
          ],
        ),
        style: Txt.mono(12.5, color: Ide.dim, height: 1.85),
      ),
    ),
  );
}
