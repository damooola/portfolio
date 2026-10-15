import 'dart:async';

import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../theme/app_theme.dart';

/// Shared phone frame for every live demo: notch, a real status bar (time,
/// signal, battery) and a home bar, so all demos look consistent.
///
/// The battery drains slowly while the demo is on screen. Tap the USB-C
/// cable under the phone to charge it back up.
///
/// On phones the site is already on a phone, so the demo is shown
/// full-width without the frame.
class DemoPhone extends StatefulWidget {
  final Widget child;

  /// Changes when the demo inside is swapped, which resets airplane mode.
  final Object? screenId;

  const DemoPhone({super.key, required this.child, this.screenId});

  /// Lets a demo flip the frame's status bar into airplane mode. Call it
  /// from event handlers, not during build.
  static void setAirplane(BuildContext context, bool on) =>
      context.findAncestorStateOfType<_DemoPhoneState>()?._setAirplane(on);

  static const screenWidth = 320.0;
  static const screenHeight = 640.0;

  @override
  State<DemoPhone> createState() => _DemoPhoneState();
}

class _DemoPhoneState extends State<DemoPhone> {
  Timer? _clock;
  Timer? _battery;
  DateTime _now = DateTime.now();
  int _level = 86;
  bool _charging = false;
  bool _visible = false;
  bool _airplane = false;

  void _setAirplane(bool on) {
    if (on != _airplane) setState(() => _airplane = on);
  }

  @override
  void initState() {
    super.initState();
    _clock = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void didUpdateWidget(DemoPhone old) {
    super.didUpdateWidget(old);
    if (old.screenId != widget.screenId) _airplane = false;
  }

  @override
  void dispose() {
    _clock?.cancel();
    _battery?.cancel();
    super.dispose();
  }

  void _onVisibility(VisibilityInfo info) {
    final visible = info.visibleFraction > 0.15;
    if (visible == _visible || !mounted) return;
    setState(() => _visible = visible);
    _battery?.cancel();
    if (visible) {
      _battery = Timer.periodic(
        const Duration(seconds: 3),
        (_) => _tickBattery(),
      );
    }
  }

  void _tickBattery() {
    if (!mounted) return;
    setState(() {
      if (_charging) {
        _level = (_level + 4).clamp(0, 100);
        if (_level == 100) _charging = false;
      } else {
        _level = (_level - 1).clamp(5, 100);
      }
    });
  }

  void _toggleCharging() => setState(() => _charging = !_charging);

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobile(MediaQuery.sizeOf(context).width);
    // Demos pause (animations stop ticking) once they scroll out of view.
    final screen = TickerMode(enabled: _visible, child: widget.child);

    return VisibilityDetector(
      key: ObjectKey(this),
      onVisibilityChanged: _onVisibility,
      child: isMobile ? _bare(screen) : _framed(screen),
    );
  }

  Widget _bare(Widget screen) {
    return Container(
      height: 600,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.night,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      child: screen,
    );
  }

  Widget _framed(Widget screen) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: DemoPhone.screenWidth + 24,
          height: DemoPhone.screenHeight + 24,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(52),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.14),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 60,
                offset: const Offset(0, 30),
              ),
              BoxShadow(
                color: AppColors.blue.withValues(alpha: 0.12),
                blurRadius: 80,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: ColoredBox(
              color: AppColors.night,
              child: Column(
                children: [
                  _StatusBar(
                    now: _now,
                    level: _level,
                    charging: _charging,
                    airplane: _airplane,
                  ),
                  Expanded(child: screen),
                  const _HomeBar(),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _Charger(charging: _charging, level: _level, onTap: _toggleCharging),
      ],
    );
  }
}

class _StatusBar extends StatelessWidget {
  final DateTime now;
  final int level;
  final bool charging;
  final bool airplane;

  const _StatusBar({
    required this.now,
    required this.level,
    required this.charging,
    required this.airplane,
  });

  @override
  Widget build(BuildContext context) {
    final time =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final style = AppText.mono.copyWith(
      fontSize: 13,
      fontWeight: FontWeight.w600,
    );

    return SizedBox(
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Dynamic-island style notch.
          Container(
            width: 96,
            height: 26,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26),
            child: Row(
              children: [
                Text(time, style: style),
                const Spacer(),
                if (airplane)
                  const Icon(
                    Icons.airplanemode_active,
                    size: 14,
                    color: AppColors.text,
                  )
                else ...[
                  const _SignalBars(),
                  const SizedBox(width: 5),
                  const Icon(Icons.wifi, size: 14, color: AppColors.text),
                ],
                const SizedBox(width: 6),
                _Battery(level: level, charging: charging),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SignalBars extends StatelessWidget {
  const _SignalBars();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final h in const [4.0, 6.0, 8.0, 10.0])
          Container(
            width: 3,
            height: h,
            margin: const EdgeInsets.only(left: 1.5),
            decoration: BoxDecoration(
              color: AppColors.text,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
      ],
    );
  }
}

class _Battery extends StatelessWidget {
  final int level;
  final bool charging;

  const _Battery({required this.level, required this.charging});

  @override
  Widget build(BuildContext context) {
    final fill = charging
        ? AppColors.online
        : level <= 20
        ? const Color(0xFFFF5A5F)
        : AppColors.text;
    return Semantics(
      label: 'Battery $level percent${charging ? ', charging' : ''}',
      child: Row(
        children: [
          Container(
            width: 24,
            height: 12,
            padding: const EdgeInsets.all(1.5),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.text.withValues(alpha: 0.5)),
              borderRadius: BorderRadius.circular(3.5),
            ),
            alignment: Alignment.centerLeft,
            child: AnimatedFractionallySizedBox(
              duration: AppMotion.big,
              widthFactor: level / 100,
              heightFactor: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: fill,
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
            ),
          ),
          Container(
            width: 1.5,
            height: 4,
            margin: const EdgeInsets.only(left: 1),
            color: AppColors.text.withValues(alpha: 0.5),
          ),
          if (charging)
            const Icon(Icons.bolt, size: 12, color: AppColors.online),
        ],
      ),
    );
  }
}

class _HomeBar extends StatelessWidget {
  const _HomeBar();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 22,
      child: Center(
        child: Container(
          width: 110,
          height: 4.5,
          decoration: BoxDecoration(
            color: AppColors.text.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }
}

/// A little USB-C cable under the phone. Tap it to plug in.
class _Charger extends StatefulWidget {
  final bool charging;
  final int level;
  final VoidCallback onTap;

  const _Charger({
    required this.charging,
    required this.level,
    required this.onTap,
  });

  @override
  State<_Charger> createState() => _ChargerState();
}

class _ChargerState extends State<_Charger> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final label = widget.charging
        ? 'CHARGING · ${widget.level}%'
        : widget.level < 100
        ? 'PLUG IN · ${widget.level}%'
        : 'FULL · 100%';
    final color = widget.charging
        ? AppColors.online
        : (_hover ? AppColors.text : AppColors.textMuted);

    return Semantics(
      button: true,
      label: widget.charging ? 'Unplug the phone' : 'Plug in the phone',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Cable slides up into the phone when plugged in.
              AnimatedSlide(
                offset: Offset(0, widget.charging ? -0.25 : 0),
                duration: AppMotion.big,
                curve: AppMotion.spring,
                child: Icon(Icons.usb, size: 20, color: color),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppText.monoLabel.copyWith(fontSize: 11, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
