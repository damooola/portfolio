// Fonts are bundled (runtime fetching is off on the live site), so every
// weight of every family the site uses must be in assets/google_fonts/.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const weights = [
    'Thin',
    'ExtraLight',
    'Light',
    'Regular',
    'Medium',
    'SemiBold',
    'Bold',
    'ExtraBold',
    'Black',
  ];
  const families = {
    // Bricolage Grotesque only comes in 200–800.
    'BricolageGrotesque': [
      'ExtraLight',
      'Light',
      'Regular',
      'Medium',
      'SemiBold',
      'Bold',
      'ExtraBold',
    ],
    'Geist': weights,
    'GeistMono': weights,
  };

  for (final MapEntry(key: family, value: variants) in families.entries) {
    test('$family: every weight is bundled', () async {
      for (final v in variants) {
        final data = await rootBundle.load(
          'assets/google_fonts/$family-$v.ttf',
        );
        expect(data.lengthInBytes, greaterThan(10000), reason: '$family-$v');
      }
    });
  }
}
