import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'widgets/about_section.dart';
import 'widgets/contact_section.dart';
import 'widgets/hero_section.dart';
import 'widgets/nav_bar.dart';
import 'widgets/scroll_meter.dart';
import 'widgets/skills_section.dart';
import 'widgets/stats_section.dart';
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
  final _aboutKey = GlobalKey();
  final _workKey = GlobalKey();
  final _contactKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.night,
      appBar: NavBar(
        onAbout: () => _scrollTo(_aboutKey),
        onWork: () => _scrollTo(_workKey),
        onContact: () => _scrollTo(_contactKey),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                HeroSection(
                  onViewWork: () => _scrollTo(_workKey),
                  onContact: () => _scrollTo(_contactKey),
                ),
                const StatsSection(),
                KeyedSubtree(key: _aboutKey, child: const AboutSection()),
                KeyedSubtree(key: _workKey, child: const WorkSection()),
                const SkillsSection(),
                KeyedSubtree(key: _contactKey, child: const ContactSection()),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ScrollProgressBar(controller: _scrollController),
          ),
        ],
      ),
    );
  }
}
