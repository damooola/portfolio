import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../data/portfolio_data.dart';
import '../theme/app_theme.dart';
import 'ledger_lines.dart';
import 'responsive_section.dart';
import 'section_header.dart';

class WorkSection extends StatelessWidget {
  const WorkSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobile(MediaQuery.of(context).size.width);
    final projects = ProjectsData.projects;

    return ResponsiveSection(
      background: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            index: '03',
            title: 'Work',
            caption: 'Things I\'ve built — receipts included.',
          ),
          for (var i = 0; i < projects.length; i++) ...[
            // Receipts alternate sides and tilt slightly, like they've been
            // pinned to a board. Straight and full-width on phones.
            Align(
              alignment: isMobile || i.isEven ? Alignment.centerLeft : Alignment.centerRight,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Transform.rotate(
                  angle: isMobile ? 0 : (i.isEven ? -0.006 : 0.006),
                  child: _Receipt(project: projects[i], number: i + 1),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          Center(
            child: Text(
              '*** THANK YOU FOR YOUR PATRONAGE ***',
              textAlign: TextAlign.center,
              style: AppText.monoLabel.copyWith(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

class _Receipt extends StatefulWidget {
  final Project project;
  final int number;

  const _Receipt({required this.project, required this.number});

  @override
  State<_Receipt> createState() => _ReceiptState();
}

class _ReceiptState extends State<_Receipt> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final project = widget.project;
    final isMobile = AppBreakpoints.isMobile(MediaQuery.of(context).size.width);
    final txn = 'TXN-${widget.number.toString().padLeft(3, '0')}';

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _hover ? -6 : 0, 0),
        decoration: ShapeDecoration(
          color: AppColors.night,
          shape: const ReceiptBorder(),
          shadows: [
            BoxShadow(
              color: AppColors.text.withValues(alpha: _hover ? 0.16 : 0.08),
              blurRadius: _hover ? 32 : 16,
              offset: Offset(0, _hover ? 16 : 6),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? AppSpacing.md : AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.blue.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(project.icon, size: 18, color: AppColors.text),
                  ),
                  const SizedBox(width: 12),
                  Text(txn, style: AppText.monoLabel),
                  const Spacer(),
                  if (project.period != null)
                    Text(project.period!, style: AppText.monoLabel),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                project.title,
                style: AppText.heading.copyWith(fontSize: isMobile ? 24 : 30),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(project.description, style: AppText.bodyMuted.copyWith(fontSize: 16)),
              const SizedBox(height: AppSpacing.md),
              const DashedDivider(),
              const SizedBox(height: AppSpacing.md),
              for (var i = 0; i < project.highlights.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 36,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Text(
                            (i + 1).toString().padLeft(2, '0'),
                            style: AppText.mono.copyWith(fontSize: 13, color: AppColors.blue),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          project.highlights[i],
                          style: AppText.body.copyWith(fontSize: 15.5),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: AppSpacing.xs),
              const DashedDivider(),
              const SizedBox(height: AppSpacing.xs),
              DotLeaderRow(label: 'ROLE', value: project.role),
              DotLeaderRow(label: 'STACK', value: project.tags.join(' · ')),
              if (project.status != null)
                DotLeaderRow(
                  label: 'STATUS',
                  value: '● ${project.status}',
                  valueStyle: AppText.body.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.blue,
                  ),
                ),
              const SizedBox(height: AppSpacing.md),
              Center(
                child: SizedBox(
                  width: 180,
                  height: 34,
                  child: CustomPaint(painter: _BarcodePainter(seed: project.title)),
                ),
              ),
            ],
          ),
        ),
      ),
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
      ..arcToPoint(Offset(rect.left + radius, rect.top), radius: Radius.circular(radius))
      ..lineTo(rect.right - radius, rect.top)
      ..arcToPoint(Offset(rect.right, rect.top + radius), radius: Radius.circular(radius))
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
  ShapeBorder scale(double t) => ReceiptBorder(tooth: tooth * t, radius: radius * t);
}

/// Decorative barcode. Bar widths are derived from [seed] so each receipt
/// gets its own stable pattern.
class _BarcodePainter extends CustomPainter {
  final String seed;

  _BarcodePainter({required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.text.withValues(alpha: 0.75);
    final codes = seed.codeUnits;
    var x = 0.0;
    var i = 0;
    while (x < size.width) {
      final c = codes[i % codes.length] + i;
      final bar = 1.0 + (c % 3);
      final gap = 1.0 + ((c >> 2) % 3);
      if (x + bar > size.width) break;
      canvas.drawRect(Rect.fromLTWH(x, 0, bar, size.height), paint);
      x += bar + gap;
      i++;
    }
  }

  @override
  bool shouldRepaint(_BarcodePainter old) => old.seed != seed;
}
