import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/sfx.dart';
import 'theme/app_theme.dart';
import 'widgets/after_hours_section.dart';
import 'widgets/career_section.dart';
import 'widgets/confetti.dart';
import 'widgets/contact_section.dart';
import 'widgets/hero_section.dart';
import 'widgets/nav_bar.dart';
import 'widgets/scroll_meter.dart';
import 'widgets/shortcut_sheet.dart';
import 'widgets/skills_section.dart';
import 'widgets/spotlight.dart';
import 'widgets/toast.dart';
import 'widgets/work_section.dart';
import 'widgets/writing_section.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Fonts ship with the site (assets/google_fonts/), so nothing waits on
  // fonts.gstatic.com and text never swaps fonts mid-load.
  GoogleFonts.config.allowRuntimeFetching = false;
  await Sfx.init();
  runApp(const PortfolioApp());
}

class PortfolioApp extends StatelessWidget {
  const PortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Damola Nelson — Flutter Engineer',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      // This is a website: arrows scroll, like Flutter's web defaults, rather
      // than hopping focus between widgets. Spelled out so tests and desktop
      // builds behave like the real site.
      shortcuts: {
        ...WidgetsApp.defaultShortcuts,
        const SingleActivator(LogicalKeyboardKey.arrowUp): const ScrollIntent(
          direction: AxisDirection.up,
        ),
        const SingleActivator(LogicalKeyboardKey.arrowDown): const ScrollIntent(
          direction: AxisDirection.down,
        ),
        const SingleActivator(LogicalKeyboardKey.arrowLeft): const ScrollIntent(
          direction: AxisDirection.left,
        ),
        const SingleActivator(LogicalKeyboardKey.arrowRight):
            const ScrollIntent(direction: AxisDirection.right),
      },
      home: const PortfolioHome(),
    );
  }
}

class PortfolioHome extends StatefulWidget {
  const PortfolioHome({super.key});

  @override
  State<PortfolioHome> createState() => _PortfolioHomeState();
}

class _PortfolioHomeState extends State<PortfolioHome> {
  final _scrollController = ScrollController();
  final _project = ValueNotifier(0);
  final _workKey = GlobalKey();
  final _careerKey = GlobalKey();
  final _skillsKey = GlobalKey();
  final _afterHoursKey = GlobalKey();
  final _heroNameKey = GlobalKey();
  final _writingKey = GlobalKey();
  final _contactKey = GlobalKey();

  static const _konami = [
    LogicalKeyboardKey.arrowUp,
    LogicalKeyboardKey.arrowUp,
    LogicalKeyboardKey.arrowDown,
    LogicalKeyboardKey.arrowDown,
    LogicalKeyboardKey.arrowLeft,
    LogicalKeyboardKey.arrowRight,
    LogicalKeyboardKey.arrowLeft,
    LogicalKeyboardKey.arrowRight,
    LogicalKeyboardKey.keyB,
    LogicalKeyboardKey.keyA,
  ];
  int _konamiProgress = 0;
  bool _sheetOpen = false;

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_onKey);
    // Deep links: /#work, /#skills, /#contact jump straight to a section,
    // and /#work-2 opens the second project.
    final fragment = Uri.base.fragment.replaceAll('/', '');
    final project = RegExp(r'^work-(\d)$').firstMatch(fragment);
    if (project != null) {
      _project.value = (int.parse(project.group(1)!) - 1).clamp(0, 2);
    }
    final target = switch (project != null ? 'work' : fragment) {
      'work' => _workKey,
      'after-hours' || 'trophies' => _afterHoursKey,
      'writing' => _writingKey,
      'skills' => _skillsKey,
      'career' => _careerKey,
      'contact' => _contactKey,
      _ => null,
    };
    if (target != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctx = target.currentContext;
        if (ctx != null) Scrollable.ensureVisible(ctx);
      });
    }
  }

  /// Page-wide keyboard play. Ignored while typing in a field (the OTP
  /// demo), so digits and arrows still go where the visitor expects.
  bool _onKey(KeyEvent event) {
    if (event is! KeyDownEvent || !mounted) return false;
    final typing =
        FocusManager.instance.primaryFocus?.context
            ?.findAncestorWidgetOfExactType<EditableText>() !=
        null;
    if (typing) return false;

    final key = event.logicalKey;
    _konamiProgress = key == _konami[_konamiProgress]
        ? _konamiProgress + 1
        : (key == _konami.first ? 1 : 0);
    if (_konamiProgress == _konami.length) {
      _konamiProgress = 0;
      Sfx.play(Sound.ding);
      showConfetti(context);
      showToast(
        context,
        'Blue is the colour',
        icon: Icons.sports_soccer,
        color: AppColors.blue,
      );
      return true;
    }
    if (_sheetOpen) return false;

    if (key == LogicalKeyboardKey.arrowRight) {
      WorkSection.select(_project, _project.value + 1);
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      WorkSection.select(_project, _project.value - 1);
    } else if (key == LogicalKeyboardKey.enter) {
      _scrollTo(_workKey);
    } else if (key == LogicalKeyboardKey.keyE) {
      ContactSection.email();
    } else if (key == LogicalKeyboardKey.keyS) {
      Sfx.toggle();
    } else if (event.character == '?') {
      _sheetOpen = true;
      Sfx.play(Sound.chime);
      showShortcutSheet(context).whenComplete(() => _sheetOpen = false);
    } else {
      return false;
    }
    return true;
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKey);
    _scrollController.dispose();
    _project.dispose();
    super.dispose();
  }

  void _scrollTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _scrollToTop() => _scrollController.animateTo(
    0,
    duration: const Duration(milliseconds: 600),
    curve: Curves.easeInOutCubic,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.night,
      extendBodyBehindAppBar: true,
      appBar: NavBar(
        onHome: _scrollToTop,
        scroll: _scrollController,
        heroNameKey: _heroNameKey,
        links: [
          NavLink('Work', () => _scrollTo(_workKey)),
          NavLink('Career', () => _scrollTo(_careerKey)),
          NavLink('Skills', () => _scrollTo(_skillsKey)),
          NavLink('After hours', () => _scrollTo(_afterHoursKey)),
          NavLink('Writing', () => _scrollTo(_writingKey)),
          NavLink('Contact', () => _scrollTo(_contactKey)),
        ],
        trailing: const [NowPlayingPill(), SoundToggle()],
      ),
      body: CursorSpotlight(
        child: Stack(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  const SizedBox(height: 68),
                  HeroSection(
                    nameKey: _heroNameKey,
                    onViewWork: () => _scrollTo(_workKey),
                    onContact: () => _scrollTo(_contactKey),
                  ),
                  KeyedSubtree(
                    key: _workKey,
                    child: WorkSection(selected: _project),
                  ),
                  KeyedSubtree(key: _careerKey, child: const CareerSection()),
                  KeyedSubtree(key: _skillsKey, child: const SkillsSection()),
                  KeyedSubtree(
                    key: _afterHoursKey,
                    child: const AfterHoursSection(),
                  ),
                  KeyedSubtree(key: _writingKey, child: const WritingSection()),
                  KeyedSubtree(key: _contactKey, child: const ContactSection()),
                ],
              ),
            ),
            Positioned(
              top: MediaQuery.paddingOf(context).top + 68,
              left: 0,
              right: 0,
              child: ScrollProgressBar(controller: _scrollController),
            ),
          ],
        ),
      ),
    );
  }
}
