// Smoke tests: the page builds without layout overflows at phone, tablet
// and desktop widths, and scrolls all the way to the bottom.

import 'package:flutter/services.dart';
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

  testWidgets('every project and demo tab renders without layout errors', (
    tester,
  ) async {
    await _pumpAt(tester, const Size(1440, 1050));
    await tester.tap(find.text('Work').first);
    await _settle(tester);

    for (final project in const [
      'NeoCash loan apps',
      'Event marketplace',
      'OTP boxes, done properly',
    ]) {
      await tester.tap(find.text(project));
      await _settle(tester);
    }
    // Projects with several demos: visit every tab except the map, which
    // needs real tiles.
    await tester.tap(find.text('NeoCash loan apps'));
    await _settle(tester);
    for (final tab in const ['Face check', 'Field app', 'Loan fix']) {
      await tester.tap(find.text(tab));
      await _settle(tester);
    }

    await tester.tap(find.text('Event marketplace'));
    await _settle(tester);
    for (final tab in const ['Chat', 'Calendar']) {
      await tester.tap(find.text(tab));
      await _settle(tester);
    }
  });

  testWidgets('nav links land on sections and reveal them', (tester) async {
    await _pumpAt(tester, const Size(1440, 1500));
    for (final (link, title) in const [
      ('Skills', 'Player profile'),
      ('Writing', 'Notes from the desk'),
      ('Contact', "Let's talk"),
    ]) {
      await tester.tap(find.text(link));
      await _settle(tester);
      final hidden = find.ancestor(
        of: find.text(title),
        matching: find.byWidgetPredicate((w) => w is Opacity && w.opacity == 0),
      );
      expect(hidden, findsNothing, reason: '$title should be revealed');
    }
  });

  testWidgets(
    'keyboard: arrows switch projects, ? opens controls, konami fires',
    (tester) async {
      await _pumpAt(tester, const Size(1440, 900));

      // Left from the first project wraps to the last one (the OTP demo).
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await _settle(tester);
      expect(find.text('Verify your number'), findsOneWidget);

      // Shift + / types "?".
      await tester.sendKeyDownEvent(LogicalKeyboardKey.slash, character: '?');
      await tester.sendKeyUpEvent(LogicalKeyboardKey.slash);
      await _settle(tester);
      expect(find.text('Controls'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await _settle(tester);
      expect(find.text('Controls'), findsNothing);

      for (final key in const [
        LogicalKeyboardKey.arrowUp,
        LogicalKeyboardKey.arrowUp,
        LogicalKeyboardKey.arrowDown,
        LogicalKeyboardKey.arrowDown,
        LogicalKeyboardKey.arrowLeft,
        LogicalKeyboardKey.arrowRight,
        LogicalKeyboardKey.arrowLeft,
        LogicalKeyboardKey.arrowRight,
        LogicalKeyboardKey.keyB,
        LogicalKeyboardKey.keyA,
      ]) {
        await tester.sendKeyEvent(key);
      }
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('Blue is the colour'), findsOneWidget);
      await _settle(tester); // let the confetti and toast clean up
    },
  );
}

Future<void> _pumpAt(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(const PortfolioApp());
  await _settle(tester);
  expect(find.text(ProfileData.initials), findsWidgets);
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
