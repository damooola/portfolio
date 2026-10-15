import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'widgets/contact_section.dart';
import 'widgets/hero_section.dart';
import 'widgets/nav_bar.dart';
import 'widgets/scroll_meter.dart';
import 'widgets/spotlight.dart';
import 'widgets/work_section.dart';

void main() {
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
  final _skillsKey = GlobalKey();
  final _contactKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Deep links: /#work, /#skills, /#contact jump straight to a section.
    final target = switch (Uri.base.fragment.replaceAll('/', '')) {
      'work' => _workKey,
      'skills' => _skillsKey,
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

  @override
  void dispose() {
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
        links: [
          NavLink('Work', () => _scrollTo(_workKey)),
          NavLink('Skills', () => _scrollTo(_skillsKey)),
          NavLink('Contact', () => _scrollTo(_contactKey)),
        ],
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
                    onViewWork: () => _scrollTo(_workKey),
                    onContact: () => _scrollTo(_contactKey),
                  ),
                  KeyedSubtree(
                    key: _workKey,
                    child: WorkSection(selected: _project),
                  ),
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
