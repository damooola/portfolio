import 'package:flutter/widgets.dart';

/// Design tokens for the "Hot reload" site: a Flutter IDE shell around the
/// page it builds. The IDE chrome is always dark; the page takes whichever
/// [PageTheme] is set in main.dart (paper, night or lagos).
abstract final class Ide {
  static const bg = Color(0xFF0B0D11);
  static const panel = Color(0xFF0F1218);
  static const raised = Color(0xFF161B24);
  static const hover = Color(0x08FFFFFF);
  static const line = Color(0x12FFFFFF);
  static const text = Color(0xFFC9CFDA);
  static const bright = Color(0xFFF1F4F9);
  static const dim = Color(0xFF5D6577);
  static const gutter = Color(0xFF353C4C);
  static const flutter = Color(0xFF3D8BFF);
  static const flutterSoft = Color(0x1F3D8BFF);

  // Syntax (a calm take on Material Theme Palenight).
  static const keyword = Color(0xFFC792EA);
  static const string = Color(0xFFB5D88A);
  static const type = Color(0xFF7FB8FF);
  static const prop = Color(0xFFE6C07B);
  static const value = Color(0xFFFF9C7A);
  static const number = Color(0xFFF78C6C);
  static const comment = Color(0xFF5A6276);

  static const ok = Color(0xFF8FD19E);
  static const warn = Color(0xFFF2C14E);
  static const live = Color(0xFF4CC37C);
}

/// The page's colours. Lerps, so switching theme cross-fades every colour.
@immutable
class PageTheme {
  final String name;
  final Color bg;
  final Color surface;
  final Color fg;
  final Color muted;
  final Color line;
  final Color accent;
  final Color accentSoft;
  final Color gold;
  final Color ok;
  final Brightness brightness;

  const PageTheme({
    required this.name,
    required this.bg,
    required this.surface,
    required this.fg,
    required this.muted,
    required this.line,
    required this.accent,
    required this.accentSoft,
    required this.gold,
    required this.ok,
    required this.brightness,
  });

  static const paper = PageTheme(
    name: 'paper',
    bg: Color(0xFFF3F0E8),
    surface: Color(0xFFFBF9F4),
    fg: Color(0xFF14120E),
    muted: Color(0xFF6C665A),
    line: Color(0x1C14120E),
    accent: Color(0xFF1F5BD8),
    accentSoft: Color(0x171F5BD8),
    gold: Color(0xFF9A6400),
    ok: Color(0xFF2F9E58),
    brightness: Brightness.light,
  );

  static const night = PageTheme(
    name: 'night',
    bg: Color(0xFF0C0F15),
    surface: Color(0xFF131824),
    fg: Color(0xFFECEFF5),
    muted: Color(0xFF8A93A6),
    line: Color(0x17FFFFFF),
    accent: Color(0xFF7AB0FF),
    accentSoft: Color(0x1F7AB0FF),
    gold: Color(0xFFF2C14E),
    ok: Color(0xFF4CC37C),
    brightness: Brightness.dark,
  );

  static const lagos = PageTheme(
    name: 'lagos',
    bg: Color(0xFF17251C),
    surface: Color(0xFF1F3026),
    fg: Color(0xFFF2E9D6),
    muted: Color(0xFFB3AA92),
    line: Color(0x21F2E9D6),
    accent: Color(0xFFF0A04B),
    accentSoft: Color(0x21F0A04B),
    gold: Color(0xFFF0C060),
    ok: Color(0xFF7FD39B),
    brightness: Brightness.dark,
  );

  static const all = {'paper': paper, 'night': night, 'lagos': lagos};

  static PageTheme lerp(PageTheme a, PageTheme b, double t) => PageTheme(
    name: t < 0.5 ? a.name : b.name,
    bg: Color.lerp(a.bg, b.bg, t)!,
    surface: Color.lerp(a.surface, b.surface, t)!,
    fg: Color.lerp(a.fg, b.fg, t)!,
    muted: Color.lerp(a.muted, b.muted, t)!,
    line: Color.lerp(a.line, b.line, t)!,
    accent: Color.lerp(a.accent, b.accent, t)!,
    accentSoft: Color.lerp(a.accentSoft, b.accentSoft, t)!,
    gold: Color.lerp(a.gold, b.gold, t)!,
    ok: Color.lerp(a.ok, b.ok, t)!,
    brightness: t < 0.5 ? a.brightness : b.brightness,
  );
}

class PageThemeTween extends Tween<PageTheme> {
  PageThemeTween({super.begin, super.end});

  @override
  PageTheme lerp(double t) => PageTheme.lerp(begin!, end!, t);
}

/// Makes the current [PageTheme] available to the page's widgets.
class PageThemeScope extends InheritedWidget {
  final PageTheme theme;

  const PageThemeScope({super.key, required this.theme, required super.child});

  static PageTheme of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PageThemeScope>()?.theme ??
      PageTheme.paper;

  @override
  bool updateShouldNotify(PageThemeScope old) => old.theme != theme;
}

/// Type. Martian Mono (condensed) for display, IBM Plex Sans for reading,
/// IBM Plex Mono for code and labels. Variable fonts are driven through
/// [FontVariation]s so weight and width render exactly on every renderer.
abstract final class Txt {
  static TextStyle display(
    double size, {
    Color? color,
    double weight = 500,
    double width = 75,
    double height = 1.0,
    double tracking = -0.045,
  }) => TextStyle(
    fontFamily: 'MartianMono',
    fontSize: size,
    height: height,
    color: color,
    letterSpacing: size * tracking,
    fontVariations: [
      FontVariation('wght', weight),
      FontVariation('wdth', width),
    ],
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  static TextStyle sans(
    double size, {
    Color? color,
    double weight = 400,
    double height = 1.55,
    bool italic = false,
    double tracking = 0,
  }) => TextStyle(
    fontFamily: 'IBMPlexSans',
    fontSize: size,
    height: height,
    color: color,
    letterSpacing: tracking,
    fontStyle: italic ? FontStyle.italic : FontStyle.normal,
    fontWeight: _weight(weight),
    fontVariations: [FontVariation('wght', weight)],
  );

  static TextStyle mono(
    double size, {
    Color? color,
    bool medium = false,
    double height = 1.5,
    double tracking = 0,
  }) => TextStyle(
    fontFamily: 'IBMPlexMono',
    fontSize: size,
    height: height,
    color: color,
    letterSpacing: tracking,
    fontWeight: medium ? FontWeight.w500 : FontWeight.w400,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  /// Small uppercase label, e.g. "01 · WORK".
  static TextStyle label(Color color, {double size = 11.5}) =>
      mono(size, color: color, medium: true, tracking: size * 0.12);

  static FontWeight _weight(double w) =>
      FontWeight.values[((w / 100).round() - 1).clamp(0, 8)];
}

abstract final class Motion {
  static const ease = Cubic(0.22, 1, 0.36, 1);
  static const fast = Duration(milliseconds: 160);
  static const medium = Duration(milliseconds: 320);
  static const slow = Duration(milliseconds: 600);

  static bool reduced(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  static Duration of(BuildContext context, Duration d) =>
      reduced(context) ? Duration.zero : d;
}

/// Layout breakpoints for the shell.
abstract final class Shell {
  /// Below this: phone mode ("you're on the device").
  static const phone = 860.0;

  /// Below this: no widget tree column.
  static const tree = 1180.0;
}
