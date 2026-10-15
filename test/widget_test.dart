// Smoke tests: the page builds without layout overflows at phone, tablet
// and desktop widths, and scrolls all the way to the bottom.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:portfolio/main.dart';
import 'package:portfolio/data/portfolio_data.dart';

void main() {
  for (final size in const [Size(390, 844), Size(820, 1180), Size(1440, 900)]) {
    testWidgets('${size.width.toInt()}px: builds and scrolls cleanly', (tester) async {
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
  await tester.pump();
  expect(find.textContaining(ProfileData.name.split(' ').first), findsWidgets);
}

Future<void> _scrollToBottom(WidgetTester tester) async {
  await tester.drag(find.byType(SingleChildScrollView).first, const Offset(0, -30000));
  await tester.pumpAndSettle();
}
