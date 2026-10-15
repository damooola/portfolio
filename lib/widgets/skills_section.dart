import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../data/portfolio_data.dart';
import '../services/sfx.dart';
import '../theme/app_theme.dart';
import 'responsive_section.dart';
import 'reveal.dart';
import 'section_header.dart';

class SkillsSection extends StatelessWidget {
  const SkillsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final sideBySide =
        MediaQuery.sizeOf(context).width >= AppBreakpoints.tablet;

    final intro = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          index: '03',
          label: 'Skills',
          title: 'Player profile',
          caption:
              'Click the card to see the stats. They\'re self-rated, '
              'so take them with a pinch of salt.',
        ),
        Reveal(
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final tool in PlayerCardData.toolkit)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Text(
                    tool,
                    style: AppText.mono.copyWith(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );

    return ResponsiveSection(
      child: sideBySide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: intro),
                const SizedBox(width: AppSpacing.xl),
                const Reveal(child: PlayerCard()),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                intro,
                const SizedBox(height: AppSpacing.xl),
                const Center(child: Reveal(child: PlayerCard())),
              ],
            ),
    );
  }
}

/// A football-game player card. Click to flip; on the back the attribute
/// bars fill and the numbers count up. Double-click the rating to see form.
class PlayerCard extends StatefulWidget {
  const PlayerCard({super.key});

  static const width = 300.0;
  static const height = 430.0;

  @override
  State<PlayerCard> createState() => _PlayerCardState();
}

class _PlayerCardState extends State<PlayerCard>
    with SingleTickerProviderStateMixin {
  late final _flip = AnimationController(vsync: this, duration: AppMotion.big);
  bool _back = false;
  bool _showForm = false;
  bool _hover = false;
  int _flips = 0;

  @override
  void dispose() {
    _flip.dispose();
    super.dispose();
  }

  void _toggle() {
    Sfx.play(Sound.click);
    setState(() {
      _back = !_back;
      if (_back) _flips++;
    });
    _back ? _flip.forward() : _flip.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final reduced = AppMotion.reduced(context);

    return Semantics(
      button: true,
      label: _back
          ? 'Player card back, attribute bars. Tap to flip.'
          : 'Player card, rating ${PlayerCardData.overall}. Tap to flip.',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: _toggle,
          child: AnimatedScale(
            scale: _hover ? 1.02 : 1,
            duration: AppMotion.hover,
            curve: AppMotion.spring,
            child: AnimatedBuilder(
              animation: _flip,
              builder: (context, _) {
                if (reduced) {
                  return AnimatedSwitcher(
                    duration: AppMotion.hover,
                    child: _back
                        ? _CardBack(key: const ValueKey('b'), run: _flips)
                        : _front(),
                  );
                }
                final t = AppMotion.spring.transform(_flip.value);
                final angle = t * math.pi;
                final showBack = angle > math.pi / 2;
                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.0015)
                    ..rotateY(angle),
                  child: showBack
                      ? Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.rotationY(math.pi),
                          child: _CardBack(run: _flips),
                        )
                      : _front(),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _front() => _CardFront(
    showForm: _showForm,
    onRatingDoubleTap: () {
      Sfx.play(Sound.chime);
      setState(() => _showForm = !_showForm);
    },
  );
}

BoxDecoration _cardDecoration() => BoxDecoration(
  borderRadius: BorderRadius.circular(26),
  gradient: const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0B5BD3), AppColors.blueDeep, Color(0xFF02234A)],
    stops: [0, 0.5, 1],
  ),
  border: Border.all(color: Colors.white.withValues(alpha: 0.22), width: 1.5),
  boxShadow: [
    BoxShadow(
      color: AppColors.blue.withValues(alpha: 0.35),
      blurRadius: 50,
      offset: const Offset(0, 20),
    ),
  ],
);

class _CardFront extends StatelessWidget {
  final bool showForm;
  final VoidCallback onRatingDoubleTap;

  const _CardFront({required this.showForm, required this.onRatingDoubleTap});

  @override
  Widget build(BuildContext context) {
    final attrs = PlayerCardData.attributes;
    final white = Colors.white;

    return Container(
      width: PlayerCard.width,
      height: PlayerCard.height,
      decoration: _cardDecoration(),
      child: Stack(
        children: [
          // Faint diagonal sheen, like foil.
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: CustomPaint(painter: _SheenPainter()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
            // Scales down rather than overflowing if text renders larger
            // than expected (bigger fonts, user zoom).
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: SizedBox(
                width: PlayerCard.width - 48,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onDoubleTap: onRatingDoubleTap,
                              child: Text(
                                '${PlayerCardData.overall}',
                                style: AppText.display.copyWith(
                                  fontSize: 64,
                                  height: 0.9,
                                  color: white,
                                ),
                              ),
                            ),
                            Text(
                              PlayerCardData.position,
                              style: AppText.display.copyWith(
                                fontSize: 22,
                                color: white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              PlayerCardData.role.toUpperCase(),
                              style: AppText.monoLabel.copyWith(
                                fontSize: 10,
                                color: white.withValues(alpha: 0.75),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _Badge(PlayerCardData.nation),
                            const SizedBox(height: 6),
                            _Badge(PlayerCardData.club.toUpperCase()),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Center(
                      child: Container(
                        width: 92,
                        height: 92,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: white.withValues(alpha: 0.08),
                          border: Border.all(
                            color: white.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          ProfileData.initials,
                          style: AppText.display.copyWith(
                            fontSize: 36,
                            color: white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        ProfileData.lastName.toUpperCase(),
                        style: AppText.display.copyWith(
                          fontSize: 28,
                          letterSpacing: 1,
                          color: white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(height: 1, color: white.withValues(alpha: 0.25)),
                    const SizedBox(height: 10),
                    AnimatedSwitcher(
                      duration: AppMotion.hover,
                      child: showForm
                          ? _FormStrip(key: const ValueKey('form'))
                          : _AttrGrid(
                              key: const ValueKey('attrs'),
                              attrs: attrs,
                            ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        'TAP TO FLIP',
                        style: AppText.monoLabel.copyWith(
                          fontSize: 9,
                          color: white.withValues(alpha: 0.55),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttrGrid extends StatelessWidget {
  final List<(String, String, int)> attrs;

  const _AttrGrid({super.key, required this.attrs});

  @override
  Widget build(BuildContext context) {
    Widget cell((String, String, int) a) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              '${a.$3}',
              style: AppText.mono.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          Text(
            a.$1,
            style: AppText.mono.copyWith(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
    final half = (attrs.length / 2).ceil();
    return Row(
      children: [
        Expanded(
          child: Column(children: [for (final a in attrs.take(half)) cell(a)]),
        ),
        Container(
          width: 1,
          height: 70,
          color: Colors.white.withValues(alpha: 0.25),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(children: [for (final a in attrs.skip(half)) cell(a)]),
        ),
      ],
    );
  }
}

/// Hidden form guide: double-click the rating.
class _FormStrip extends StatelessWidget {
  const _FormStrip({super.key});

  @override
  Widget build(BuildContext context) {
    Color colorFor(String r) => switch (r) {
      'W' => AppColors.online,
      'D' => AppColors.textMuted,
      _ => const Color(0xFFFF5A5F),
    };
    return SizedBox(
      height: 78,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'FORM · LAST 5',
            style: AppText.monoLabel.copyWith(
              fontSize: 10,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < PlayerCardData.form.length; i++)
                Container(
                  width: 30,
                  height: 30,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colorFor(PlayerCardData.form[i]),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    PlayerCardData.form[i],
                    style: AppText.mono.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.night,
                    ),
                  ),
                ).animate().scaleXY(
                  begin: 0,
                  end: 1,
                  delay: (50 * i).ms,
                  duration: 300.ms,
                  curve: AppMotion.spring,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;

  const _Badge(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: AppText.mono.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _CardBack extends StatelessWidget {
  /// Bumped on each flip so the bars refill every time.
  final int run;

  const _CardBack({super.key, required this.run});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: PlayerCard.width,
      height: PlayerCard.height,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      decoration: _cardDecoration().copyWith(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF07326A), Color(0xFF021A38)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'ATTRIBUTES',
                style: AppText.monoLabel.copyWith(color: Colors.white),
              ),
              const Spacer(),
              Text(
                'OVR ${PlayerCardData.overall}',
                style: AppText.mono.copyWith(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          for (var i = 0; i < PlayerCardData.attributes.length; i++) ...[
            _AttrBar(
              key: ValueKey('$run-$i'),
              attr: PlayerCardData.attributes[i],
              delay: Duration(milliseconds: 150 + 60 * i),
            ),
            const SizedBox(height: 14),
          ],
          const Spacer(),
          Center(
            child: Text(
              'TAP TO FLIP BACK',
              style: AppText.monoLabel.copyWith(
                fontSize: 9,
                color: Colors.white54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttrBar extends StatelessWidget {
  final (String, String, int) attr;
  final Duration delay;

  const _AttrBar({super.key, required this.attr, required this.delay});

  @override
  Widget build(BuildContext context) {
    final (_, name, value) = attr;
    return Animate(
      delay: delay,
      effects: [
        CustomEffect(
          duration: 700.ms,
          curve: AppMotion.settle,
          builder: (context, t, _) => _bar(name, value, t),
        ),
      ],
      child: const SizedBox.shrink(),
    );
  }

  Widget _bar(String name, int value, double t) {
    final shown = (value * t).round();
    // Gold is reserved for trophies, so bars stay green and blue.
    final color = value >= 85 ? AppColors.online : AppColors.blue;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              name,
              style: AppText.body.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                height: 1.2,
              ),
            ),
            const Spacer(),
            Text(
              '$shown',
              style: AppText.mono.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: Stack(
            children: [
              Container(height: 6, color: Colors.white.withValues(alpha: 0.12)),
              FractionallySizedBox(
                widthFactor: value / 100 * t,
                child: Container(height: 6, color: color),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SheenPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.035);
    for (var x = -size.height; x < size.width; x += 18) {
      final path = Path()
        ..moveTo(x, size.height)
        ..lineTo(x + size.height, 0)
        ..lineTo(x + size.height + 7, 0)
        ..lineTo(x + 7, size.height)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_SheenPainter oldDelegate) => false;
}
