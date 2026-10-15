// Smoke tests: the page builds without layout overflows at phone, tablet
// and desktop widths, and the scroll readout moves when you scroll.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:portfolio/main.dart';
import 'package:portfolio/data/portfolio_data.dart';

void main() {
  testWidgets('phone: percentage pill reads 100% at the bottom', (tester) async {
    await _pumpAt(tester, const Size(390, 844));
    expect(find.text('000%'), findsOneWidget);

    await _scrollToBottom(tester);
    expect(find.text('100%'), findsOneWidget);
  });

  for (final size in const [Size(820, 1180), Size(1440, 900)]) {
    testWidgets('${size.width.toInt()}px: ruler tracks scroll offset', (tester) async {
      await _pumpAt(tester, size);
      expect(find.text('0000'), findsOneWidget);

      await _scrollToBottom(tester);
      expect(find.text('0000'), findsNothing);
    });
  }
}

Future<void> _pumpAt(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(const PortfolioApp());
  await tester.pump();
  expect(find.text(ProfileData.name), findsWidgets);
}

Future<void> _scrollToBottom(WidgetTester tester) async {
  await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -30000));
  await tester.pumpAndSettle();
}
