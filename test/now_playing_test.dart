import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/services/football.dart';
import 'package:portfolio/theme/app_theme.dart';
import 'package:portfolio/widgets/now_playing.dart';

void main() {
  test('fixtures read from Chelsea\'s point of view', () {
    final home = Fixture.fromJson(const {
      'strHomeTeam': 'Chelsea',
      'strAwayTeam': 'Bournemouth',
      'intHomeScore': '5',
      'intAwayScore': '1',
      'strLeague': 'English Premier League',
      'strVenue': 'Stamford Bridge',
      'strTimestamp': '2026-10-10T14:00:00',
    });
    expect(home.played, isTrue);
    expect(home.shortFor('Chelsea'), 'W 5–1 vs Bournemouth');
    expect(home.competition, 'Premier League');
    expect(home.kickoff.isUtc, isTrue);

    final away = Fixture.fromJson(const {
      'strHomeTeam': 'Arsenal',
      'strAwayTeam': 'Chelsea',
      'intHomeScore': '2',
      'intAwayScore': '0',
      'strTimestamp': '2026-09-01T16:30:00',
    });
    expect(away.shortFor('Chelsea'), 'L 0–2 at Arsenal');

    final upcoming = Fixture.fromJson(const {
      'strHomeTeam': 'Everton',
      'strAwayTeam': 'Chelsea',
      'intHomeScore': null,
      'intAwayScore': null,
      'strTimestamp': '2026-10-17T11:30:00',
    });
    expect(upcoming.played, isFalse);
  });

  testWidgets('playlist asset loads with previews', (tester) async {
    final playlist = await tester.runAsync(Playlist.load);
    expect(playlist, isNotNull);
    expect(playlist!.tracks, isNotEmpty);
    expect(playlist.tracks.every((t) => t.preview != null), isTrue);
  });

  testWidgets('hover previews a panel, click pins it, leaving keeps the pin', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: const Scaffold(
          body: Padding(padding: EdgeInsets.all(40), child: NowPlayingStrip()),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    await mouse.addPointer(location: const Offset(1190, 890));

    // Hovering "learning" previews its panel.
    await mouse.moveTo(tester.getCenter(find.text('LEARNING')));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('CURRENTLY LEARNING'), findsOneWidget);

    // Moving off the strip closes an unpinned preview.
    await mouse.moveTo(const Offset(1190, 890));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('CURRENTLY LEARNING'), findsNothing);

    // Clicking pins it; it stays after the mouse leaves.
    final learning = tester.getCenter(find.text('LEARNING'));
    await mouse.moveTo(learning);
    await tester.pump();
    await mouse.down(learning);
    await tester.pump(const Duration(milliseconds: 50));
    await mouse.up();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('CURRENTLY LEARNING'), findsOneWidget);
    expect(find.text('CLICK TO CLOSE'), findsOneWidget);
    await mouse.moveTo(const Offset(1190, 890));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('CURRENTLY LEARNING'), findsOneWidget);
  });

  testWidgets('panel sits under its tile and stays on the page', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: const Scaffold(
          body: Padding(padding: EdgeInsets.all(40), child: NowPlayingStrip()),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    await mouse.addPointer(location: const Offset(1190, 890));

    // Strip is 1120 wide: four 272.5px tiles with 10px gaps, starting at x=40.
    const tileWidth = (1120 - 30) / 4;
    final caret = find.byWidgetPredicate(
      (w) => w is CustomPaint && w.size == const Size(18, 9),
    );

    for (final (i, label) in const [
      'CHESS.COM',
      'SPOTIFY',
      'CHELSEA',
      'LEARNING',
    ].indexed) {
      await mouse.moveTo(tester.getCenter(find.text(label)));
      // One frame to start the glide, then let it finish.
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      final tileCentre = 40 + i * (tileWidth + 10) + tileWidth / 2;
      expect(
        tester.getCenter(caret).dx,
        moreOrLessEquals(tileCentre, epsilon: 1),
        reason: 'caret under $label',
      );

      final panel = tester.getRect(
        find.ancestor(of: caret, matching: find.byType(Stack)).first,
      );
      expect(panel.left, greaterThanOrEqualTo(40 - 0.5), reason: label);
      expect(panel.right, lessThanOrEqualTo(1160 + 0.5), reason: label);
    }
  });
}
