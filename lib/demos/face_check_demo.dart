import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/sfx.dart';
import '../theme/app_theme.dart';

/// Guided face capture, rebuilt from scratch as a simulation.
///
/// The real thing reads head angles and a smile score from the camera with
/// on-device ML. Here you steer a drawn face instead: move the pointer (or
/// drag) to turn it, use the tilt slider and the smile toggle. Each step
/// checks its target angle against a window while capping the others, so
/// a tilted head can't pass for a turn.
class FaceCheckDemo extends StatefulWidget {
  const FaceCheckDemo({super.key});

  @override
  State<FaceCheckDemo> createState() => _FaceCheckDemoState();
}

class FacePose {
  /// Degrees. Positive yaw = turned to the left, positive pitch = looking up.
  final double yaw;
  final double pitch;
  final double roll;

  /// 0 to 1, like an ML smile probability.
  final double smile;

  const FacePose({this.yaw = 0, this.pitch = 0, this.roll = 0, this.smile = 0});
}

enum FaceStep { straight, left, right, smile }

extension FaceStepText on FaceStep {
  String get prompt => switch (this) {
    FaceStep.straight => 'Look straight ahead',
    FaceStep.left => 'Turn your head left',
    FaceStep.right => 'Turn your head right',
    FaceStep.smile => 'Now smile',
  };
}

/// Does [pose] satisfy [step]? The target axis must sit in its window and
/// every other axis must stay under a cap.
bool facePasses(FaceStep step, FacePose pose) {
  bool calm(double v, double cap) => v.abs() <= cap;
  switch (step) {
    case FaceStep.straight:
      return calm(pose.yaw, 8) &&
          calm(pose.pitch, 8) &&
          calm(pose.roll, 10) &&
          pose.smile < 0.5;
    case FaceStep.left:
      return pose.yaw >= 20 &&
          pose.yaw <= 45 &&
          calm(pose.pitch, 12) &&
          calm(pose.roll, 12);
    case FaceStep.right:
      return pose.yaw <= -20 &&
          pose.yaw >= -45 &&
          calm(pose.pitch, 12) &&
          calm(pose.roll, 12);
    case FaceStep.smile:
      return pose.smile >= 0.7 &&
          calm(pose.yaw, 12) &&
          calm(pose.pitch, 12) &&
          calm(pose.roll, 12);
  }
}

class _FaceCheckDemoState extends State<FaceCheckDemo> {
  static const _hold = Duration(milliseconds: 600);

  late final Timer _ticker;
  // Starts turned a little, so the visitor has to centre it first.
  FacePose _pose = const FacePose(yaw: 22, pitch: 8);
  int _step = 0;
  DateTime? _passingSince;
  double _uploading = -1;

  bool get _done => _step >= FaceStep.values.length;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(
      const Duration(milliseconds: 100),
      (_) => _check(),
    );
  }

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }

  void _setPose(FacePose pose) {
    if (_done) return;
    setState(() => _pose = pose);
  }

  /// Like checking camera frames: a pose has to hold briefly to count.
  void _check() {
    if (!mounted || _done) return;
    final passing = facePasses(FaceStep.values[_step], _pose);
    if (!passing) {
      if (_passingSince != null) setState(() => _passingSince = null);
      return;
    }
    final since = _passingSince ??= DateTime.now();
    if (DateTime.now().difference(since) >= _hold) {
      Sfx.play(Sound.ding);
      setState(() {
        _step++;
        _passingSince = null;
      });
      if (_done) _upload();
    } else {
      setState(() {});
    }
  }

  Future<void> _upload() async {
    for (var i = 0; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 120));
      if (!mounted) return;
      setState(() => _uploading = i / 10);
    }
    Sfx.play(Sound.stamp);
  }

  void _restart() {
    Sfx.play(Sound.click);
    setState(() {
      _step = 0;
      _pose = const FacePose(yaw: 22, pitch: 8);
      _uploading = -1;
      _passingSince = null;
    });
  }

  void _fromPointer(Offset local, Size size) {
    final x = (local.dx / size.width).clamp(0.0, 1.0);
    final y = (local.dy / size.height).clamp(0.0, 1.0);
    _setPose(
      FacePose(
        yaw: (0.5 - x) * 100,
        pitch: (0.5 - y) * 70,
        roll: _pose.roll,
        smile: _pose.smile,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final step = _done ? null : FaceStep.values[_step];
    final holding = _passingSince == null
        ? 0.0
        : (DateTime.now().difference(_passingSince!).inMilliseconds /
                  _hold.inMilliseconds)
              .clamp(0.0, 1.0);
    final progress = (_step + holding) / FaceStep.values.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
      child: Column(
        children: [
          Text(
            'IDENTITY CHECK · STEP ${math.min(_step + 1, 4)} OF 4',
            style: AppText.monoLabel.copyWith(fontSize: 9),
          ),
          const SizedBox(height: 4),
          AnimatedSwitcher(
            duration: AppMotion.hover,
            child: Text(
              step?.prompt ?? (_uploading < 1 ? 'Uploading…' : 'Verified'),
              key: ValueKey(step ?? _uploading >= 1),
              style: AppText.heading.copyWith(fontSize: 20),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: LayoutBuilder(
              builder: (context, box) {
                final size = Size(box.maxWidth, box.maxHeight);
                return MouseRegion(
                  cursor: _done
                      ? SystemMouseCursors.basic
                      : SystemMouseCursors.move,
                  onHover: (e) => _fromPointer(e.localPosition, size),
                  child: GestureDetector(
                    onPanUpdate: (d) => _fromPointer(d.localPosition, size),
                    child: Semantics(
                      label:
                          'Simulated camera. Move the pointer to turn the face.',
                      child: CustomPaint(
                        size: size,
                        painter: _FacePainter(
                          pose: _pose,
                          progress: _done ? 1 : progress,
                          passing: _passingSince != null || _done,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          if (_done)
            Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: _uploading.clamp(0.0, 1.0),
                    minHeight: 5,
                    backgroundColor: AppColors.raised,
                    color: AppColors.online,
                  ),
                ),
                const SizedBox(height: 10),
                if (_uploading >= 1)
                  TextButton(
                    onPressed: _restart,
                    child: const Text('Try it again'),
                  ).animate().fadeIn(),
              ],
            )
          else ...[
            _Readout(pose: _pose, step: step!),
            const SizedBox(height: 6),
            Row(
              children: [
                Text('TILT', style: AppText.monoLabel.copyWith(fontSize: 9)),
                Expanded(
                  child: Slider(
                    value: _pose.roll,
                    min: -30,
                    max: 30,
                    onChanged: (v) => _setPose(
                      FacePose(
                        yaw: _pose.yaw,
                        pitch: _pose.pitch,
                        roll: v,
                        smile: _pose.smile,
                      ),
                    ),
                  ),
                ),
                FilterChip(
                  label: const Text('Smile'),
                  selected: _pose.smile > 0.5,
                  onSelected: (on) {
                    Sfx.play(Sound.click);
                    _setPose(
                      FacePose(
                        yaw: _pose.yaw,
                        pitch: _pose.pitch,
                        roll: _pose.roll,
                        smile: on ? 0.92 : 0.05,
                      ),
                    );
                  },
                  labelStyle: AppText.body.copyWith(fontSize: 11),
                  visualDensity: VisualDensity.compact,
                  selectedColor: AppColors.blue,
                  backgroundColor: AppColors.raised,
                  side: const BorderSide(color: AppColors.line),
                  showCheckmark: false,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Readout extends StatelessWidget {
  final FacePose pose;
  final FaceStep step;

  const _Readout({required this.pose, required this.step});

  @override
  Widget build(BuildContext context) {
    final ok = facePasses(step, pose);
    String deg(double v) => '${v.round()}°';
    Widget cell(String label, String value) => Expanded(
      child: Column(
        children: [
          Text(label, style: AppText.monoLabel.copyWith(fontSize: 8.5)),
          Text(
            value,
            style: AppText.mono.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ok ? AppColors.online : AppColors.line),
      ),
      child: Row(
        children: [
          cell('YAW', deg(pose.yaw)),
          cell('PITCH', deg(pose.pitch)),
          cell('TILT', deg(pose.roll)),
          cell('SMILE', pose.smile.toStringAsFixed(1)),
        ],
      ),
    );
  }
}

class _FacePainter extends CustomPainter {
  final FacePose pose;
  final double progress;
  final bool passing;

  _FacePainter({
    required this.pose,
    required this.progress,
    required this.passing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final oval = Rect.fromCenter(
      center: c,
      width: size.width * 0.72,
      height: size.height * 0.92,
    );

    // Camera-ish backdrop and the guide oval.
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(16)),
      Paint()..color = const Color(0xFF060A16),
    );
    canvas.drawOval(oval, Paint()..color = const Color(0xFF0E1530));
    canvas.drawOval(
      oval,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = AppColors.raised,
    );
    // Progress around the oval.
    canvas.drawArc(
      oval,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..color = passing ? AppColors.online : AppColors.blue,
    );

    // The face: features shift with yaw/pitch, everything rotates with roll.
    final r = oval.width * 0.36;
    final dx = -pose.yaw / 45 * r * 0.45;
    final dy = -pose.pitch / 35 * r * 0.4;
    canvas
      ..save()
      ..translate(c.dx, c.dy)
      ..rotate(pose.roll * math.pi / 180);

    final skin = Paint()..color = const Color(0xFF8D5A3B);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(dx * 0.25, dy * 0.25),
        width: r * 2 - pose.yaw.abs() / 45 * r * 0.25,
        height: r * 2.35,
      ),
      skin,
    );

    final eye = Paint()..color = const Color(0xFF1A1A1A);
    final eyeY = dy - r * 0.2;
    canvas
      ..drawCircle(Offset(dx - r * 0.36, eyeY), r * 0.09, eye)
      ..drawCircle(Offset(dx + r * 0.36, eyeY), r * 0.09, eye);

    // Nose points where the head is turned.
    canvas.drawLine(
      Offset(dx, eyeY + r * 0.15),
      Offset(dx * 1.35, eyeY + r * 0.48),
      Paint()
        ..color = const Color(0xFF6A3F27)
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );

    // Mouth: flat line to a curve as the smile grows.
    final mouth = Path()
      ..moveTo(dx - r * 0.32, dy + r * 0.62)
      ..quadraticBezierTo(
        dx,
        dy + r * (0.62 + 0.35 * pose.smile),
        dx + r * 0.32,
        dy + r * 0.62,
      );
    canvas.drawPath(
      mouth,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFF3A1E12),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_FacePainter old) =>
      old.pose != pose || old.progress != progress || old.passing != passing;
}
