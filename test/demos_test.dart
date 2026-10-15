// Behaviour tests for the live demos: they're the part visitors poke at.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:portfolio/demos/offline_sync_demo.dart';
import 'package:portfolio/demos/otp_demo.dart';

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
}
