import 'package:flutter/widgets.dart';

import 'spotify_embed_stub.dart'
    if (dart.library.js_interop) 'spotify_embed_web.dart'
    as impl;

/// Spotify's own player for a playlist, track or album link. It's an
/// iframe, so it only renders on the web; elsewhere (tests) it's empty.
class SpotifyEmbed extends StatelessWidget {
  final String shareUrl;
  final double height;

  const SpotifyEmbed({super.key, required this.shareUrl, this.height = 152});

  /// Turns a share link like open.spotify.com/playlist/ID?si=… into the
  /// embed URL, or null if it isn't a Spotify link we understand.
  static String? embedUrl(String shareUrl) {
    final m = RegExp(
      r'open\.spotify\.com/(?:intl-[a-z]+/)?(playlist|track|album|artist)/([A-Za-z0-9]+)',
    ).firstMatch(shareUrl);
    if (m == null) return null;
    return 'https://open.spotify.com/embed/${m.group(1)}/${m.group(2)}?utm_source=generator&theme=0';
  }

  @override
  Widget build(BuildContext context) {
    final url = embedUrl(shareUrl);
    if (url == null) return const SizedBox.shrink();
    return SizedBox(height: height, child: impl.buildIframe(url));
  }
}
