import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/sfx.dart';
import '../theme/app_theme.dart';

/// Event planner day view, rebuilt from scratch on mock data.
///
/// Tasks sit on an hour grid by start time. Overlapping tasks are grouped
/// and split into columns so nothing hides behind anything else, and a
/// "now" line tracks the clock. The role switch shows per-role permissions:
/// creators can add and delete, co-planners can add, viewers can only look.
class PlannerDemo extends StatefulWidget {
  const PlannerDemo({super.key});

  @override
  State<PlannerDemo> createState() => _PlannerDemoState();
}

enum PlannerRole { creator, coPlanner, viewer }

extension on PlannerRole {
  String get label => switch (this) {
    PlannerRole.creator => 'Creator',
    PlannerRole.coPlanner => 'Co-planner',
    PlannerRole.viewer => 'Viewer',
  };
  bool get canAdd => this != PlannerRole.viewer;
  bool get canDelete => this == PlannerRole.creator;
}

class PlannerTask {
  final int id;
  final String title;

  /// Minutes from midnight.
  final int start;
  final int end;
  final Color color;

  const PlannerTask(this.id, this.title, this.start, this.end, this.color);
}

/// A task with its place in an overlap group: which column, out of how many.
class PlacedTask {
  final PlannerTask task;
  final int column;
  final int columns;

  const PlacedTask(this.task, this.column, this.columns);
}

/// Lays tasks out side by side where they overlap.
///
/// One sorted pass builds groups: a task starting before the current group
/// ends joins it (and may stretch its end); otherwise it starts a new group.
/// Inside a group, each task takes the first column that's free by its start.
List<PlacedTask> layoutTasks(List<PlannerTask> tasks) {
  final sorted = [...tasks]
    ..sort(
      (a, b) => a.start != b.start
          ? a.start.compareTo(b.start)
          : b.end.compareTo(a.end),
    );
  final placed = <PlacedTask>[];
  var group = <(PlannerTask, int)>[];
  var groupEnd = -1;
  var columnEnds = <int>[];

  void flush() {
    final count = columnEnds.length;
    for (final (task, column) in group) {
      placed.add(PlacedTask(task, column, count));
    }
    group = [];
    columnEnds = [];
  }

  for (final task in sorted) {
    if (task.start >= groupEnd) {
      flush();
      groupEnd = task.end;
    } else {
      groupEnd = math.max(groupEnd, task.end);
    }
    var column = columnEnds.indexWhere((end) => end <= task.start);
    if (column == -1) {
      column = columnEnds.length;
      columnEnds.add(task.end);
    } else {
      columnEnds[column] = task.end;
    }
    group.add((task, column));
  }
  flush();
  return placed;
}

class _PlannerDemoState extends State<PlannerDemo> {
  static const _dayStart = 8 * 60;
  static const _dayEnd = 20 * 60;
  static const _hourHeight = 56.0;
  static const _palette = [
    AppColors.blue,
    Color(0xFF8B5CF6),
    Color(0xFF14B8A6),
    Color(0xFFF97316),
  ];
  static const _ideas = [
    'Cake tasting',
    'Florist call',
    'Seating plan',
    'DJ sound check',
    'Pay venue deposit',
    'Dress fitting',
  ];

  final _scroll = ScrollController(initialScrollOffset: _hourHeight * 0.75);
  final _random = math.Random(3);
  late final Timer _clock;
  DateTime _now = DateTime.now();
  PlannerRole _role = PlannerRole.creator;
  int _nextId = 100;
  int _ideaIndex = 0;

  final _tasks = <PlannerTask>[
    const PlannerTask(
      1,
      'Venue walkthrough',
      9 * 60,
      10 * 60 + 30,
      AppColors.blue,
    ),
    const PlannerTask(
      2,
      'Caterer menu call',
      9 * 60 + 30,
      10 * 60 + 15,
      Color(0xFF8B5CF6),
    ),
    const PlannerTask(3, 'Décor vendor', 10 * 60, 11 * 60, Color(0xFF14B8A6)),
    const PlannerTask(
      4,
      'Photographer brief',
      12 * 60,
      13 * 60,
      Color(0xFFF97316),
    ),
    const PlannerTask(
      5,
      'Guest list review',
      14 * 60 + 30,
      16 * 60,
      AppColors.blue,
    ),
    const PlannerTask(6, 'Rehearsal', 15 * 60, 16 * 60 + 30, Color(0xFF8B5CF6)),
  ];

  @override
  void initState() {
    super.initState();
    _clock = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _clock.cancel();
    _scroll.dispose();
    super.dispose();
  }

  void _setRole(PlannerRole role) {
    Sfx.play(Sound.click);
    setState(() => _role = role);
  }

  /// Drops a new hour-long task somewhere busy, so the regrouping shows.
  void _addTask() {
    if (!_role.canAdd) return;
    Sfx.play(Sound.click);
    final start =
        _dayStart +
        60 +
        _random.nextInt(9) * 60 +
        (_random.nextBool() ? 30 : 0);
    setState(() {
      _tasks.add(
        PlannerTask(
          _nextId++,
          _ideas[_ideaIndex++ % _ideas.length],
          start,
          math.min(start + 60 + (_random.nextBool() ? 30 : 0), _dayEnd),
          _palette[_random.nextInt(_palette.length)],
        ),
      );
    });
  }

  PlannerTask? _selected;

  void _openTask(PlannerTask task) {
    Sfx.play(Sound.click);
    setState(() => _selected = task);
  }

  void _deleteSelected() {
    final task = _selected;
    if (task == null || !_role.canDelete) return;
    Sfx.play(Sound.click);
    setState(() {
      _tasks.removeWhere((t) => t.id == task.id);
      _selected = null;
    });
  }

  /// Task details, drawn inside the phone rather than over the whole page.
  Widget _sheet(PlannerTask task) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: () => setState(() => _selected = null),
            child: ColoredBox(color: Colors.black.withValues(alpha: 0.45)),
          ),
        ).animate().fadeIn(duration: 150.ms),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child:
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                decoration: const BoxDecoration(
                  color: AppColors.raised,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.line,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      task.title,
                      style: AppText.heading.copyWith(fontSize: 19),
                    ),
                    Text(
                      '${_hhmm(task.start)} – ${_hhmm(task.end)} · ${_role.label.toUpperCase()}',
                      style: AppText.mono.copyWith(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _role.canDelete ? _deleteSelected : null,
                        icon: Icon(
                          _role.canDelete
                              ? Icons.delete_outline
                              : Icons.lock_outline,
                          size: 18,
                        ),
                        label: Text(
                          _role.canDelete
                              ? 'Delete task'
                              : 'Only the creator can delete',
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFFF5A5F),
                          side: const BorderSide(color: AppColors.line),
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().slideY(
                begin: 1,
                end: 0,
                duration: AppMotion.big,
                curve: AppMotion.settle,
              ),
        ),
      ],
    );
  }

  static String _hhmm(int minutes) =>
      '${(minutes ~/ 60).toString().padLeft(2, '0')}:${(minutes % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final nowMinutes = _now.hour * 60 + _now.minute;
    final placed = layoutTasks(_tasks);

    final selected = _selected;
    return Stack(
      children: [
        _day(nowMinutes, placed),
        if (selected != null) _sheet(selected),
      ],
    );
  }

  Widget _day(int nowMinutes, List<PlacedTask> placed) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Wedding · Saturday',
                      style: AppText.heading.copyWith(fontSize: 18),
                    ),
                    Text(
                      '${_tasks.length} TASKS · DAY VIEW',
                      style: AppText.monoLabel.copyWith(fontSize: 9),
                    ),
                  ],
                ),
              ),
              _AddButton(enabled: _role.canAdd, onTap: _addTask),
            ],
          ),
        ),
        const SizedBox(height: 8),
        _RoleSwitch(role: _role, onChanged: _setRole),
        if (_role == PlannerRole.viewer)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 6, 16, 0),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.raised,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.visibility_outlined,
                  size: 14,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'View only: ask the creator for access',
                    style: AppText.mono.copyWith(
                      fontSize: 10,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 200.ms),
        const SizedBox(height: 8),
        Expanded(
          child: SingleChildScrollView(
            controller: _scroll,
            padding: const EdgeInsets.only(bottom: 12),
            child: SizedBox(
              height: (_dayEnd - _dayStart) / 60 * _hourHeight + 12,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const gutter = 44.0;
                  final laneWidth = constraints.maxWidth - gutter - 12;
                  double y(int minutes) =>
                      (minutes - _dayStart) / 60 * _hourHeight + 6;

                  return Stack(
                    children: [
                      for (
                        var h = _dayStart ~/ 60;
                        h <= _dayEnd ~/ 60;
                        h++
                      ) ...[
                        Positioned(
                          left: 8,
                          top: y(h * 60) - 7,
                          child: Text(
                            '${h.toString().padLeft(2, '0')}:00',
                            style: AppText.mono.copyWith(
                              fontSize: 9.5,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                        Positioned(
                          left: gutter,
                          right: 12,
                          top: y(h * 60),
                          child: Container(height: 1, color: AppColors.line),
                        ),
                      ],
                      for (final p in placed)
                        AnimatedPositioned(
                          key: ValueKey(p.task.id),
                          duration: AppMotion.big,
                          curve: AppMotion.settle,
                          left: gutter + 2 + laneWidth / p.columns * p.column,
                          width: laneWidth / p.columns - 4,
                          top: y(p.task.start) + 1,
                          height:
                              (p.task.end - p.task.start) / 60 * _hourHeight -
                              3,
                          child:
                              _TaskBlock(
                                    task: p.task,
                                    compact: p.columns > 2,
                                    onTap: () => _openTask(p.task),
                                  )
                                  .animate(key: ValueKey('in-${p.task.id}'))
                                  .fadeIn(duration: 250.ms)
                                  .scaleXY(
                                    begin: 0.9,
                                    end: 1,
                                    curve: AppMotion.spring,
                                  ),
                        ),
                      if (nowMinutes > _dayStart && nowMinutes < _dayEnd)
                        Positioned(
                          left: gutter - 4,
                          right: 12,
                          top: y(nowMinutes) - 4,
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFF5A5F),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: 1.5,
                                  color: const Color(0xFFFF5A5F),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RoleSwitch extends StatelessWidget {
  final PlannerRole role;
  final ValueChanged<PlannerRole> onChanged;

  const _RoleSwitch({required this.role, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          for (final r in PlannerRole.values)
            Expanded(
              child: Semantics(
                button: true,
                selected: r == role,
                label: 'View as ${r.label}',
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => onChanged(r),
                    child: AnimatedContainer(
                      duration: AppMotion.hover,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: r == role ? AppColors.blue : Colors.transparent,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Text(
                        r.label,
                        style: AppText.body.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: r == role ? Colors.white : AppColors.textMuted,
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

class _AddButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;

  const _AddButton({required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: enabled ? 'Add a task' : 'Viewers can\'t add tasks',
      child: Semantics(
        button: true,
        enabled: enabled,
        label: 'Add task',
        child: MouseRegion(
          cursor: enabled
              ? SystemMouseCursors.click
              : SystemMouseCursors.forbidden,
          child: GestureDetector(
            onTap: enabled ? onTap : null,
            child: AnimatedContainer(
              duration: AppMotion.hover,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: enabled ? AppColors.blue : AppColors.raised,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    enabled ? Icons.add : Icons.lock_outline,
                    size: 15,
                    color: enabled ? Colors.white : AppColors.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Task',
                    style: AppText.body.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: enabled ? Colors.white : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TaskBlock extends StatelessWidget {
  final PlannerTask task;
  final bool compact;
  final VoidCallback onTap;

  const _TaskBlock({
    required this.task,
    required this.compact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    String hhmm(int m) => '${m ~/ 60}:${(m % 60).toString().padLeft(2, '0')}';
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        // Colour bar on the left; text shrinks to fit short tasks instead of
        // overflowing.
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: ColoredBox(
            color: task.color.withValues(alpha: 0.22),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 3, color: task.color),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(5, 3, 3, 2),
                    // Full-size text; short or narrow blocks drop the time
                    // line and clip the title instead of shrinking it.
                    child: LayoutBuilder(
                      builder: (context, box) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Text(
                              task.title,
                              maxLines: box.maxHeight > 34 ? 2 : 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.body.copyWith(
                                fontSize: compact ? 10 : 11,
                                fontWeight: FontWeight.w600,
                                height: 1.2,
                              ),
                            ),
                          ),
                          if (!compact && box.maxHeight > 36)
                            Text(
                              '${hhmm(task.start)}–${hhmm(task.end)}',
                              maxLines: 1,
                              overflow: TextOverflow.clip,
                              style: AppText.mono.copyWith(
                                fontSize: 9,
                                color: AppColors.textMuted,
                              ),
                            ),
                        ],
                      ),
                    ),
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
