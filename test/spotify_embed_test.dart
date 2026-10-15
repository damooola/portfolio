import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/widgets/spotify_embed.dart';

void main() {
  test('share links become embed URLs', () {
    expect(
      SpotifyEmbed.embedUrl(
        'https://open.spotify.com/playlist/37i9dQZF1DXcBWIGoYBM5M?si=abc123',
      ),
      'https://open.spotify.com/embed/playlist/37i9dQZF1DXcBWIGoYBM5M?utm_source=generator&theme=0',
    );
    expect(
      SpotifyEmbed.embedUrl(
        'https://open.spotify.com/intl-fr/track/4uLU6hMCjMI75M1A2tKUQC',
      ),
      'https://open.spotify.com/embed/track/4uLU6hMCjMI75M1A2tKUQC?utm_source=generator&theme=0',
    );
  });

  test('empty or non-Spotify links are ignored', () {
    expect(SpotifyEmbed.embedUrl(''), isNull);
    expect(SpotifyEmbed.embedUrl('https://example.com/playlist/abc'), isNull);
  });
}
