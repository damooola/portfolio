// All site copy lives here, separate from layout. Edit this file to change
// what the site says — you shouldn't need to touch widget code for content
// changes. Anything marked TODO is a placeholder you should personalize.
//
// Every figure in TrophiesData comes straight from the resume PDF. Don't add
// numbers here that aren't on the resume.

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

  // TODO: the learning blurb was drafted for you — make it yours.
  static const learning = 'Go, one service at a time';
  static const learningDetail =
      'Writing small Go services to understand the other end of the APIs my '
      'apps talk to.';
  static const learningUrl = 'https://github.com/damooola';
}

enum DemoKind { offlineSync, routeMap, otp }

class Project {
  final String name;
  final String org;
  final String period;
  final String summary;
  final List<String> tags;
  final DemoKind demo;

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
    required this.demo,
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
      name: 'Offline-first field app',
      org: 'Neocash',
      period: 'NOW',
      summary:
          'A field agent app that keeps working on a bad network and keeps '
          'data safe on a lost phone.',
      tags: ['Flutter', 'Riverpod', 'Go', 'SQLCipher', 'CI/CD'],
      demo: DemoKind.offlineSync,
      builtForReal:
          'Built for real: an outbox with ordering, retries and idempotency '
          'keys, over a SQLCipher-encrypted local database and a Go backend.',
      result:
          'Result: nothing lost or duplicated when the connection drops '
          'mid-write, with encryption checked on a real device in CI.',
    ),
    Project(
      name: 'Event marketplace',
      org: 'Ajarra',
      period: '2025 — 2026',
      summary:
          'A two-sided marketplace connecting event planners with vendors. '
          'I was the only mobile engineer, end to end.',
      tags: ['Flutter', 'BLoC', 'Maps', 'Socket.IO', 'Firebase'],
      demo: DemoKind.routeMap,
      builtForReal:
          'Built for real: maps and live tracking, real-time chat with an '
          'offline message queue, bookings and payments, for clients and vendors.',
      result: 'Result: shipped solo to both the App Store and Google Play.',
    ),
    Project(
      name: 'OTP boxes, done properly',
      org: 'Blog post',
      period: 'JUN 2026',
      summary:
          'Six little boxes that every app gets slightly wrong: focus, paste, '
          'backspace, autofill. I wrote up how to get them right.',
      tags: ['Flutter', 'Forms', 'Accessibility', 'UX detail'],
      demo: DemoKind.otp,
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
      '2',
      'Store double',
      'Shipped apps to both the App Store and Google Play.',
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
    'Drift',
    'SQLCipher',
    'Firebase',
    'Go',
    'Kotlin',
    'Swift',
    'Fastlane',
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
