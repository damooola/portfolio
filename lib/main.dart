import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'ide/shell.dart';
import 'ide/tokens.dart';
import 'services/sfx.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // All fonts ship with the site (assets/fonts, assets/google_fonts), so
  // nothing waits on a font CDN and text never swaps mid-load.
  GoogleFonts.config.allowRuntimeFetching = false;
  // The demos still have their little sounds; they stay off by default.
  await Sfx.init();
  runApp(const PortfolioApp());
}

class PortfolioApp extends StatelessWidget {
  const PortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    // The demos inside the phones keep the dark app theme they were built in;
    // the IDE and page style themselves from ide/tokens.dart.
    final base = buildAppTheme();
    return MaterialApp(
      title: 'Damola Nelson · Flutter mobile engineer',
      debugShowCheckedModeBanner: false,
      theme: base.copyWith(
        scaffoldBackgroundColor: Ide.bg,
        scrollbarTheme: ScrollbarThemeData(
          thickness: WidgetStateProperty.all(6),
          radius: const Radius.circular(6),
          thumbColor: WidgetStateProperty.resolveWith(
            (s) => Colors.white.withValues(alpha: s.contains(WidgetState.hovered) ? 0.28 : 0.16),
          ),
        ),
        tooltipTheme: TooltipThemeData(
          decoration: BoxDecoration(
            color: Ide.raised,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Ide.line),
          ),
          textStyle: Txt.mono(11.5, color: Ide.text),
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        ),
      ),
      // This is a website: arrow keys scroll, like Flutter's web defaults,
      // rather than hopping focus between widgets.
      shortcuts: {
        ...WidgetsApp.defaultShortcuts,
        const SingleActivator(LogicalKeyboardKey.arrowUp): const ScrollIntent(direction: AxisDirection.up),
        const SingleActivator(LogicalKeyboardKey.arrowDown): const ScrollIntent(direction: AxisDirection.down),
        const SingleActivator(LogicalKeyboardKey.arrowLeft): const ScrollIntent(direction: AxisDirection.left),
        const SingleActivator(LogicalKeyboardKey.arrowRight): const ScrollIntent(direction: AxisDirection.right),
      },
      home: const IdeShell(),
    );
  }
}
