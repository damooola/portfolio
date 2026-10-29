import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/portfolio_data.dart';
import '../demos/chat_demo.dart';
import '../demos/face_check_demo.dart';
import '../demos/loan_fix_demo.dart';
import '../demos/offline_sync_demo.dart';
import '../demos/planner_demo.dart';
import '../demos/route_map_demo.dart';
import '../services/chess.dart';
import '../services/football.dart';
import '../widgets/chess_board.dart';
import '../widgets/demo_phone.dart';
import '../widgets/writing_section.dart' show Article, WritingSection;
import 'chrome.dart';
import 'content.dart';
import 'controller.dart';
import 'editor.dart';
import 'page_parts.dart';
import 'tokens.dart';

/// The portfolio itself: what main.dart "builds". Each section carries a
/// key so the shell can scroll to it and track which one is on screen.
class PortfolioPage extends StatelessWidget {
  final Map<String, GlobalKey> sectionKeys;

  const PortfolioPage({super.key, required this.sectionKeys});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final w = box.maxWidth;
        final pad = w < 600 ? 20.0 : (w < 900 ? 40.0 : 64.0);
        Widget section(String id, Widget child, {bool first = false}) =>
            Container(
              key: sectionKeys[id],
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                pad,
                first ? (w < 600 ? 36 : 72) : 72,
                pad,
                72,
              ),
              decoration: first
                  ? null
                  : BoxDecoration(
                      border: Border(
                        top: BorderSide(color: PageThemeScope.of(context).line),
                      ),
                    ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 980),
                  child: child,
                ),
              ),
            );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            section('home', _Hero(width: w - pad * 2), first: true),
            section('work', _Work(width: math.min(980, w - pad * 2))),
            section('career', const _Career()),
            section('writing', _Writing(width: w - pad * 2)),
            section(
              'afterhours',
              _AfterHours(width: math.min(980, w - pad * 2)),
            ),
            section('contact', const _Contact()),
          ],
        );
      },
    );
  }
}

// ── Hero ──────────────────────────────────────────────────────────────────

class _Hero extends StatelessWidget {
  final double width;

  const _Hero({required this.width});

  @override
  Widget build(BuildContext context) {
    final c = IdeScope.of(context);
    final t = PageThemeScope.of(context);
    final nameSize = (width * 0.105).clamp(40.0, 104.0);
    final shipping = c.value('status') == 'shipping';
    final where = c.value('basedIn');
    final handle = c.value('name') == 'damooola';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Inspectable(
          id: 'status',
          label: 'StatusChip(status)',
          child: Swap(
            id: '$shipping$where',
            child: _StatusChip(
              busy: shipping,
              text: shipping
                  ? 'Heads down, shipping · $where'
                  : width < 480
                  ? 'Open to Flutter roles · $where'
                  : 'Open to Flutter roles · full time · contract · $where',
            ),
          ),
        ),
        SizedBox(height: nameSize * 0.32),
        Inspectable(
          id: 'name',
          label: 'Text(name)',
          child: Swap(
            id: handle,
            child: Text.rich(
              handle
                  ? TextSpan(
                      children: [
                        TextSpan(
                          text: '@',
                          style: TextStyle(color: t.accent),
                        ),
                        const TextSpan(text: 'damooola'),
                      ],
                    )
                  : TextSpan(
                      children: [
                        const TextSpan(text: 'Damola '),
                        TextSpan(
                          text: 'Nelson',
                          style: TextStyle(color: t.accent),
                        ),
                      ],
                    ),
              style: Txt.display(nameSize, color: t.fg, height: 0.98),
            ),
          ),
        ),
        const SizedBox(height: 26),
        Inspectable(
          id: 'role',
          label: 'Text(role)',
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Swap(
              id: '${c.value('role')}${c.value('specialty')}',
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${c.value('role')}. ',
                      style: Txt.sans(
                        21,
                        color: t.fg,
                        weight: 600,
                        height: 1.45,
                      ),
                    ),
                    TextSpan(
                      text: IdeContent.specialties[c.value('specialty')],
                    ),
                  ],
                ),
                style: Txt.sans(21, color: t.muted, height: 1.45),
              ),
            ),
          ),
        ),
        const SizedBox(height: 22),
        Inspectable(
          id: 'platforms',
          label: 'Wrap(ships)',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('Ships to', style: Txt.mono(12.5, color: t.muted)),
              const Chip2('Android'),
              const Chip2('iOS'),
              AnimatedSize(
                duration: Motion.of(context, Motion.medium),
                curve: Motion.ease,
                child: c.flag('web')
                    ? const Chip2('Web')
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        Inspectable(
          id: 'stats',
          label: 'GridView(kResumeStats)',
          child: _Stats(columns: width < 520 ? 2 : 3),
        ),
        const SizedBox(height: 32),
        Inspectable(
          id: 'cta',
          label: 'Row(actions)',
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              PageButton(
                label: 'See the work',
                primary: true,
                icon: Icons.arrow_downward_rounded,
                onTap: () => IdeJump.of(context)?.jumpTo('work'),
              ),
              PageButton(
                label: 'Resume',
                icon: Icons.description_outlined,
                onTap: () => openLink(resumeUrl),
              ),
              PageButton(
                label: 'Email',
                icon: Icons.mail_outline_rounded,
                onTap: () => openLink('mailto:${ProfileData.email}'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final bool busy;
  final String text;

  const _StatusChip({required this.busy, required this.text});

  @override
  Widget build(BuildContext context) {
    final t = PageThemeScope.of(context);
    final dot = busy ? const Color(0xFFD9921F) : t.ok;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 14, 8),
      decoration: BoxDecoration(
        color: t.surface,
        border: Border.all(color: t.line),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: _Pulse(color: dot),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              text,
              style: Txt.mono(12.5, color: t.muted, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}

/// A status dot that breathes.
class _Pulse extends StatefulWidget {
  final Color color;

  const _Pulse({required this.color});

  @override
  State<_Pulse> createState() => _PulseState();
}

class _PulseState extends State<_Pulse> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (Motion.reduced(context)) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    builder: (_, _) => Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: widget.color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: widget.color.withValues(alpha: 0.28 * (1 - _c.value)),
            spreadRadius: 2 + 5 * _c.value,
          ),
        ],
      ),
    ),
  );
}

class _Stats extends StatelessWidget {
  final int columns;

  const _Stats({required this.columns});

  @override
  Widget build(BuildContext context) {
    final t = PageThemeScope.of(context);
    final stats = TrophiesData.trophies;
    final rows = (stats.length / columns).ceil();
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 680),
      child: Container(
        decoration: BoxDecoration(
          color: t.line,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: t.line),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            for (var r = 0; r < rows; r++)
              Padding(
                padding: EdgeInsets.only(top: r == 0 ? 0 : 1),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var col = 0; col < columns; col++) ...[
                        if (col > 0) const SizedBox(width: 1),
                        Expanded(
                          child: r * columns + col < stats.length
                              ? Tooltip(
                                  message: stats[r * columns + col].detail,
                                  waitDuration: const Duration(
                                    milliseconds: 300,
                                  ),
                                  child: Container(
                                    color: t.surface,
                                    padding: const EdgeInsets.fromLTRB(
                                      16,
                                      16,
                                      12,
                                      14,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          stats[r * columns + col].value,
                                          style: Txt.display(
                                            28,
                                            color: t.gold,
                                            width: 80,
                                            tracking: -0.03,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          stats[r * columns + col].label,
                                          style: Txt.mono(
                                            11.5,
                                            color: t.muted,
                                            height: 1.35,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : ColoredBox(color: t.surface),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Work ──────────────────────────────────────────────────────────────────

class _Work extends StatelessWidget {
  final double width;

  const _Work({required this.width});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Kicker('01 · Work'),
        const SectionTitle('Three apps, rebuilt as small working demos.'),
        const Lede(
          'The real apps belong to the companies I built them for, so these are '
          'versions I rebuilt from scratch on mock data. They’re running live. '
          'Poke them.',
        ),
        const SizedBox(height: 20),
        for (var i = 0; i < IdeContent.projects.length; i++)
          _ProjectRow(
            index: i,
            project: IdeContent.projects[i],
            sideBySide: width >= 700,
            last: i == IdeContent.projects.length - 1,
          ),
      ],
    );
  }
}

class _ProjectRow extends StatelessWidget {
  final int index;
  final IdeProject project;
  final bool sideBySide;
  final bool last;

  const _ProjectRow({
    required this.index,
    required this.project,
    required this.sideBySide,
    required this.last,
  });

  String? get _demoKey => switch (project.id) {
    'loan' => 'loanDemo',
    'ajarra' => 'ajarraDemo',
    _ => null,
  };

  @override
  Widget build(BuildContext context) {
    final c = IdeScope.of(context);
    final t = PageThemeScope.of(context);
    final key = _demoKey;
    final demo = key == null
        ? project.demos.first
        : Demo.values.byName(c.value(key));

    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '0${index + 1}  ·  ${project.client}  ·  ${project.years}',
          style: Txt.mono(12, color: t.muted),
        ),
        const SizedBox(height: 12),
        Text(
          project.name,
          style: Txt.display(
            30,
            color: t.fg,
            width: 80,
            height: 1.1,
            tracking: -0.035,
          ),
        ),
        const SizedBox(height: 14),
        Text(project.summary, style: Txt.sans(16, color: t.muted)),
        const SizedBox(height: 12),
        Text(project.builtForReal, style: Txt.sans(16, color: t.fg)),
        const SizedBox(height: 18),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [for (final s in project.stack) Chip2(s, accent: true)],
        ),
        const SizedBox(height: 22),
        if (project.demos.length > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _DemoTabs(
              demos: project.demos,
              selected: demo,
              onSelect: (d) => IdeScope.read(context).set(key!, d.name),
            ),
          ),
        _TryHint(
          demo: demo,
          offline: project.id == 'field' && c.flag('airplane'),
        ),
      ],
    );

    final phone = Inspectable(
      id: 'demo-${project.id}',
      label: 'DemoPhone(Demo.${demo.name})',
      child: _Device(project: project, demo: demo, compact: !sideBySide),
    );

    return Inspectable(
      id: 'project-${project.id}',
      label: '${project.widget}()',
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 40),
        decoration: BoxDecoration(
          border: last ? null : Border(bottom: BorderSide(color: t.line)),
        ),
        child: sideBySide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: text),
                  const SizedBox(width: 48),
                  phone,
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  text,
                  const SizedBox(height: 28),
                  Center(child: phone),
                ],
              ),
      ),
    );
  }
}

class _DemoTabs extends StatelessWidget {
  final List<Demo> demos;
  final Demo selected;
  final ValueChanged<Demo> onSelect;

  const _DemoTabs({
    required this.demos,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final t = PageThemeScope.of(context);
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: t.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final d in demos)
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => onSelect(d),
                child: AnimatedContainer(
                  duration: Motion.of(context, Motion.fast),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: d == selected ? t.fg : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    d.label,
                    style: Txt.mono(
                      12.5,
                      color: d == selected ? t.bg : t.muted,
                      medium: true,
                      height: 1,
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

class _TryHint extends StatelessWidget {
  final Demo demo;
  final bool offline;

  const _TryHint({required this.demo, required this.offline});

  @override
  Widget build(BuildContext context) {
    final t = PageThemeScope.of(context);
    return Swap(
      id: '${demo.name}$offline',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Icon(
              offline
                  ? Icons.airplanemode_active_rounded
                  : Icons.touch_app_outlined,
              size: 15,
              color: offline ? const Color(0xFFD9921F) : t.accent,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              offline
                  ? 'The phone is offline because of airplaneMode: true in work.dart. Add a customer, then flip it back.'
                  : demo.hint,
              style: Txt.sans(14, color: t.muted, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

/// A live Flutter demo in a phone frame, scaled to fit the column.
class _Device extends StatelessWidget {
  final IdeProject project;
  final Demo demo;
  final bool compact;

  const _Device({
    required this.project,
    required this.demo,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    final c = IdeScope.of(context);
    final screen = switch (demo) {
      Demo.offlineSync => OfflineSyncDemo(airplane: c.airplane),
      Demo.loanFix => const LoanFixDemo(),
      Demo.faceCheck => const FaceCheckDemo(),
      Demo.calendar => const PlannerDemo(),
      Demo.chat => const ChatDemo(),
      Demo.routeMap => const RouteMapDemo(),
    };
    // The framed phone (plus the charger strip under it) sizes itself;
    // FittedBox scales that natural size down to the column.
    const frameW = DemoPhone.screenWidth + 24;
    const frameH = DemoPhone.screenHeight + 24 + 70;
    final phone = DemoPhone(
      key: ValueKey('${project.id}-phone'),
      screenId: demo,
      child: KeyedSubtree(key: ValueKey(demo), child: screen),
    );

    // On real phones DemoPhone renders bare (no frame) at full width.
    if (MediaQuery.sizeOf(context).width < 600) {
      return ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: phone,
      );
    }
    final w = compact ? 300.0 : 284.0;
    return SizedBox(
      width: w,
      height: w * frameH / frameW,
      child: FittedBox(alignment: Alignment.topCenter, child: phone),
    );
  }
}

// ── Career ────────────────────────────────────────────────────────────────

class _Career extends StatelessWidget {
  const _Career();

  @override
  Widget build(BuildContext context) {
    final c = IdeScope.of(context);
    final t = PageThemeScope.of(context);
    final oneline = c.flag('oneline');
    final roles = IdeContent.roles;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Kicker('02 · Career'),
        Inspectable(
          id: 'career',
          label: 'GitLog(career)',
          child: Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'git log ',
                    style: TextStyle(color: t.fg),
                  ),
                  TextSpan(
                    text: '--career',
                    style: TextStyle(color: t.accent),
                  ),
                ],
              ),
              style: Txt.display(38, height: 1.08, tracking: -0.04),
            ),
          ),
        ),
        const Lede(
          'Every job so far, newest first. Titles and dates match my LinkedIn.',
        ),
        const SizedBox(height: 28),
        for (var i = 0; i < roles.length; i++)
          _Commit(
            id: 'role-$i',
            hash: IdeContent.hashes[i],
            head: i == 0 ? 'HEAD → main' : null,
            title: roles[i].title,
            company: roles[i].product == null
                ? roles[i].company
                : '${roles[i].company} · ${roles[i].product}',
            when: '${roles[i].start} — ${roles[i].end}  ·  ${roles[i].place}',
            body: roles[i].summary,
            tags: roles[i].tags,
            oneline: oneline,
          ),
        _Commit(
          id: 'role-edu',
          hash: IdeContent.hashes.last,
          head: 'tag: v1.0',
          title: 'BEng Electrical & Electronics Engineering',
          company: 'Obafemi Awolowo University',
          when: '2020 — 2025  ·  Ile-Ife',
          body: null,
          tags: const [],
          oneline: oneline,
          last: true,
        ),
      ],
    );
  }
}

class _Commit extends StatelessWidget {
  final String id;
  final String hash;
  final String? head;
  final String title;
  final String company;
  final String when;
  final String? body;
  final List<String> tags;
  final bool oneline;
  final bool last;

  const _Commit({
    required this.id,
    required this.hash,
    required this.head,
    required this.title,
    required this.company,
    required this.when,
    required this.body,
    required this.tags,
    required this.oneline,
    this.last = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = PageThemeScope.of(context);
    final current = head == 'HEAD → main';
    return Inspectable(
      id: id,
      label: 'Commit($hash)',
      child: Stack(
        children: [
          // The commit graph: a line through every commit but the first one.
          if (!last)
            Positioned(
              left: 10.3,
              top: 17,
              bottom: 0,
              child: Container(width: 1.4, color: t.line),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 5.5, right: 5.5),
                child: Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: current ? t.accent : t.bg,
                    border: Border.all(
                      color: current ? t.accent : t.muted,
                      width: 1.6,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: oneline ? 14 : 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 10,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            hash,
                            style: Txt.mono(13, color: t.gold, medium: true),
                          ),
                          if (head != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: current ? t.accentSoft : t.surface,
                                borderRadius: BorderRadius.circular(5),
                                border: current
                                    ? null
                                    : Border.all(color: t.line),
                              ),
                              child: Text(
                                head!,
                                style: Txt.mono(
                                  11,
                                  color: current ? t.accent : t.muted,
                                  medium: true,
                                  height: 1,
                                ),
                              ),
                            ),
                          Text(
                            title,
                            style: Txt.sans(
                              16.5,
                              color: t.fg,
                              weight: 600,
                              height: 1.3,
                            ),
                          ),
                          Text(
                            '@ $company',
                            style: Txt.sans(16.5, color: t.accent, height: 1.3),
                          ),
                        ],
                      ),
                      AnimatedSize(
                        duration: Motion.of(context, Motion.medium),
                        curve: Motion.ease,
                        alignment: Alignment.topLeft,
                        child: oneline
                            ? const SizedBox(width: double.infinity)
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 6),
                                  Text(
                                    when,
                                    style: Txt.mono(12, color: t.muted),
                                  ),
                                  if (body != null) ...[
                                    const SizedBox(height: 10),
                                    ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxWidth: 640,
                                      ),
                                      child: Text(
                                        body!,
                                        style: Txt.sans(15.5, color: t.muted),
                                      ),
                                    ),
                                  ],
                                  if (tags.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      children: [
                                        for (final s in tags) Chip2(s),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Writing ───────────────────────────────────────────────────────────────

class _Writing extends StatefulWidget {
  final double width;

  const _Writing({required this.width});

  @override
  State<_Writing> createState() => _WritingState();
}

class _WritingState extends State<_Writing> {
  late final Future<List<Article>> _articles = Article.load();

  static const _months = [
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

  static String _date(String iso) {
    final d = DateTime.tryParse(iso);
    return d == null ? iso : '${_months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final c = IdeScope.of(context);
    final cardW = math.min(300.0, widget.width * 0.82);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Kicker('03 · Writing'),
        const SectionTitle('Notes from the desk.'),
        const Lede(
          'Things I figured out the hard way, written down so you don’t have to.',
        ),
        _RowLabel(
          title: 'On the record',
          note: 'Daily Flutters on Hashnode · Flutter, mostly',
        ),
        Inspectable(
          id: 'posts',
          label: 'ListView(posts)',
          child: FutureBuilder(
            future: _articles,
            builder: (context, snap) {
              final all = snap.data ?? const <Article>[];
              final posts = c.value('sort') == 'newest'
                  ? ([...all]..sort((a, b) => b.date.compareTo(a.date)))
                        .take(6)
                        .toList()
                  : WritingSection.pick(all);
              if (posts.isEmpty) return const SizedBox(height: 236);
              return Swap(
                id: c.value('sort'),
                child: SwipeRow(
                  height: 236,
                  itemWidth: cardW,
                  count: posts.length,
                  builder: (_, i) =>
                      _PostCard(article: posts[i], date: _date(posts[i].date)),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 22),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            PageButton(
              label: 'All posts on Daily Flutters',
              primary: true,
              icon: Icons.north_east_rounded,
              onTap: () => openLink(ProfileData.blogUrl),
            ),
            PageButton(
              label: 'Coder Legion',
              icon: Icons.north_east_rounded,
              onTap: () =>
                  openLink('https://coderlegion.com/user/damolanelson'),
            ),
          ],
        ),
        _RowLabel(
          title: 'Off the clock',
          note: 'Personal essays on Medium · not about code at all',
        ),
        Inspectable(
          id: 'essays',
          label: 'ListView(essays)',
          child: SwipeRow(
            height: 452,
            itemWidth: 206,
            gap: 26,
            count: PersonalPostsData.posts.length,
            builder: (_, i) => _EssayPhone(
              post: PersonalPostsData.posts[i],
              tilt: i.isEven ? -2.0 : 1.6,
            ),
          ),
        ),
      ],
    );
  }
}

class _RowLabel extends StatelessWidget {
  final String title;
  final String note;

  const _RowLabel({required this.title, required this.note});

  @override
  Widget build(BuildContext context) {
    final t = PageThemeScope.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 44, bottom: 16),
      child: Wrap(
        spacing: 12,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.end,
        children: [
          Text(
            title,
            style: Txt.display(19, color: t.fg, width: 80, tracking: -0.02),
          ),
          Text(note, style: Txt.mono(12, color: t.muted)),
        ],
      ),
    );
  }
}

class _PostCard extends StatefulWidget {
  final Article article;
  final String date;

  const _PostCard({required this.article, required this.date});

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final t = PageThemeScope.of(context);
    final a = widget.article;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () => openLink(a.url),
        child: AnimatedContainer(
          duration: Motion.of(context, Motion.fast),
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
          decoration: BoxDecoration(
            color: t.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _hover ? t.accent : t.line,
              width: _hover ? 1.4 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      [a.platform, ...a.alsoOn].join(' + ').toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Txt.label(t.muted, size: 10.5),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.date.toUpperCase(),
                    style: Txt.label(t.muted, size: 10.5),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                a.title,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Txt.sans(17, color: t.fg, weight: 600, height: 1.3),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    a.snippet,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Txt.sans(13.5, color: t.muted, height: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    '${a.readMinutes} MIN READ',
                    style: Txt.label(t.muted, size: 10.5),
                  ),
                  const Spacer(),
                  AnimatedSlide(
                    duration: Motion.of(context, Motion.fast),
                    offset: Offset(_hover ? 0.25 : 0, 0),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 17,
                      color: _hover ? t.accent : t.muted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EssayPhone extends StatefulWidget {
  final PersonalPost post;
  final double tilt;

  const _EssayPhone({required this.post, required this.tilt});

  @override
  State<_EssayPhone> createState() => _EssayPhoneState();
}

class _EssayPhoneState extends State<_EssayPhone> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final t = PageThemeScope.of(context);
    final p = widget.post;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () => openLink(p.url),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            AnimatedRotation(
              duration: Motion.of(context, Motion.medium),
              curve: Motion.ease,
              turns: _hover ? 0 : widget.tilt / 360,
              child: AnimatedSlide(
                duration: Motion.of(context, Motion.medium),
                curve: Motion.ease,
                offset: Offset(0, _hover ? -0.012 : 0),
                child: Container(
                  height: 352,
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D0F14),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                      width: 1.4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: _hover ? 0.32 : 0.22,
                        ),
                        blurRadius: _hover ? 40 : 28,
                        offset: Offset(0, _hover ? 22 : 16),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Image.asset(
                      p.image,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      width: double.infinity,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              p.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Txt.sans(15, color: t.fg, weight: 600, height: 1.3),
            ),
            const SizedBox(height: 4),
            Text(
              '${p.date} · ${p.readMinutes} min',
              style: Txt.mono(11.5, color: t.muted),
            ),
          ],
        ),
      ),
    );
  }
}

// ── After hours ───────────────────────────────────────────────────────────

class _AfterHours extends StatelessWidget {
  final double width;

  const _AfterHours({required this.width});

  @override
  Widget build(BuildContext context) {
    final two = width >= 640;
    const tiles = [_LearningTile(), _ChessTile(), _MusicTile(), _ClubTile()];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Kicker('04 · After hours'),
        const SectionTitle('When the laptop closes.'),
        const Lede(
          'What I’m learning, my chess form, what’s playing and how Chelsea are doing. All live.',
        ),
        const SizedBox(height: 30),
        if (two)
          Column(
            children: [
              for (var r = 0; r < 2; r++)
                Padding(
                  padding: EdgeInsets.only(top: r == 0 ? 0 : 14),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: tiles[r * 2]),
                        const SizedBox(width: 14),
                        Expanded(child: tiles[r * 2 + 1]),
                      ],
                    ),
                  ),
                ),
            ],
          )
        else
          Column(
            children: [
              for (var i = 0; i < tiles.length; i++) ...[
                if (i > 0) const SizedBox(height: 12),
                tiles[i],
              ],
            ],
          ),
      ],
    );
  }
}

/// Shared tile chrome: label row, then content. Tapping runs [onTap].
class _Tile extends StatefulWidget {
  final String id;
  final String widgetLabel;
  final String label;
  final Widget? badge;
  final Widget child;
  final VoidCallback? onTap;

  const _Tile({
    required this.id,
    required this.widgetLabel,
    required this.label,
    required this.child,
    this.badge,
    this.onTap,
  });

  @override
  State<_Tile> createState() => _TileState();
}

class _TileState extends State<_Tile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final t = PageThemeScope.of(context);
    return Inspectable(
      id: widget.id,
      label: widget.widgetLabel,
      child: MouseRegion(
        cursor: widget.onTap == null
            ? SystemMouseCursors.basic
            : SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: Motion.of(context, Motion.fast),
            constraints: const BoxConstraints(minHeight: 176),
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
            decoration: BoxDecoration(
              color: t.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: _hover && widget.onTap != null
                    ? t.muted.withValues(alpha: 0.45)
                    : t.line,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(widget.label, style: Txt.label(t.muted, size: 11)),
                    const Spacer(),
                    ?widget.badge,
                  ],
                ),
                const SizedBox(height: 16),
                widget.child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) {
    final t = PageThemeScope.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: t.ok, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text('LIVE', style: Txt.label(t.ok, size: 10.5)),
      ],
    );
  }
}

class _TileTitle extends StatelessWidget {
  final String text;

  const _TileTitle(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: Txt.display(
      22,
      color: PageThemeScope.of(context).fg,
      width: 80,
      height: 1.15,
      tracking: -0.025,
    ),
  );
}

class _TileBody extends StatelessWidget {
  final String text;

  const _TileBody(this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Text(
      text,
      style: Txt.sans(
        14.5,
        color: PageThemeScope.of(context).muted,
        height: 1.5,
      ),
    ),
  );
}

class _LearningTile extends StatelessWidget {
  const _LearningTile();

  @override
  Widget build(BuildContext context) {
    final c = IdeScope.of(context);
    final t = PageThemeScope.of(context);
    final items = NowPlayingData.learningItems;
    final i = c.indexOf('learning');
    final (badge, title, detail) = items[i];
    return _Tile(
      id: 'tile-learning',
      widgetLabel: 'LearningTile',
      label: 'LEARNING',
      badge: Text(
        '${i + 1} / ${items.length}',
        style: Txt.mono(11.5, color: t.muted),
      ),
      onTap: () => c.cycle('learning'),
      child: Swap(
        id: i,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: t.accentSoft,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badge,
                    style: Txt.mono(
                      11,
                      color: t.accent,
                      medium: true,
                      height: 1,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(child: _TileTitle(title)),
              ],
            ),
            _TileBody(detail),
          ],
        ),
      ),
    );
  }
}

class _ChessTile extends StatefulWidget {
  const _ChessTile();

  @override
  State<_ChessTile> createState() => _ChessTileState();
}

class _ChessTileState extends State<_ChessTile> {
  late final Future<ChessSnapshot?> _chess = Chess.load(
    NowPlayingData.chessUsername,
  );

  @override
  Widget build(BuildContext context) {
    final c = IdeScope.of(context);
    final t = PageThemeScope.of(context);
    final showWin = c.flag('lastWin');
    return _Tile(
      id: 'tile-chess',
      widgetLabel: 'ChessTile',
      label: 'CHESS.COM',
      badge: const _LiveBadge(),
      onTap: () => c.cycle('lastWin'),
      child: FutureBuilder(
        future: _chess,
        builder: (context, snap) {
          final s = snap.data;
          if (snap.connectionState != ConnectionState.done) {
            return const _TileBody('Checking my rating…');
          }
          if (s == null) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _TileTitle('ay0dam0la'),
                _TileBody('Chess.com isn’t answering right now.'),
              ],
            );
          }
          final win = s.lastWin;
          return Swap(
            id: showWin && win != null,
            child: showWin && win != null
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: ChessBoard(
                          fen: win.fen,
                          size: 132,
                          flipped: !win.playedWhite,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _TileTitle('My last win'),
                            _TileBody(
                              'Beat ${win.opponent} (${win.opponentRating}) by ${win.wonBy}.',
                            ),
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: () => openLink(win.url),
                              child: Text(
                                'View the game →',
                                style: Txt.sans(
                                  14,
                                  color: t.accent,
                                  weight: 500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _TileTitle(s.summary),
                      const _TileBody(
                        'Read live from Chess.com. Tap for the final position of my last win.',
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }
}

class _MusicTile extends StatefulWidget {
  const _MusicTile();

  @override
  State<_MusicTile> createState() => _MusicTileState();
}

class _MusicTileState extends State<_MusicTile> {
  @override
  void initState() {
    super.initState();
    IdeScope.read(context).music.load();
  }

  @override
  Widget build(BuildContext context) {
    final c = IdeScope.of(context);
    final t = PageThemeScope.of(context);
    final m = c.music;
    final track = m.current;
    final progress = m.duration.inMilliseconds == 0
        ? 0.0
        : (m.position.inMilliseconds / m.duration.inMilliseconds).clamp(
            0.0,
            1.0,
          );
    return _Tile(
      id: 'tile-music',
      widgetLabel: 'PlaylistTile',
      label: 'SPOTIFY',
      badge: m.playing ? _Equalizer(color: t.accent) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _RoundButton(
                icon: m.playing
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                filled: true,
                onTap: () => c.cycle('playing'),
                label: m.playing ? 'Pause' : 'Play',
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Swap(
                  id: track?.title ?? '',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        track?.title ?? 'My playlist',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Txt.sans(
                          16,
                          color: t.fg,
                          weight: 600,
                          height: 1.3,
                        ),
                      ),
                      Text(
                        track?.artist ?? 'Loading…',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Txt.sans(14, color: t.muted, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ),
              _RoundButton(
                icon: Icons.skip_previous_rounded,
                onTap: m.previous,
                label: 'Previous',
              ),
              const SizedBox(width: 4),
              _RoundButton(
                icon: Icons.skip_next_rounded,
                onTap: m.next,
                label: 'Next',
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: t.line,
              valueColor: AlwaysStoppedAnimation(t.accent),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${m.playlist?.tracks.length ?? 0} tracks · 30-second previews',
            style: Txt.mono(11.5, color: t.muted),
          ),
        ],
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;
  final String label;

  const _RoundButton({
    required this.icon,
    required this.onTap,
    required this.label,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = PageThemeScope.of(context);
    return Semantics(
      button: true,
      label: label,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: filled ? 44 : 34,
            height: filled ? 44 : 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: filled ? t.fg : Colors.transparent,
            ),
            child: Icon(
              icon,
              size: filled ? 24 : 20,
              color: filled ? t.bg : t.muted,
            ),
          ),
        ),
      ),
    );
  }
}

class _Equalizer extends StatefulWidget {
  final Color color;

  const _Equalizer({required this.color});

  @override
  State<_Equalizer> createState() => _EqualizerState();
}

class _EqualizerState extends State<_Equalizer>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    builder: (_, _) => Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < 3; i++)
          Container(
            margin: const EdgeInsets.only(left: 2),
            width: 3,
            height:
                4 +
                9 * (0.5 + 0.5 * math.sin((_c.value + i * 0.3) * 2 * math.pi)),
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
      ],
    ),
  );
}

class _ClubTile extends StatefulWidget {
  const _ClubTile();

  @override
  State<_ClubTile> createState() => _ClubTileState();
}

class _ClubTileState extends State<_ClubTile> {
  late final Future<ChelseaForm?> _form = Football.load(
    NowPlayingData.chelseaTeamId,
  );

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _months = [
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

  @override
  Widget build(BuildContext context) {
    final c = IdeScope.of(context);
    final t = PageThemeScope.of(context);
    return _Tile(
      id: 'tile-club',
      widgetLabel: 'ClubTile',
      label: 'CHELSEA',
      badge: const _LiveBadge(),
      onTap: () => c.cycle('club'),
      child: FutureBuilder(
        future: _form,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const _TileBody('Checking the score…');
          }
          final f = snap.data;
          final last = f?.last;
          final next = f?.next;
          if (last == null && next == null) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _TileTitle('Chelsea FC'),
                _TileBody('The scores feed is down. Still Chelsea.'),
              ],
            );
          }
          final outcome = last?.outcomeFor(Football.team);
          final color = switch (outcome) {
            'W' => t.ok,
            'L' => const Color(0xFFD9534F),
            _ => t.muted,
          };
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (last != null)
                Row(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        outcome!,
                        style: Txt.mono(
                          12.5,
                          color: color,
                          medium: true,
                          height: 1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: _TileTitle(
                        last.shortFor(Football.team).substring(2),
                      ),
                    ),
                  ],
                ),
              if (next != null)
                _TileBody(
                  'Next: ${next.home == Football.team ? 'vs' : 'at'} ${next.opponentOf(Football.team)}, '
                  '${_days[next.kickoff.toLocal().weekday - 1]} ${next.kickoff.toLocal().day} ${_months[next.kickoff.toLocal().month - 1]}'
                  '${next.competition.isEmpty ? '' : ' · ${next.competition}'}',
                ),
            ],
          );
        },
      ),
    );
  }
}

// ── Contact ───────────────────────────────────────────────────────────────

class _Contact extends StatelessWidget {
  const _Contact();

  @override
  Widget build(BuildContext context) {
    final t = PageThemeScope.of(context);
    final c = IdeScope.read(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Kicker('05 · Contact'),
        const SectionTitle('Let’s build something that ships.'),
        const Lede(
          'Hiring for a Flutter role, building something, or want to argue about state management? I reply within a day.',
        ),
        const SizedBox(height: 30),
        Inspectable(
          id: 'email',
          label: 'Text(email)',
          child: _BigEmail(
            onCopy: () async {
              await Clipboard.setData(
                const ClipboardData(text: ProfileData.email),
              );
              c.log(
                LogKind.ok,
                'Copied ${ProfileData.email} to the clipboard.',
              );
            },
          ),
        ),
        const SizedBox(height: 28),
        Inspectable(
          id: 'links',
          label: 'Row(links)',
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              PageButton(
                label: 'Email me',
                primary: true,
                icon: Icons.mail_outline_rounded,
                onTap: () => openLink('mailto:${ProfileData.email}'),
              ),
              PageButton(
                label: 'GitHub',
                onTap: () => openLink(ProfileData.githubUrl),
              ),
              PageButton(
                label: 'LinkedIn',
                onTap: () => openLink(ProfileData.linkedinUrl),
              ),
              PageButton(label: 'Resume', onTap: () => openLink(resumeUrl)),
            ],
          ),
        ),
        const SizedBox(height: 64),
        Text(
          'Built in Flutter, hot-reloaded in Lagos · 2026',
          style: Txt.mono(12, color: t.muted),
        ),
      ],
    );
  }
}

class _BigEmail extends StatefulWidget {
  final Future<void> Function() onCopy;

  const _BigEmail({required this.onCopy});

  @override
  State<_BigEmail> createState() => _BigEmailState();
}

class _BigEmailState extends State<_BigEmail> {
  bool _hover = false;
  bool _copied = false;

  @override
  Widget build(BuildContext context) {
    final t = PageThemeScope.of(context);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () async {
          await widget.onCopy();
          if (!mounted) return;
          setState(() => _copied = true);
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) setState(() => _copied = false);
          });
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                ProfileData.email,
                style:
                    Txt.display(
                      44,
                      color: t.accent,
                      height: 1.1,
                      tracking: -0.035,
                    ).copyWith(
                      decoration: _hover
                          ? TextDecoration.underline
                          : TextDecoration.none,
                      decorationColor: t.accent,
                      decorationThickness: 1.5,
                    ),
              ),
            ),
            const SizedBox(height: 10),
            Swap(
              id: _copied,
              child: Text(
                _copied ? 'Copied to your clipboard.' : 'Click to copy',
                style: Txt.mono(12, color: _copied ? t.ok : t.muted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
