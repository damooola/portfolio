# Damola Nelson — Portfolio

My personal portfolio site, built with **Flutter Web**. I'm a Flutter mobile engineer in Lagos, and instead of listing what I've built, the site lets you use it: every project comes with a working Flutter demo running inside a phone frame.

The concept is **After Hours**: a dark navy room, a soft blue glow that follows the cursor, and small things to pick up and play with. It's a clean portfolio if you only scroll, with extra toys for anyone who pokes around.

## Sections

| Section | What it does |
| --- | --- |
| Hero | Name, role, status and resume download, plus six headline numbers from my resume |
| 01 Work | Three projects with live demos in a phone that tilts toward the cursor |
| 02 Career | Work history, newest first |
| 03 Skills | A football-game player card that flips to show the attribute bars |
| 04 After hours | Four live tiles: what I'm learning, my Chess.com form, my playlist in a custom player, and Chelsea's last result and next game. Hover to preview, click to pin |
| 05 Writing | A draggable row of Flutter articles from Hashnode and Coder Legion, plus three personal Medium essays shown on phones |
| 06 Contact | Click to copy my email, or press **E** |

## Live demos

The real apps belong to the companies I built them for, so every demo is a small working version rebuilt from scratch on mock data.

**NeoCash loan apps**
- **Loan fix**: a declined application with three reasons to fix (verify a guarantor by OTP, add collateral, lower the amount). Fixed items collapse into "resolved", then you can resubmit.
- **Face check**: guided face capture. Steer a drawn face with the pointer; each step checks its target angle while capping the others, so a head tilt can't pass for a turn.
- **Field app**: toggle airplane mode and add customers. Rows queue in an outbox, then sync one at a time with a simulated failure and retry.

**Event marketplace (Ajarra)**
- **Calendar**: a day view where overlapping tasks split into columns, with a live "now" line and Creator / Co-planner / Viewer permissions.
- **Chat**: messages queue while offline, then send in order after reconnecting, with sent and read ticks, a flaky-server mode with tap-to-retry, and voice notes.
- **Map**: tap a vendor pin to draw the route and watch the car drive it while distance and ETA count down.

**OTP boxes**: type, paste or backspace a 6-digit code. Focus moves correctly, a wrong code shakes and the right one ticks green.

## Toys

- **Keyboard**: `←` `→` switch projects, `Enter` jumps to the demo, `E` emails me, `S` toggles sound effects, `?` shows all shortcuts
- **Sound effects**: off by default. The speaker toggle in the nav remembers your choice.
- **Music**: separate from sound effects. Pressing play always plays, and a pill in the nav lets you pause from anywhere on the page.
- There's also a cheat code, if you know the classic one.

All motion respects the OS "reduce motion" setting.

## Stack

- Flutter Web (Dart)
- `flutter_animate` for reveals and springs, `google_fonts` (Bricolage Grotesque, Geist, Geist Mono)
- `flutter_map` + `latlong2` with Esri's keyless dark basemap, so no API key ships to the browser
- `audioplayers` + `shared_preferences` for sound, `visibility_detector` to pause off-screen demos

## Project layout

```text
lib/
  data/portfolio_data.dart   # all site copy and content: edit this, not the widgets
  theme/app_theme.dart       # the 10 colour tokens, type, motion
  demos/                     # the three live demos
  services/sfx.dart          # sound effects
  widgets/                   # sections, phone frame, player card, toasts, confetti
tool/
  fetch_articles.dart        # RSS feeds -> assets/articles.json
  make_sfx.py                # synthesizes assets/sfx/*.wav
  make_icons.py              # draws the DN favicon and app icons
test/                        # layout checks at 3 widths, demo behaviour, keyboard play
```

## Running locally

```bash
flutter pub get
flutter run -d chrome
```

Production build:

```bash
flutter build web
python -m http.server 8765 --directory build/web   # then open http://localhost:8765
```

Deep links like `/#work`, `/#work-2` (opens the second demo) and `/#contact` jump straight to a section.

## Updating the playlist

The music tile plays 30-second previews in the site's own player. After changing the playlist link in `lib/data/portfolio_data.dart`:

```bash
dart run tool/fetch_playlist.dart
```

## Updating articles

Medium and Hashnode block browser requests, so articles are fetched at build time. Add your feed URLs at the top of `tool/fetch_articles.dart`, then:

```bash
dart run tool/fetch_articles.dart
```

## Tests

```bash
flutter analyze
flutter test
```

## Contact

- GitHub: [@damooola](https://github.com/damooola)
- Email: <damolanelson@gmail.com>
