import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../services/music.dart';

/// The site's files, in tab order. Each one "builds" one section of the page.
enum SourceFile {
  main('main.dart', 'home'),
  work('work.dart', 'work'),
  career('career.log', 'career'),
  writing('writing.dart', 'writing'),
  afterHours('after_hours.dart', 'afterhours'),
  contact('contact.sh', 'contact');

  final String label;
  final String section;

  const SourceFile(this.label, this.section);

  static SourceFile forSection(String section) =>
      values.firstWhere((f) => f.section == section, orElse: () => main);
}

enum LogKind { plain, ok, info, warn }

class LogLine {
  final LogKind kind;
  final String text;

  const LogLine(this.kind, this.text);
}

/// Everything the IDE and the page share: the editable values, which file is
/// open, which section is on screen, what's being inspected, and the console.
class IdeController extends ChangeNotifier {
  IdeController({PlaylistController? music})
    : music = music ?? PlaylistController.instance {
    this.music.addListener(_onMusic);
  }

  /// Every clickable value and the options a click cycles through.
  static const options = <String, List<String>>{
    'name': ['Damola Nelson', 'damooola'],
    'role': [
      'Flutter mobile engineer',
      'Flutter + Go engineer',
      'Mobile engineer, fintech',
    ],
    'specialty': [
      'apps that work on one bar of signal',
      'payments that never double-charge',
      'code the next developer can maintain',
    ],
    'basedIn': ['Lagos, NG', 'Remote, any timezone'],
    'status': ['openToWork', 'shipping'],
    'web': ['false', 'true'],
    'theme': ['paper', 'night', 'lagos'],
    'airplane': ['false', 'true'],
    'loanDemo': ['loanFix', 'faceCheck'],
    'ajarraDemo': ['calendar', 'chat', 'routeMap'],
    'oneline': ['false', 'true'],
    'sort': ['favourites', 'newest'],
    'learning': ['golang', 'iso27001', 'encryption'],
    'lastWin': ['false', 'true'],
    'club': ['chelsea'],
  };

  /// Values shown as quoted strings (green) rather than enum members.
  static const stringKeys = {'name', 'role', 'specialty', 'basedIn'};

  final PlaylistController music;
  final _index = <String, int>{for (final k in options.keys) k: 0};

  String value(String key) => switch (key) {
    'playing' => music.playing ? 'true' : 'false',
    _ => options[key]![_index[key]!],
  };

  int indexOf(String key) => _index[key] ?? 0;
  bool flag(String key) => value(key) == 'true';

  /// Drives the offline demo's airplane mode; written by both sides.
  late final ValueNotifier<bool> airplane = ValueNotifier<bool>(false)
    ..addListener(() {
      final want = airplane.value ? 1 : 0;
      if (_index['airplane'] != want) {
        _index['airplane'] = want;
        _lastChanged = 'airplane';
        notifyListeners();
      }
    });

  // ── Files, sections, inspection ─────────────────────────────────────────

  SourceFile file = SourceFile.main;
  String section = 'home';

  /// Widget id hovered in the code (outlined on the page).
  String? inspecting;

  /// Widget id hovered on the page (its code lines light up).
  String? pageHover;

  bool reading = false;
  String consoleTab = 'debug';

  void openFile(SourceFile f) {
    if (f == file) return;
    file = f;
    notifyListeners();
  }

  /// Called as the page scrolls; keeps the tab and tree in step.
  void setSection(String s) {
    if (s == section) return;
    section = s;
    file = SourceFile.forSection(s);
    notifyListeners();
  }

  void inspect(String? id) {
    if (id == inspecting) return;
    inspecting = id;
    notifyListeners();
  }

  void hoverPage(String? id) {
    if (id == pageHover) return;
    pageHover = id;
    notifyListeners();
  }

  void toggleReading() {
    reading = !reading;
    log(
      LogKind.info,
      reading
          ? 'flutter: Reading mode. Code hidden.'
          : 'flutter: Code is back. Hover any line to see what it builds.',
    );
    notifyListeners();
  }

  void showConsole(String tab) {
    consoleTab = tab;
    notifyListeners();
  }

  // ── Hot reload ──────────────────────────────────────────────────────────

  /// Bumps on every reload; the page flashes when it changes.
  int reloads = 0;
  String? _lastChanged;

  /// The key changed by the last reload, so its line can glow.
  String? get lastChanged => _lastChanged;

  final logs = <LogLine>[];
  final _random = math.Random();
  Timer? _pending;

  void log(LogKind kind, String text) {
    logs.add(LogLine(kind, text));
    if (logs.length > 80) logs.removeAt(0);
    notifyListeners();
  }

  /// Moves [key] to its next option and hot-reloads.
  void cycle(String key) {
    if (key == 'playing') {
      final wasPlaying = music.playing;
      music.toggle();
      hotReload(changed: key, note: wasPlaying ? 'Paused.' : 'Playing.');
      return;
    }
    final list = options[key];
    if (list == null) return;
    _index[key] = (_index[key]! + 1) % list.length;
    if (key == 'airplane') airplane.value = flag('airplane');
    hotReload(changed: key, note: _note(key));
  }

  /// Sets [key] to a specific option (e.g. a demo tab on the page).
  void set(String key, String option) {
    final i = options[key]?.indexOf(option) ?? -1;
    if (i < 0 || i == _index[key]) return;
    _index[key] = i;
    hotReload(changed: key);
  }

  void hotReload({String? changed, String? note}) {
    _lastChanged = changed;
    log(LogKind.plain, 'Performing hot reload...');
    _pending?.cancel();
    _pending = Timer(const Duration(milliseconds: 180), () {
      final ms = 140 + _random.nextInt(170);
      reloads++;
      log(
        LogKind.ok,
        'Reloaded ${changed == null ? 0 : 1} of 412 libraries in ${ms}ms '
        '(compile: ${(ms * .3).round()} ms, reload: ${(ms * .2).round()} ms, '
        'reassemble: ${(ms * .5).round()} ms).',
      );
      if (note != null) log(LogKind.info, 'flutter: $note');
    });
  }

  void hotRestart() {
    for (final k in _index.keys) {
      _index[k] = 0;
    }
    airplane.value = false;
    if (music.playing) music.toggle();
    _lastChanged = null;
    log(LogKind.plain, 'Performing hot restart...');
    _pending?.cancel();
    _pending = Timer(const Duration(milliseconds: 260), () {
      reloads++;
      log(
        LogKind.ok,
        'Restarted application in ${480 + _random.nextInt(200)}ms.',
      );
    });
  }

  String? _note(String key) => switch (key) {
    'status' =>
      value(key) == 'shipping'
          ? 'Heads down, shipping. Still answering email.'
          : 'Open to Flutter roles.',
    'theme' => 'Theme set to ${value(key)}.',
    'airplane' =>
      flag(key)
          ? 'Offline. New customers queue on the device.'
          : 'Back online. Syncing the queue.',
    'club' => 'Club is final. It’s Chelsea.',
    'sort' => 'Posts sorted by ${value(key)}.',
    'oneline' => flag(key) ? 'git log --oneline' : 'git log',
    _ => null,
  };

  void _onMusic() => notifyListeners();

  @override
  void dispose() {
    _pending?.cancel();
    music.removeListener(_onMusic);
    airplane.dispose();
    super.dispose();
  }
}

/// Gives descendants access to the [IdeController] and rebuilds them when
/// it changes.
class IdeScope extends InheritedNotifier<IdeController> {
  const IdeScope({
    super.key,
    required IdeController controller,
    required super.child,
  }) : super(notifier: controller);

  static IdeController of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<IdeScope>()!.notifier!;

  /// Read without subscribing (for event handlers).
  static IdeController read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<IdeScope>()!.notifier!;
}
