import 'package:flutter/widgets.dart';

/// Non-web builds (tests) have no iframes.
Widget buildIframe(String url) => const SizedBox.shrink();
