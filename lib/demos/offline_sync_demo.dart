import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/sfx.dart';
import '../theme/app_theme.dart';
import '../widgets/demo_phone.dart';

/// Offline-first field agent app, rebuilt from scratch on mock data.
///
/// Toggle airplane mode and add customers: rows queue in the outbox as
/// pending receipts. Reconnect and the outbox flushes one row at a time,
/// stamping each SYNCED. One row fails on its first attempt and retries
/// with backoff, the way a real outbox would.
class OfflineSyncDemo extends StatefulWidget {
  /// Optional outside switch for airplane mode (true = offline), e.g. the
  /// `airplaneMode:` value in the site's code. Kept in sync both ways: the
  /// in-phone toggle writes back to it.
  final ValueNotifier<bool>? airplane;

  const OfflineSyncDemo({super.key, this.airplane});

  @override
  State<OfflineSyncDemo> createState() => _OfflineSyncDemoState();
}

enum _Sync { pending, syncing, retrying, synced }

class _Customer {
  final String name;
  final String market;
  final int number;
  final String idempotencyKey;
  _Sync state;
  int attempts = 0;

  _Customer(
    this.name,
    this.market,
    this.number,
    this.idempotencyKey,
    this.state,
  );

  String get ref => 'CUS-${number.toString().padLeft(4, '0')}';
  String get initials => name.split(' ').map((w) => w[0]).join();
}

class _OfflineSyncDemoState extends State<OfflineSyncDemo> {
  static const _pool = [
    ('Adaeze Okafor', 'Oyingbo Market'),
    ('Tunde Bakare', 'Mile 12'),
    ('Halima Musa', 'Ikorodu Garage'),
    ('Chinedu Eze', 'Alaba Intl.'),
    ('Bisi Adeyemi', 'Mushin'),
    ('Ibrahim Sani', 'Agege'),
    ('Kemi Lawal', 'Ketu'),
    ('Emeka Obi', 'Idumota'),
  ];

  final _random = math.Random(7);
  final _customers = <_Customer>[];
  bool _online = true;
  int _next = 41;
  int _flushRun = 0;
  bool _failedOnce = false;

  @override
  void initState() {
    super.initState();
    _customers
      ..add(_make(_Sync.synced))
      ..add(_make(_Sync.synced));
    widget.airplane?.addListener(_onExternalAirplane);
    if (widget.airplane?.value ?? false) {
      _online = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) DemoPhone.setAirplane(context, true);
      });
    }
  }

  @override
  void didUpdateWidget(OfflineSyncDemo old) {
    super.didUpdateWidget(old);
    if (old.airplane != widget.airplane) {
      old.airplane?.removeListener(_onExternalAirplane);
      widget.airplane?.addListener(_onExternalAirplane);
    }
  }

  @override
  void dispose() {
    widget.airplane?.removeListener(_onExternalAirplane);
    super.dispose();
  }

  void _onExternalAirplane() {
    final offline = widget.airplane!.value;
    if (offline == !_online) return;
    _toggleOnline();
  }

  _Customer _make(_Sync state) {
    final (name, market) = _pool[(_next - 41) % _pool.length];
    final key = List.generate(
      6,
      (_) => _random.nextInt(16).toRadixString(16),
    ).join();
    return _Customer(name, market, _next++, key, state);
  }

  int get _queued => _customers.where((c) => c.state != _Sync.synced).length;

  void _add() {
    Sfx.play(Sound.click);
    final customer = _make(_Sync.pending);
    setState(() => _customers.insert(0, customer));
    if (_online) _flush();
  }

  void _toggleOnline() {
    Sfx.play(Sound.click);
    setState(() => _online = !_online);
    DemoPhone.setAirplane(context, !_online);
    widget.airplane?.value = !_online;
    if (_online) {
      _flush();
    } else {
      // Anything mid-flight goes back in the queue.
      _flushRun++;
      setState(() {
        for (final c in _customers) {
          if (c.state != _Sync.synced) c.state = _Sync.pending;
        }
      });
    }
  }

  /// Drain the outbox oldest-first, one row at a time. A new flush (or going
  /// offline) bumps [_flushRun], which stops any older flush loop.
  Future<void> _flush() async {
    final run = ++_flushRun;
    bool stale() => !mounted || run != _flushRun || !_online;

    while (true) {
      final pending = _customers.reversed.where(
        (c) => c.state == _Sync.pending,
      );
      if (pending.isEmpty) return;
      final c = pending.first;

      setState(() {
        c.state = _Sync.syncing;
        c.attempts++;
      });
      await Future.delayed(const Duration(milliseconds: 650));
      if (stale()) return;

      // One simulated failure per visit: the server times out, the row backs
      // off and retries with the same idempotency key, so no duplicate.
      final shouldFail = !_failedOnce && _queued > 1;
      if (shouldFail) {
        _failedOnce = true;
        setState(() => c.state = _Sync.retrying);
        await Future.delayed(const Duration(milliseconds: 1400));
        if (stale()) return;
        setState(() {
          c.state = _Sync.syncing;
          c.attempts++;
        });
        await Future.delayed(const Duration(milliseconds: 550));
        if (stale()) return;
      }

      setState(() => c.state = _Sync.synced);
      Sfx.play(Sound.stamp);
      await Future.delayed(const Duration(milliseconds: 250));
      if (stale()) return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Field Agent',
                      style: AppText.heading.copyWith(fontSize: 22),
                    ),
                    Text(
                      'IKORODU CLUSTER · AGENT 014',
                      style: AppText.monoLabel.copyWith(fontSize: 9),
                    ),
                  ],
                ),
              ),
              _AirplaneToggle(airplane: !_online, onTap: _toggleOnline),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _OutboxBar(online: _online, queued: _queued),
        const SizedBox(height: 6),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 10),
            itemCount: _customers.length,
            itemBuilder: (context, i) {
              final c = _customers[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ReceiptRow(key: ValueKey(c.number), customer: c)
                    .animate(key: ValueKey('in-${c.number}'))
                    .fadeIn(duration: 250.ms)
                    .slideY(
                      begin: -0.25,
                      end: 0,
                      duration: AppMotion.big,
                      curve: AppMotion.spring,
                    ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
          child: _AddButton(
            onTap: _add,
            hint: _online
                ? 'Try airplane mode first ↑'
                : 'Queues while offline',
          ),
        ),
      ],
    );
  }
}

class _AirplaneToggle extends StatelessWidget {
  final bool airplane;
  final VoidCallback onTap;

  const _AirplaneToggle({required this.airplane, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: airplane,
      label: 'Airplane mode',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: AppMotion.hover,
            width: 64,
            height: 34,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: airplane ? const Color(0xFFF59E0B) : AppColors.raised,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.line),
            ),
            child: AnimatedAlign(
              duration: AppMotion.big,
              curve: AppMotion.spring,
              alignment: airplane
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.airplanemode_active,
                  size: 16,
                  color: airplane ? const Color(0xFFB45309) : AppColors.night,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OutboxBar extends StatelessWidget {
  final bool online;
  final int queued;

  const _OutboxBar({required this.online, required this.queued});

  @override
  Widget build(BuildContext context) {
    final status = online
        ? (queued == 0 ? 'online · outbox empty' : 'online · syncing $queued')
        : 'offline · $queued queued';
    final dot = online ? AppColors.online : const Color(0xFFF59E0B);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              status,
              style: AppText.mono.copyWith(fontSize: 11, color: AppColors.text),
            ),
          ),
          Text('OUTBOX', style: AppText.monoLabel.copyWith(fontSize: 9)),
          const SizedBox(width: 6),
          AnimatedSwitcher(
            duration: AppMotion.hover,
            transitionBuilder: (child, a) =>
                ScaleTransition(scale: a, child: child),
            child: Container(
              key: ValueKey(queued),
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: queued == 0 ? AppColors.raised : AppColors.blue,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$queued',
                style: AppText.mono.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A customer row printed like a receipt, with a torn bottom edge.
class _ReceiptRow extends StatelessWidget {
  final _Customer customer;

  const _ReceiptRow({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    final c = customer;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 18),
      decoration: const ShapeDecoration(
        color: AppColors.surface,
        shape: ReceiptBorder(tooth: 6, radius: 10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: AppColors.blueDeep,
            child: Text(
              c.initials,
              style: AppText.mono.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.body.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
                Text(
                  c.market,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.bodyMuted.copyWith(fontSize: 12, height: 1.3),
                ),
                const SizedBox(height: 4),
                Text(
                  '${c.ref} · idem ${c.idempotencyKey}',
                  style: AppText.mono.copyWith(
                    fontSize: 9.5,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 78,
            child: Center(child: _StatusBadge(customer: c)),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final _Customer customer;

  const _StatusBadge({required this.customer});

  @override
  Widget build(BuildContext context) {
    switch (customer.state) {
      case _Sync.pending:
        return _chip('PENDING', AppColors.textMuted);
      case _Sync.syncing:
        return const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.blue,
          ),
        );
      case _Sync.retrying:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _chip('TIMEOUT', const Color(0xFFFF5A5F)),
            const SizedBox(height: 3),
            Text(
              'retry ${customer.attempts}',
              style: AppText.mono.copyWith(
                fontSize: 9,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ).animate().shakeX(hz: 5, amount: 3, duration: 350.ms);
      case _Sync.synced:
        // Rubber stamp: slams down big, settles at a tilt.
        final stamp = Transform.rotate(
          angle: -0.18,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.online, width: 1.6),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'SYNCED',
              style: AppText.mono.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.online,
                letterSpacing: 1.2,
              ),
            ),
          ),
        );
        return stamp
            .animate(key: ValueKey('stamp-${customer.number}'))
            .scaleXY(
              begin: 1.9,
              end: 1,
              duration: 260.ms,
              curve: Curves.easeInCubic,
            )
            .fadeIn(duration: 120.ms);
    }
  }

  Widget _chip(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    decoration: BoxDecoration(
      border: Border.all(color: color.withValues(alpha: 0.6)),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      label,
      style: AppText.mono.copyWith(
        fontSize: 9.5,
        color: color,
        letterSpacing: 0.8,
      ),
    ),
  );
}

class _AddButton extends StatelessWidget {
  final VoidCallback onTap;
  final String hint;

  const _AddButton({required this.onTap, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          hint,
          style: AppText.mono.copyWith(
            fontSize: 10,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: double.infinity,
          height: 46,
          child: FilledButton.icon(
            onPressed: onTap,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: AppText.body.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            icon: const Icon(Icons.person_add_alt_1, size: 18),
            label: const Text('Add customer'),
          ),
        ),
      ],
    );
  }
}

/// Rounded top corners, torn zig-zag bottom edge — like a printed receipt.
class ReceiptBorder extends ShapeBorder {
  final double tooth;
  final double radius;

  const ReceiptBorder({this.tooth = 10, this.radius = 14});

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.only(bottom: tooth);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      getOuterPath(rect, textDirection: textDirection);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final path = Path()
      ..moveTo(rect.left, rect.top + radius)
      ..arcToPoint(
        Offset(rect.left + radius, rect.top),
        radius: Radius.circular(radius),
      )
      ..lineTo(rect.right - radius, rect.top)
      ..arcToPoint(
        Offset(rect.right, rect.top + radius),
        radius: Radius.circular(radius),
      )
      ..lineTo(rect.right, rect.bottom - tooth);

    final teeth = math.max(1, (rect.width / (tooth * 2)).floor());
    final step = rect.width / teeth;
    for (var i = 0; i < teeth; i++) {
      final x = rect.right - i * step;
      path
        ..lineTo(x - step / 2, rect.bottom)
        ..lineTo(x - step, rect.bottom - tooth);
    }
    return path..close();
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) =>
      ReceiptBorder(tooth: tooth * t, radius: radius * t);
}
