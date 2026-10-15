import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens for the portfolio site. Keep every color, font, and
/// spacing value here — nothing hardcoded in widgets — so the whole
/// site stays visually consistent and easy to retheme from one place.
///
/// "After Hours": night navy, one royal-blue accent, gold only for trophies.
class AppColors {
  AppColors._();

  static const night = Color(0xFF0A0F1E); // page background
  static const surface = Color(0xFF111831); // cards, phone frame body
  static const raised = Color(0xFF19223F); // hovered cards, popovers
  static const line = Color(0x14FFFFFF); // white @ 8% — borders, dividers
  static const text = Color(0xFFE9EDF7); // main text
  static const textMuted = Color(0xFF8B94AE); // captions, labels
  static const blue = Color(0xFF3D6BFF); // accent: links, focus, cursor glow
  static const blueDeep = Color(0xFF034694); // Chelsea royal blue: big fills
  static const gold = Color(0xFFF2C14E); // trophies only
  static const online = Color(0xFF4ADE80); // sync and status dots
}

class AppSpacing {
  AppSpacing._();

  static const xs = 8.0;
  static const sm = 16.0;
  static const md = 24.0;
  static const lg = 40.0;
  static const xl = 64.0;
  static const xxl = 96.0;
}

class AppBreakpoints {
  AppBreakpoints._();

  static const mobile = 600.0;
  static const tablet = 960.0;
  static const desktop = 1200.0;

  static bool isMobile(double width) => width < mobile;
  static bool isTablet(double width) => width >= mobile && width < desktop;
  static bool isDesktop(double width) => width >= desktop;

  /// Max content width so text doesn't stretch edge-to-edge on wide screens.
  static double contentWidth(double width) => width < desktop ? width : desktop;
}

/// Springy, physical motion. Hovers are quick; big moves overshoot a little.
class AppMotion {
  AppMotion._();

  static const hover = Duration(milliseconds: 180);
  static const big = Duration(milliseconds: 450);
  static const stagger = Duration(milliseconds: 50);
  static const spring = Curves.easeOutBack;
  static const settle = Curves.easeOutCubic;

  /// True when the visitor asked the OS for less motion. Swap movement
  /// for fades when this is on.
  static bool reduced(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;
}

class AppText {
  AppText._();

  /// Hero name, section titles, player-card rating.
  static TextStyle get display => GoogleFonts.bricolageGrotesque(
    color: AppColors.text,
    fontWeight: FontWeight.w800,
    height: 1.0,
    letterSpacing: -0.5,
  );

  static TextStyle get heading => GoogleFonts.bricolageGrotesque(
    color: AppColors.text,
    fontWeight: FontWeight.w700,
    height: 1.15,
  );

  static TextStyle get body => GoogleFonts.geist(
    color: AppColors.text,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  static TextStyle get bodyMuted => GoogleFonts.geist(
    color: AppColors.textMuted,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  /// Numbers and status lines. Tabular digits so figures line up.
  static TextStyle get mono => GoogleFonts.geistMono(
    color: AppColors.text,
    fontWeight: FontWeight.w500,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  /// Small all-caps labels: section indexes, card fields, key hints.
  static TextStyle get monoLabel => GoogleFonts.geistMono(
    color: AppColors.textMuted,
    fontWeight: FontWeight.w500,
    fontSize: 12,
    letterSpacing: 1.2,
    fontFeatures: const [FontFeature.tabularFigures()],
  );
}

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.night,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.blue,
      brightness: Brightness.dark,
      primary: AppColors.blue,
      surface: AppColors.surface,
    ),
    textTheme: GoogleFonts.geistTextTheme(ThemeData.dark().textTheme),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: AppColors.blue,
      selectionColor: AppColors.blue.withValues(alpha: 0.35),
    ),
  );
}
