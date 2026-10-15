// Behaviour tests for the live demos: they're the part visitors poke at.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:portfolio/demos/offline_sync_demo.dart';
import 'package:portfolio/demos/otp_demo.dart';
import 'package:portfolio/demos/chat_demo.dart';
import 'package:portfolio/demos/planner_demo.dart';

Future<void> _pumpDemo(WidgetTester tester, Widget demo) async {
  tester.view.physicalSize = const Size(320, 640);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(home: Scaffold(body: demo)));
  await tester.pump(const Duration(seconds: 1));
}

Future<void> _advance(WidgetTester tester, Duration total) async {
  for (
    var t = Duration.zero;
    t < total;
    t += const Duration(milliseconds: 50)
  ) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  testWidgets(
    'offline sync: queues while offline, retries once, then syncs all',
    (tester) async {
      await _pumpDemo(tester, const OfflineSyncDemo());
      expect(find.text('SYNCED'), findsNWidgets(2));

      await tester.tap(find.byIcon(Icons.airplanemode_active));
      await tester.pump();
      await tester.tap(find.text('Add customer'));
      await tester.tap(find.text('Add customer'));
      await _advance(tester, const Duration(milliseconds: 600));

      expect(find.text('PENDING'), findsNWidgets(2));
      expect(find.text('offline · 2 queued'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.airplanemode_active));
      await _advance(tester, const Duration(milliseconds: 800));
      expect(
        find.text('TIMEOUT'),
        findsOneWidget,
        reason: 'one simulated failure',
      );

      await _advance(tester, const Duration(seconds: 4));
      expect(find.text('PENDING'), findsNothing);
      expect(find.text('TIMEOUT'), findsNothing);
      expect(find.text('SYNCED'), findsNWidgets(4));
      expect(find.text('online · outbox empty'), findsOneWidget);
    },
  );

  testWidgets('otp: wrong code shakes and clears, pasted code verifies', (
    tester,
  ) async {
    await _pumpDemo(tester, const OtpDemo());

    Finder key(String d) =>
        find.descendant(of: find.byType(InkWell), matching: find.text(d));
    for (var i = 0; i < OtpDemo.length; i++) {
      await tester.tap(key('1'));
      await tester.pump();
    }
    await _advance(tester, const Duration(milliseconds: 300));
    expect(find.text("That code doesn't match"), findsOneWidget);

    await _advance(tester, const Duration(milliseconds: 800));
    expect(find.text("That code doesn't match"), findsNothing);

    await tester.tap(find.text('Paste'));
    await _advance(tester, const Duration(seconds: 1));
    expect(find.text('Verified'), findsOneWidget);
  });

  test(
    'planner: overlapping tasks share columns, separate ones get full width',
    () {
      PlannerTask t(int id, int start, int end) =>
          PlannerTask(id, 'T$id', start, end, Colors.blue);
      final placed = {
        for (final p in layoutTasks([
          t(1, 540, 630), // 9:00–10:30
          t(2, 570, 615), // 9:30–10:15, overlaps 1
          t(3, 600, 660), // 10:00–11:00, overlaps 1 (2 still busy)
          t(4, 720, 780), // 12:00–13:00, alone
        ]))
          p.task.id: p,
      };
      expect(placed[1]!.columns, 3);
      expect(
        {placed[1]!.column, placed[2]!.column, placed[3]!.column},
        {0, 1, 2},
      );
      expect(placed[4]!.columns, 1);
      expect(placed[4]!.column, 0);

      // A task that starts as another ends reuses its column.
      final chain = layoutTasks([
        t(1, 540, 600),
        t(2, 570, 630),
        t(3, 600, 660),
      ]);
      final byId = {for (final p in chain) p.task.id: p};
      expect(byId[3]!.column, byId[1]!.column);
      expect(byId[1]!.columns, 2);
    },
  );

  testWidgets("planner: viewers can't add tasks, creators can", (tester) async {
    await _pumpDemo(tester, const PlannerDemo());
    expect(find.text('6 TASKS · DAY VIEW'), findsOneWidget);

    await tester.tap(find.text('Viewer'));
    await _advance(tester, const Duration(milliseconds: 400));
    await tester.tap(find.text('Task'));
    await _advance(tester, const Duration(milliseconds: 400));
    expect(find.text('6 TASKS · DAY VIEW'), findsOneWidget);

    await tester.tap(find.text('Creator'));
    await _advance(tester, const Duration(milliseconds: 400));
    await tester.tap(find.text('Task'));
    await _advance(tester, const Duration(milliseconds: 600));
    expect(find.text('7 TASKS · DAY VIEW'), findsOneWidget);
  });

  testWidgets('chat: offline messages queue, then send in order once back', (
    tester,
  ) async {
    await _pumpDemo(tester, const ChatDemo());

    await tester.tap(find.byIcon(Icons.wifi));
    await _advance(tester, const Duration(milliseconds: 300));
    await tester.tap(find.text('Can you do 200 guests?'));
    await tester.enterText(find.byType(TextField), 'See you Saturday');
    await tester.tap(find.byIcon(Icons.send_rounded));
    await _advance(tester, const Duration(milliseconds: 300));
    expect(find.text('queued'), findsNWidgets(2));
    expect(find.textContaining('2 queued'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.wifi_off));
    await _advance(tester, const Duration(milliseconds: 300));
    expect(find.text('reconnecting…'), findsOneWidget);

    await _advance(tester, const Duration(seconds: 6));
    expect(find.text('queued'), findsNothing);
    expect(find.text('read'), findsNWidgets(3)); // two new + one from before
    expect(
      find.text("Yes, 200 is fine. I'll bring extra centrepieces."),
      findsOneWidget,
    );
  });
}
