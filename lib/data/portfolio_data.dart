// All site copy lives here, separate from layout. Edit this file to change
// what the site says — you shouldn't need to touch widget code for content
// changes. Anything marked TODO is a placeholder you should personalize.
//
// Every figure in StatsData comes straight from the resume PDF. Don't add
// numbers here that aren't on the resume.

import 'package:flutter/material.dart' show IconData, Icons;

class ProfileData {
  static const name = 'Damola Nelson';
  static const firstName = 'Damola';
  static const lastName = 'Nelson';
  static const initials = 'DN';
  static const title = 'Flutter Mobile Engineer';
  static const role = 'Flutter mobile engineer in Lagos.';
  static const status = 'Online — building offline-first apps';

  // TODO: tagline was drafted for you — rewrite in your own voice.
  static const tagline =
      'I build apps that keep working when the network doesn\'t, and I sweat '
      'the small stuff: the OTP box, the retry, the half-second of feedback.';

  // TODO: swap the LinkedIn placeholder for your real profile URL.
  static const githubUrl = 'https://github.com/damooola';
  static const githubHandle = 'damooola';
  static const linkedinUrl = 'https://www.linkedin.com/in/YOUR-LINKEDIN-HERE';
  static const email = 'damolanelson@gmail.com';
  static const resumeAssetPath = 'assets/resume.pdf';
}

/// The "now playing" strip in the hero. Hand-edited — update it whenever
/// you like. Clicking the strip cycles through these in order.
class NowPlayingData {
  // TODO: these are placeholders — put in your real game, song and score.
  static const items = <(String, String, IconData)>[
    ('PLAYING', 'EA SPORTS FC 26', Icons.sports_esports_outlined),
    ('ON REPEAT', 'Add your song here', Icons.music_note_outlined),
    ('CHELSEA', 'Last result goes here', Icons.sports_soccer_outlined),
    ('LEARNING', 'Go, one service at a time', Icons.school_outlined),
  ];
}

enum StatTrend { up, down }

class Stat {
  final String label;
  final String value;
  final String caption;
  final StatTrend? trend;

  const Stat({
    required this.label,
    required this.value,
    required this.caption,
    this.trend,
  });
}

class StatsData {
  static const stats = <Stat>[
    Stat(
      label: 'CRASH RATE',
      value: '~25%',
      caption:
          'fewer app crashes after architecture and performance work '
          'on a live lending app.',
      trend: StatTrend.down,
    ),
    Stat(
      label: 'RETENTION',
      value: '~15%',
      caption:
          'better onboarding retention after redesigning the whole '
          'sign-up flow.',
      trend: StatTrend.up,
    ),
    Stat(
      label: 'GATEWAYS',
      value: '04',
      caption:
          'payment gateways integrated — Paystack, Flutterwave, '
          'Razorpay and Stripe.',
    ),
    Stat(
      label: 'SHIPPING SINCE',
      value: '2024',
      caption: 'building Flutter apps for teams in Nigeria, the US and India.',
    ),
  ];
}

class Project {
  final String title;
  final String description;
  final List<String> highlights;
  final List<String> tags;
  final String role;
  final IconData icon;
  final String? period;
  final String? status;

  const Project({
    required this.title,
    required this.description,
    required this.highlights,
    required this.tags,
    required this.role,
    required this.icon,
    this.period,
    this.status,
  });
}

class ProjectsData {
  static const projects = <Project>[
    Project(
      title: 'Offline-First Field Agent App',
      description:
          'A mobile app for field agents working in low-connectivity '
          'environments, backed by a Go services layer. Built to keep '
          'working — and keep data safe — when the network doesn\'t.',
      highlights: [
        'Offline-first architecture: writes queue through an outbox '
            'pattern with ordering, retries, and idempotent request '
            'handling, so nothing is lost or duplicated when '
            'connectivity drops mid-transaction.',
        'Local data encrypted at rest with SQLCipher; verified with a '
            'dedicated integration test suite that checks the '
            'encryption guarantees on a real device, not just in theory.',
        'CI pipeline runs static analysis, unit/widget tests, and a '
            'hardware-emulator integration test on every change before '
            'it merges.',
      ],
      tags: ['Flutter', 'Riverpod', 'Go', 'SQLCipher', 'CI/CD'],
      role: 'Mobile engineer',
      icon: Icons.shield_outlined,
    ),
    Project(
      title: 'Consumer Lending App',
      description:
          'A production lending app serving real customers — the kind '
          'of app where a crash or a broken payment flow has real '
          'consequences, not just a bad review.',
      highlights: [
        'Redesigned the onboarding flow end to end, lifting onboarding '
            'retention by around 15%.',
        'Integrated biometric facial verification, document capture, '
            'and address verification into the KYC flow.',
        'Built the automated repayment integration through Nigeria\'s '
            'interbank mandate system, and shipped architecture and '
            'performance work that cut crashes by around 25%.',
      ],
      tags: ['Flutter', 'Riverpod', 'Firebase', 'Payments'],
      role: 'Mobile engineer',
      icon: Icons.fingerprint,
      period: '2026 — NOW',
      status: 'Live on iOS & Android',
    ),
    Project(
      title: 'Event Marketplace App',
      description:
          'A two-sided marketplace connecting event organizers with '
          'vendors — decoration, catering, photography, and more. I was '
          'the only mobile engineer on this one, owning the app end to '
          'end across both the client and vendor experiences.',
      highlights: [
        'Built real-time chat between clients and vendors with a custom '
            'connection service: authenticated handshake, automatic '
            'reconnection, and an offline message queue that flushes '
            'once connectivity returns — the most resilient piece of '
            'infrastructure I\'ve shipped solo.',
        'Built full auth (email/password with OTP, Google & Apple '
            'sign-in, password recovery) and role-based experiences for '
            'clients and vendors in a single app.',
        'Integrated booking flows, subscription and one-off payments, '
            'push notifications, and a vendor-facing analytics dashboard.',
      ],
      tags: ['Flutter', 'BLoC/Cubit', 'Socket.IO', 'GetIt', 'Firebase'],
      role: 'Sole mobile developer',
      icon: Icons.forum_outlined,
      period: '2025 — 2026',
      status: 'Live on iOS & Android',
    ),
  ];
}

class SkillGroup {
  final String label;
  final List<String> items;

  const SkillGroup({required this.label, required this.items});
}

class SkillsData {
  /// Items shown with a "learning" marker instead of as established skills.
  static const learning = {'Go'};

  static const groups = <SkillGroup>[
    SkillGroup(
      label: 'Mobile',
      items: ['Flutter', 'Dart', 'Kotlin', 'Swift', 'Riverpod', 'BLoC'],
    ),
    SkillGroup(
      label: 'Backend & Data',
      items: ['Go', 'REST APIs', 'Firebase', 'Drift / SQLite', 'SQLCipher'],
    ),
    SkillGroup(
      label: 'Payments',
      items: ['Paystack', 'Flutterwave', 'Razorpay', 'Stripe'],
    ),
    SkillGroup(label: 'Tooling', items: ['Git', 'CI/CD', 'Fastlane', 'Figma']),
  ];
}
