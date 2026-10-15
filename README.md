# Damola Nelson — Portfolio

My personal portfolio site, built with **Flutter Web**. I'm a Flutter mobile engineer in Lagos, and instead of listing what I've built, the site lets you use it: every project comes with a working Flutter demo running inside a phone frame.

The concept is **After Hours**: a dark navy room, a soft blue glow that follows the cursor, and small things to pick up and play with. It's a clean portfolio if you only scroll, with extra toys for anyone who pokes around.

## Sections

| Section | What it does |
| --- | --- |
| Hero | The name drops in letter by letter, plus a status pill and four "now playing" tiles: live Chess.com rating with my last win on a board, my playlist in a custom preview player, Chelsea's live score and next game, and what I'm learning. Hover to preview, click to pin |
| 01 Work | Three projects, each with a live demo in a phone that tilts toward the cursor |
| 02 Skills | A football-game player card that flips to show the attribute bars |
| 03 Trophies | Resume stats shown as console-style achievements |
| 04 Writing | A draggable row of Flutter articles from Hashnode and Coder Legion, plus three personal Medium essays shown on phones |
| 05 Contact | Click to copy my email, or press **E** |

## Live demos

All demos run on mock data and were rebuilt from scratch. None of them use employer code.

- **Offline sync**: toggle airplane mode and add customers. Rows queue in an outbox, then sync one at a time with a simulated failure and retry.
- **Map and live route**: tap a vendor pin to draw the route and watch the car drive it while distance and ETA count down.
- **OTP boxes**: type, paste or backspace a 6-digit code. Focus moves correctly, a wrong code shakes and the right one ticks green.

## Toys

- **Keyboard**: `←` `→` switch projects, `Enter` jumps to the demo, `E` emails me, `S` toggles sound, `?` shows all shortcuts
- **Sound**: off by default. The speaker toggle in the nav remembers your choice.
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
