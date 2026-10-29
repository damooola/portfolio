// The "Hot reload" site: it builds without layout errors at every width,
// the code really drives the page, and phones get the page plus a source
// sheet.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'package:portfolio/ide/chrome.dart';
import 'package:portfolio/ide/controller.dart';
import 'package:portfolio/ide/shell.dart';
import 'package:portfolio/main.dart';
import 'package:portfolio/widgets/writing_section.dart';

void main() {
  // Fire visibility callbacks immediately instead of on a debounce timer.
  VisibilityDetectorController.instance.updateInterval = Duration.zero;

  test(
    'writing shows featured posts first, then the newest, capped at six',
    () {
      Article a(String title, String date) => Article(
        title: title,
        url: 'https://example.com/$title',
        platform: 'Hashnode',
        snippet: '',
        readMinutes: 5,
        date: date,
      );
      final all = [
        a('Newest', '2026-09-01'),
        a('The OTP Boxes That Would Not Let Go', '2026-06-01'),
        for (var i = 0; i < 8; i++) a('Old $i', '2026-0${i % 5 + 1}-01'),
      ];
      final picked = WritingSection.pick(all);
      expect(picked.length, WritingSection.shownCount);
      expect(picked.first.title, 'The OTP Boxes That Would Not Let Go');
      expect(picked[1].title, 'Newest');
    },
  );

  for (final size in const [
    Size(360, 740), // small phone
    Size(390, 844), // phone
    Size(1024, 768), // laptop: no widget tree
    Size(1440, 900), // desktop
    Size(1920, 1080),
  ]) {
    testWidgets(
      '${size.width.toInt()}×${size.height.toInt()}: builds and scrolls cleanly',
      (tester) async {
        await _pump(tester, size, const PortfolioApp());
        await tester.drag(_page(), const Offset(0, -40000));
        await _settle(tester);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('clicking values in the code changes the page', (tester) async {
    final c = IdeController();
    await _pump(tester, const Size(1600, 1000), _app(c));

    // Theme: paper → night.
    await tester.tap(find.text('paper'));
    await _settle(tester);
    expect(c.value('theme'), 'night');
    expect(find.text('night'), findsOneWidget);

    // Name: the page swaps to the handle.
    await tester.tap(find.text("'Damola Nelson'"));
    await _settle(tester);
    expect(find.textContaining('damooola', findRichText: true), findsWidgets);

    // Web joins the platforms.
    expect(find.text('Web'), findsNothing);
    await tester.tap(find.text('false').first);
    await _settle(tester);
    expect(find.text('Web'), findsOneWidget);

    // Every change logs a hot reload.
    expect(c.logs.where((l) => l.text.startsWith('Reloaded')).length, 3);
  });

  testWidgets('airplaneMode in work.dart takes the field app offline', (
    tester,
  ) async {
    final c = IdeController();
    await _pump(tester, const Size(1600, 1000), _app(c));
    await tester.tap(find.text('work.dart').first);
    await _settle(tester);
    expect(c.file, SourceFile.work);

    await tester.tap(find.text('false').first);
    await _settle(tester);
    expect(c.flag('airplane'), isTrue);
    expect(c.airplane.value, isTrue);
    expect(find.textContaining('airplaneMode: true'), findsWidgets);
  });

  testWidgets('tabs, keys and reading mode', (tester) async {
    final c = IdeController();
    await _pump(tester, const Size(1600, 1000), _app(c));

    await tester.tap(find.text('career.log'));
    await _settle(tester);
    expect(c.file, SourceFile.career);
    expect(c.section, 'career');

    await tester.sendKeyDownEvent(LogicalKeyboardKey.keyR, character: 'r');
    await tester.sendKeyUpEvent(LogicalKeyboardKey.keyR);
    await _settle(tester);
    expect(c.logs.last.text, startsWith('Reloaded 0 of 412'));

    await tester.tap(find.text('Read normally'));
    await _settle(tester);
    expect(c.reading, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('panes collapse, restore and resize like VS Code', (
    tester,
  ) async {
    final c = IdeController();
    await _pump(tester, const Size(1600, 1000), _app(c));
    // The pane is the AnimatedContainer around the tree; its content keeps
    // full width inside the clip while the pane animates.
    double width(Finder f) => tester
        .getSize(
          find.ancestor(of: f, matching: find.byType(AnimatedContainer)).first,
        )
        .width;

    // Hide the widget tree, then bring it back from the activity bar.
    expect(find.text('WIDGET TREE'), findsOneWidget);
    await tester.tap(find.byTooltip('Hide widget tree'));
    await _settle(tester);
    expect(width(find.byType(WidgetTree)), lessThan(1));
    await tester.tap(find.byTooltip('Widget tree'));
    await _settle(tester);
    expect(width(find.byType(WidgetTree)), greaterThan(100));

    // Hide and restore the console.
    await tester.tap(find.byTooltip('Hide console'));
    await _settle(tester);
    expect(find.byType(DebugConsole), findsNothing);
    await tester.tap(find.byTooltip('Debug console'));
    await _settle(tester);
    expect(find.byType(DebugConsole), findsOneWidget);

    // Drag the divider between the tree and the editor.
    final before = width(find.byType(WidgetTree));
    final tree = tester.getRect(
      find
          .ancestor(
            of: find.byType(WidgetTree),
            matching: find.byType(AnimatedContainer),
          )
          .first,
    );
    await tester.dragFrom(Offset(tree.right + 2, 400), const Offset(80, 0));
    await _settle(tester);
    // Flutter keeps the first ~20px as drag slop, so expect most of the 80.
    expect(width(find.byType(WidgetTree)), greaterThan(before + 50));

    // Page only, then back.
    await tester.tap(find.byTooltip('Page only (read normally)'));
    await _settle(tester);
    expect(c.reading, isTrue);
    await tester.tap(find.byTooltip('Show the code again'));
    await _settle(tester);
    expect(c.reading, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('phones get the page, and the source slides up', (tester) async {
    final c = IdeController();
    await _pump(tester, const Size(390, 844), _app(c));
    expect(find.text('WIDGET TREE'), findsNothing);

    await tester.tap(find.text('Source'));
    await _settle(tester);
    expect(find.text('main.dart'), findsOneWidget);

    // A value near the top is in view straight away.
    await tester.tap(find.text("'Damola Nelson'"));
    await _settle(tester);
    expect(c.value('name'), 'damooola');

    // Scroll the sheet's code to reach the theme line.
    await tester.scrollUntilVisible(
      find.text('paper'),
      120,
      scrollable: find
          .descendant(
            of: find.byType(BottomSheet),
            matching: find.byType(Scrollable),
          )
          .at(1),
    );
    await tester.tap(find.text('paper'));
    await _settle(tester);
    expect(c.value('theme'), 'night');
    expect(tester.takeException(), isNull);
  });
}

Widget _app(IdeController c) => MaterialApp(home: IdeShell(controller: c));

Finder _page() => find.byType(SingleChildScrollView).first;

Future<void> _pump(WidgetTester tester, Size size, Widget app) async {
  // Like the live site: every font must come from the bundled assets.
  GoogleFonts.config.allowRuntimeFetching = false;
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(app);
  await _settle(tester);
}

/// Some decorations loop forever (the status dot), so pumpAndSettle would
/// never return. Pump a few seconds of frames instead.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 30; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}
