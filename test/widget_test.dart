// Smoke tests: the page builds without layout overflows at phone, tablet
// and desktop widths, and scrolls all the way to the bottom.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'package:portfolio/main.dart';
import 'package:portfolio/data/portfolio_data.dart';

void main() {
  // Fire visibility callbacks immediately instead of on a debounce timer.
  VisibilityDetectorController.instance.updateInterval = Duration.zero;

  for (final size in const [Size(390, 844), Size(820, 1180), Size(1440, 900)]) {
    testWidgets('${size.width.toInt()}px: builds and scrolls cleanly', (
      tester,
    ) async {
      await _pumpAt(tester, size);
      await _scrollToBottom(tester);
    });
  }
}

Future<void> _pumpAt(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(const PortfolioApp());
  await _settle(tester);
  expect(find.text(ProfileData.initials), findsOneWidget);
}

Future<void> _scrollToBottom(WidgetTester tester) async {
  await tester.drag(
    find.byType(SingleChildScrollView).first,
    const Offset(0, -30000),
  );
  await _settle(tester);
}

/// Some decorations loop forever (the status dot), so pumpAndSettle would
/// never return. Pump a few seconds of frames instead.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 30; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}
