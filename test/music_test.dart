import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/services/music.dart';
import 'package:portfolio/theme/app_theme.dart';
import 'package:portfolio/widgets/nav_bar.dart';

void main() {
  testWidgets('nav pill only appears while music is active', (tester) async {
    final music = PlaylistController.instance;
    await tester.runAsync(music.load);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: const Scaffold(body: Center(child: NowPlayingPill())),
      ),
    );
    await tester.pump();
    final firstTitle = music.playlist!.tracks.first.title;
    expect(find.text(firstTitle), findsNothing);

    // Simulate a song mid-play (the audio plugin isn't available in tests).
    music
      ..playing = true
      ..position = const Duration(seconds: 5)
      ..notifyListeners();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text(firstTitle), findsOneWidget);
    expect(find.byTooltip('Pause music'), findsOneWidget);

    music
      ..playing = false
      ..position = Duration.zero
      ..notifyListeners();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text(firstTitle), findsNothing);
  });
}
