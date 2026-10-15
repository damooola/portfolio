# Damola Nelson — Portfolio

My personal portfolio site, built with **Flutter Web**. I'm a Flutter mobile engineer in Lagos building fintech apps: lending, offline-first field tools, and the parts that don't make the demo (bad networks, encrypted local data, retries that don't double-charge).

The design borrows from fintech itself: section dividers marked with ₦, a KPI "ledger", projects laid out as torn-edge receipts, and a debit-card-style identity card with a guilloché (banknote) pattern.

## Sections

Hero → (01) Ledger → (02) About → (03) Work → (04) Stack → (05) Let's talk

- **Ledger:** headline stats, every figure taken from my resume
- **Work:** three case studies: an offline-first field agent app, a consumer lending app, and an event marketplace
- **Let's talk:** contact links and a downloadable resume

## Stack

- Flutter Web (Dart)
- [`google_fonts`](https://pub.dev/packages/google_fonts): Fraunces, Inter, JetBrains Mono
- [`url_launcher`](https://pub.dev/packages/url_launcher)
- Custom painters for the guilloché texture, receipt edges, and scroll ruler

## Project layout

```text
lib/
  data/portfolio_data.dart   # all site copy and content: edit this, not the widgets
  theme/app_theme.dart       # colors, type scale, design tokens
  widgets/                   # one file per section and decorative component
assets/resume.pdf            # resume linked from the contact section
test/widget_test.dart        # overflow checks at phone, tablet, and desktop widths
```text

## Running locally

```bash
flutter pub get
flutter run -d chrome
```text

Production build:

```bash
flutter build web
python -m http.server 8765 --directory build/web   # then open http://localhost:8765
```text

## Tests

```bash
flutter analyze
flutter test
```text

## Contact

- GitHub: [@damooola](https://github.com/damooola)
- Email: <damolanelson@gmail.com>
