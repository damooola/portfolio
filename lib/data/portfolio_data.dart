// All site copy lives here, separate from layout. Edit this file to change
// what the site says — you shouldn't need to touch widget code for content
// changes. Anything marked TODO is a placeholder you should personalize.
//
// Every figure in TrophiesData comes straight from the resume PDF. Don't add
// numbers here that aren't on the resume. Career dates and titles follow
// LinkedIn, which is the source of truth for the timeline.

class ProfileData {
  static const name = 'Damola Nelson';
  static const firstName = 'Damola';
  static const lastName = 'Nelson';
  static const initials = 'DN';
  static const title = 'Flutter Mobile Engineer';
  static const role = 'Flutter mobile engineer.';
  static const status =
      'Open to Flutter Dev roles · full time · contract · remote';

  /// From my LinkedIn summary.
  static const tagline =
      'I build Flutter apps that ship, on Android and iOS, in production. '
      'Fintech, marketplaces and travel, with payments, maps and real-time '
      'features, and code the next developer can actually maintain.';

  static const githubUrl = 'https://github.com/damooola';
  static const githubHandle = 'damooola';
  static const linkedinUrl = 'https://www.linkedin.com/in/damola-owonifari';
  static const behanceUrl = 'https://www.behance.net/damolanelson';
  static const blogUrl = 'https://daily-flutters.hashnode.dev';
  static const email = 'damolanelson@gmail.com';
  static const resumeAssetPath = 'assets/resume.pdf';
}

/// The four "now playing" tiles in the hero. Hover one to preview its
/// panel; click to pin it open.
class NowPlayingData {
  /// Chess.com username: the tile shows my current rating and the panel my
  /// last win, read live from Chess.com's public API.
  static const chessUsername = 'ay0dam0la';

  /// Spotify share link (Share → Copy link to playlist). After changing it,
  /// run `dart run tool/fetch_playlist.dart` to refresh the tracks.
  static const spotifyPlaylistUrl =
      'https://open.spotify.com/playlist/129dbvsNU8XV8ZGlrrjM3x';

  /// TheSportsDB team id for Chelsea: last result and next fixture, live.
  static const chelseaTeamId = '133610';

  static const learning = 'Go, deeper every week';
  static const learningDetail =
      'I already ship Go on the backend at NeoCash, and I\'m still levelling '
      'up: the server side of the same APIs my Flutter apps talk to.';
  static const learningUrl = 'https://github.com/damooola';
}

enum DemoKind {
  loanFix('Loan fix'),
  faceCheck('Face check'),
  offlineSync('Field app'),
  planner('Calendar'),
  chat('Chat'),
  routeMap('Map'),
  otp('OTP');

  const DemoKind(this.label);
  final String label;
}

class Project {
  final String name;
  final String org;
  final String period;
  final String summary;
  final List<String> tags;

  /// Live demos in the phone, first one shown by default. More than one
  /// gets a switcher above the phone.
  final List<DemoKind> demos;

  /// Line under the phone: what was built for real.
  final String builtForReal;

  /// Second line under the phone: the result. Resume figures only.
  final String result;
  final String? linkLabel;
  final String? linkUrl;

  const Project({
    required this.name,
    required this.org,
    required this.period,
    required this.summary,
    required this.tags,
    required this.demos,
    required this.builtForReal,
    required this.result,
    this.linkLabel,
    this.linkUrl,
  });
}

/// Demos are rebuilt from scratch on mock data — no employer code.
class ProjectsData {
  static const projects = <Project>[
    Project(
      name: 'NeoCash loan apps',
      org: 'NeoCash',
      period: '2026 — NOW',
      summary:
          'The customer loan app on Google Play and the App Store, and the '
          'field-agent app that onboards customers with no signal. I work '
          'across both, plus the Go backend.',
      tags: ['Flutter', 'Riverpod', 'Go', 'ML Kit', 'Drift'],
      demos: [DemoKind.loanFix, DemoKind.faceCheck, DemoKind.offlineSync],
      builtForReal:
          'Built for real: ten loan-rejection recovery flows, guided face '
          'capture, location-aware address checks and a server-side PIN '
          'migration in the customer app; main contributor (360 of 448 '
          'commits) to the offline-first agent app.',
      result:
          'Result: onboarding retention up about 15% and crashes down about '
          '25% on the live customer app.',
    ),
    Project(
      name: 'Event marketplace',
      org: 'Ajarra',
      period: '2025 — 2026',
      summary:
          'A two-sided marketplace connecting event planners with vendors. '
          'I was the only mobile engineer, end to end.',
      tags: ['Flutter', 'BLoC', 'Socket.IO', 'Firebase', 'GetIt'],
      demos: [DemoKind.planner, DemoKind.chat, DemoKind.routeMap],
      builtForReal:
          'Built for real: Socket.IO chat with an offline queue and voice notes, '
          'a calendar built from scratch, co-planning roles, escrow bookings, '
          'Paystack boosts and Flutterwave payments.',
      result:
          'Result: wrote 694 of its 707 commits and shipped it to the App Store '
          'and Google Play.',
    ),
    Project(
      name: 'OTP boxes, done properly',
      org: 'Blog post',
      period: 'JUN 2026',
      summary:
          'Six little boxes that every app gets slightly wrong: focus, paste, '
          'backspace, autofill. I wrote up how to get them right.',
      tags: ['Flutter', 'Forms', 'Accessibility', 'UX detail'],
      demos: [DemoKind.otp],
      builtForReal:
          'Built for real: one hidden field driving six boxes, so paste, '
          'SMS autofill and backspace behave like any normal input.',
      result: 'Write-up: The OTP Boxes That Would Not Let Go.',
      linkLabel: 'Read the post',
      linkUrl:
          'https://daily-flutters.hashnode.dev/the-otp-boxes-that-would-not-let-go',
    ),
  ];
}

/// Resume stats, shown as console-style achievements.
class Trophy {
  final String value;
  final String title;
  final String detail;

  const Trophy(this.value, this.title, this.detail);
}

class TrophiesData {
  static const trophies = <Trophy>[
    Trophy(
      '−40%',
      'Bug exterminator',
      'Audited a crypto app\'s codebases and cut crashes by about 40%.',
    ),
    Trophy(
      '−25%',
      'Crash buster',
      'Cut app crashes by about 25% on a live lending app.',
    ),
    Trophy(
      '+15%',
      'Smooth onboarding',
      'Lifted onboarding retention by about 15% with a redesigned sign-up.',
    ),
    Trophy(
      '4',
      'Payment collector',
      'Integrated Paystack, Flutterwave, Razorpay and Stripe.',
    ),
    Trophy(
      '98%',
      'Solo build',
      'Wrote 694 of Ajarra\'s 707 commits, from first screen to both stores.',
    ),
    Trophy(
      '27',
      'Published author',
      'Posts on Daily Flutters about real Flutter bugs and how I fixed them.',
    ),
  ];
}

/// Football-game player card. Self-rated — tune the numbers to taste.
class PlayerCardData {
  // TODO: these ratings are a starting point — adjust them yourself.
  static const overall = 86;
  static const position = 'CAM';
  static const role = 'Mobile';
  static const nation = 'NGA';
  static const club = 'Lagos';
  static const form = ['W', 'W', 'W', 'D', 'W'];

  static const attributes = <(String, String, int)>[
    ('FLT', 'Flutter', 90),
    ('DRT', 'Dart', 88),
    ('STM', 'State mgmt', 86),
    ('API', 'APIs', 84),
    ('TST', 'Testing', 80),
    ('NAT', 'Native', 74),
  ];

  /// Shown on the back, under the bars.
  static const toolkit = [
    'Riverpod',
    'BLoC',
    'Provider',
    'Drift',
    'SQLCipher',
    'Isar',
    'Hive',
    'Firebase',
    'Supabase',
    'go_router',
    'Freezed',
    'Go',
    'Kotlin',
    'Java',
    'GitHub Actions',
    'Figma',
  ];
}

/// Personal essays from Medium, shown as phone screenshots in the Writing
/// section. Hand-picked; screenshots come from tool/shoot_medium.sh.
class PersonalPost {
  final String title;
  final String subtitle;
  final String url;
  final String date;
  final int readMinutes;
  final String image;

  const PersonalPost(
    this.title,
    this.subtitle,
    this.url,
    this.date,
    this.readMinutes,
    this.image,
  );
}

class PersonalPostsData {
  static const posts = <PersonalPost>[
    PersonalPost(
      'Making the World a Better Place',
      'Am I really making a difference?',
      'https://medium.com/wake-write-win/making-the-world-a-better-place-025bda69cc1f',
      'APR 2024',
      2,
      'assets/writing/better-place.jpg',
    ),
    PersonalPost(
      'Do Not Care About What Others Think',
      'Be your own person',
      'https://medium.com/new-writers-welcome/do-not-care-about-what-others-think-db9cc3a21b6c',
      'MAR 2024',
      2,
      'assets/writing/what-others-think.jpg',
    ),
    PersonalPost(
      'Is True Happiness an Illusion?',
      'Can we truly be happy?',
      'https://medium.com/wake-write-win/is-true-happiness-an-illusion-0a64490a9e9f',
      'JAN 2024',
      3,
      'assets/writing/happiness.jpg',
    ),
  ];
}

/// Work history for the career log. Titles, employers and dates follow
/// LinkedIn.
class Role {
  final String title;
  final String company;
  final String? product;
  final String start;
  final String end;
  final String place;
  final String summary;
  final List<String> tags;

  const Role({
    required this.title,
    required this.company,
    this.product,
    required this.start,
    required this.end,
    required this.place,
    required this.summary,
    this.tags = const [],
  });

  bool get current => end == 'Present';
}

class CareerData {
  static const roles = <Role>[
    Role(
      title: 'Software Engineer',
      company: 'NeoCash',
      product: 'Shepherd Trust Microfinance Bank',
      start: 'Jan 2026',
      end: 'Present',
      place: 'Lagos',
      summary:
          'Flutter apps and the Go backend behind them. In the customer app: '
          'ten loan-rejection recovery flows, on-device guided face capture, '
          'location-aware address checks and a server-side PIN migration. Main '
          'contributor to the offline-first field-agent app.',
      tags: ['Flutter', 'Riverpod', 'Go', 'Drift'],
    ),
    Role(
      title: 'Mobile Developer',
      company: 'AJ\'s Rentals Ltd',
      product: 'Ajarra',
      start: 'Jun 2025',
      end: 'May 2026',
      place: 'Lagos',
      summary:
          'Built and shipped the Ajarra app on Android and iOS, writing 694 of '
          'its 707 commits: Socket.IO chat with voice notes, a calendar built '
          'from scratch, co-planning roles, escrow bookings, and Paystack and '
          'Flutterwave payments.',
      tags: ['Flutter', 'BLoC', 'Socket.IO', 'Payments'],
    ),
    Role(
      title: 'Flutter Developer',
      company: 'Deolang',
      start: 'Jan 2025',
      end: 'May 2025',
      place: 'India · remote',
      summary:
          'Turned Figma designs into a guest-house finder app with BLoC, REST '
          'APIs and Razorpay payments.',
      tags: ['BLoC', 'Razorpay'],
    ),
    Role(
      title: 'Flutter Developer',
      company: 'Hermex Travels',
      start: 'Oct 2024',
      end: 'Dec 2024',
      place: 'Lagos',
      summary:
          'Added an AI support chatbot and Flutterwave payments for flights '
          'and hotels, and cut UI boilerplate by about 40%.',
      tags: ['Flutterwave', 'AI chat'],
    ),
    Role(
      title: 'Flutter Developer',
      company: 'Decentralyne',
      start: 'Aug 2024',
      end: 'Oct 2024',
      place: 'Lagos',
      summary:
          'Audited the Android and iOS codebases of a crypto asset app and cut '
          'crashes by about 40%.',
      tags: ['Performance', 'Refactoring'],
    ),
    Role(
      title: 'Network Engineer',
      company: 'Nigerian Ports Authority',
      start: 'Apr 2024',
      end: 'Dec 2024',
      place: 'Lagos',
      summary:
          'Routers (BGP), Cisco and Huawei switches, VLANs and Sophos '
          'firewalls. Why I care what happens on the wire.',
      tags: ['Networking'],
    ),
  ];

  static const education =
      'BEng Electrical & Electronics Engineering · Obafemi Awolowo University · 2020 – 2025';
}
