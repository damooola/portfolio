import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens for the portfolio site. Keep every color, font, and
/// spacing value here — nothing hardcoded in widgets — so the whole
/// site stays visually consistent and easy to retheme from one place.
class AppColors {
  AppColors._();

  static const ink = Color(0xFF5A0F1F); // primary text, near-black
  static const inkMuted = Color(0xFF7A1F2B); // secondary text, borders
  static const rose = Color(0xFFA74753); // tags, hover states
  static const sage = Color(0xFF7FB8A6); // accent: fills, CTAs, on-dark text
  static const sageDeep = Color(0xFF3D7A67); // sage for text/icons on cream (contrast)
  static const cream = Color(0xFFF2EFE8); // background
  static const creamDeep = Color(0xFFE8E2D6); // card surfaces, subtle contrast
  static const hairline = Color(0x335A0F1F); // ink @ 20% — rules, borders
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
  static double contentWidth(double width) =>
      width < desktop ? width : desktop;
}

class AppText {
  AppText._();

  static TextStyle get display => GoogleFonts.fraunces(
        color: AppColors.ink,
        fontWeight: FontWeight.w600,
        height: 1.05,
        letterSpacing: -0.5,
      );

  static TextStyle get heading => GoogleFonts.fraunces(
        color: AppColors.ink,
        fontWeight: FontWeight.w600,
        height: 1.15,
      );

  static TextStyle get body => GoogleFonts.inter(
        color: AppColors.ink,
        fontWeight: FontWeight.w400,
        height: 1.6,
      );

  static TextStyle get bodyMuted => GoogleFonts.inter(
        color: AppColors.inkMuted,
        fontWeight: FontWeight.w400,
        height: 1.6,
      );

  /// Numbers and figures. Tabular digits so columns of figures line up
  /// the way they do on a bank statement.
  static TextStyle get mono => GoogleFonts.jetBrainsMono(
        color: AppColors.ink,
        fontWeight: FontWeight.w500,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  /// Small all-caps labels: section indexes, ledger keys, card fields.
  static TextStyle get monoLabel => GoogleFonts.jetBrainsMono(
        color: AppColors.inkMuted,
        fontWeight: FontWeight.w500,
        fontSize: 12,
        letterSpacing: 1.4,
        fontFeatures: const [FontFeature.tabularFigures()],
      );
}

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.cream,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.sage,
      brightness: Brightness.light,
      surface: AppColors.cream,
    ),
    textTheme: GoogleFonts.interTextTheme(),
  );
}
