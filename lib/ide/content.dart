import '../data/portfolio_data.dart';

/// Content for the "Hot reload" site. Biography, stats, career and essays
/// still come from portfolio_data.dart; this adds what's specific to the
/// IDE: the three projects as they appear in work.dart, and git hashes for
/// the career log.

enum Demo {
  offlineSync(
    'Offline sync',
    'Turn on airplane mode and add customers. They queue, then sync one at a time when you’re back online, and one fails once and retries.',
  ),
  loanFix(
    'Loan fix',
    'A declined application with three things to fix: verify a guarantor, add collateral, lower the amount. Then resubmit.',
  ),
  faceCheck(
    'Face check',
    'Guided face capture. Steer the face to each target angle; a head tilt can’t pass for a turn.',
  ),
  calendar(
    'Calendar',
    'A day view where overlapping tasks split into columns, with creator, co-planner and viewer permissions.',
  ),
  chat(
    'Chat',
    'Messages queue while offline and send in order on reconnect, with ticks, a flaky-server mode and voice notes.',
  ),
  routeMap(
    'Map',
    'Tap a vendor to draw the route and watch the car drive it while distance and ETA count down.',
  );

  final String label;
  final String hint;

  const Demo(this.label, this.hint);
}

class IdeProject {
  final String id;

  /// Class name in work.dart.
  final String widget;
  final String name;
  final String client;
  final String years;
  final String summary;
  final String builtForReal;
  final List<String> stack;
  final List<Demo> demos;

  const IdeProject({
    required this.id,
    required this.widget,
    required this.name,
    required this.client,
    required this.years,
    required this.summary,
    required this.builtForReal,
    required this.stack,
    required this.demos,
  });
}

abstract final class IdeContent {
  static const projects = <IdeProject>[
    IdeProject(
      id: 'field',
      widget: 'FieldAgentApp',
      name: 'Field agent app',
      client: 'NeoCash · Shepherd Trust MFB',
      years: '2026 — now',
      summary:
          'The app field agents use to sign up borrowers in markets with '
          'patchy or no signal. Everything saves on the phone first and syncs '
          'when a connection comes back.',
      builtForReal:
          'Main contributor (360 of 448 commits) to the offline-first engine '
          'we built as a team: an encrypted local database, a request queue '
          'that retries without creating duplicates, and conflict handling.',
      stack: ['Flutter', 'Riverpod', 'Drift', 'SQLCipher', 'Go'],
      demos: [Demo.offlineSync],
    ),
    IdeProject(
      id: 'loan',
      widget: 'LoanApp',
      name: 'Customer loan app',
      client: 'NeoCash',
      years: '2026 — now',
      summary: 'The lending app on Google Play and the App Store.',
      builtForReal:
          'Ten loan-rejection recovery flows, on-device guided face capture, '
          'location-aware address checks and a server-side PIN migration. '
          'Onboarding retention up about 15%, crashes down about 25%.',
      stack: ['Flutter', 'Riverpod', 'ML Kit', 'Go'],
      demos: [Demo.loanFix, Demo.faceCheck],
    ),
    IdeProject(
      id: 'ajarra',
      widget: 'Ajarra',
      name: 'Ajarra',
      client: 'AJ’s Rentals · event marketplace',
      years: '2025 — 2026',
      summary:
          'A two-sided marketplace connecting event planners with vendors. '
          'I was the only mobile engineer, end to end.',
      builtForReal:
          'Wrote 694 of its 707 commits: Socket.IO chat with an offline queue '
          'and voice notes, a calendar built from scratch, co-planning roles, '
          'escrow bookings, and Paystack and Flutterwave payments.',
      stack: ['Flutter', 'BLoC', 'Socket.IO', 'Firebase'],
      demos: [Demo.calendar, Demo.chat, Demo.routeMap],
    ),
  ];

  /// Short commit hashes for the career log, newest first, matching
  /// [CareerData.roles]; the last is the degree, tagged v1.0.
  static const hashes = [
    'a41f2c9',
    '9b13e07',
    '51c0d2a',
    '7e2a6f1',
    'c08d3b4',
    '3fa9e10',
    '0e8f3b1',
  ];

  static List<Role> get roles => CareerData.roles;

  /// Specialty lines the `specialty:` value cycles through.
  static const specialties = {
    'apps that work on one bar of signal':
        'I build apps that still work on one bar of signal.',
    'payments that never double-charge':
        'I build payment flows that never charge anyone twice.',
    'code the next developer can maintain':
        'I write code the next developer can actually maintain.',
  };
}
