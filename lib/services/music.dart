import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class Track {
  final String title;
  final String artist;
  final Duration length;
  final String? preview;
  final String url;

  const Track(this.title, this.artist, this.length, this.preview, this.url);
}

class Playlist {
  final String name;
  final String owner;
  final String url;
  final String? cover;
  final List<Track> tracks;

  const Playlist(this.name, this.owner, this.url, this.cover, this.tracks);

  /// From assets/playlist.json, written by tool/fetch_playlist.dart.
  static Future<Playlist?> load() async {
    try {
      final json =
          jsonDecode(await rootBundle.loadString('assets/playlist.json'))
              as Map<String, dynamic>;
      return Playlist(
        json['name'] as String,
        json['owner'] as String? ?? '',
        json['url'] as String,
        json['cover'] as String?,
        [
          for (final t in (json['tracks'] as List).cast<Map<String, dynamic>>())
            Track(
              t['title'] as String,
              t['artist'] as String,
              Duration(milliseconds: t['durationMs'] as int? ?? 0),
              t['preview'] as String?,
              t['url'] as String,
            ),
        ],
      );
    } catch (_) {
      return null;
    }
  }
}

/// Plays 30-second Spotify previews in order. One shared instance, so the
/// hero's player and the nav's "now playing" pill control the same music,
/// and it keeps going while the visitor looks around the page.
///
/// Music is separate from sound effects ([Sfx]): pressing play always
/// plays, and never switches the effects on.
class PlaylistController extends ChangeNotifier {
  PlaylistController();

  static final instance = PlaylistController();

  Playlist? playlist;
  int index = 0;
  bool playing = false;
  Duration position = Duration.zero;
  Duration duration = const Duration(seconds: 30);

  AudioPlayer? _player;
  final _subs = <StreamSubscription<Object?>>[];
  bool _disposed = false;

  /// Async work (asset load, audio events) can finish after a controller is
  /// disposed; drop those updates instead of notifying.
  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  Track? get current => playlist?.tracks.elementAtOrNull(index);

  Future<void>? _loading;

  /// Loads the playlist once; later calls reuse the first load.
  Future<void> load() => _loading ??= () async {
    playlist = await Playlist.load();
    notifyListeners();
  }();

  /// Something is loaded in the player (playing or paused mid-track).
  bool get active => playing || position > Duration.zero;

  AudioPlayer _ensurePlayer() {
    final existing = _player;
    if (existing != null) return existing;
    final player = AudioPlayer();
    _subs.addAll([
      player.onPositionChanged.listen((p) {
        position = p;
        notifyListeners();
      }),
      player.onDurationChanged.listen((d) {
        if (d > Duration.zero) duration = d;
        notifyListeners();
      }),
      player.onPlayerComplete.listen((_) => next()),
    ]);
    return _player = player;
  }

  Future<void> playAt(int i) async {
    final tracks = playlist?.tracks;
    if (tracks == null || tracks.isEmpty) return;
    index = i % tracks.length;
    final url = tracks[index].preview;
    if (url == null) return next();
    position = Duration.zero;
    playing = true;
    notifyListeners();
    try {
      await _ensurePlayer().play(UrlSource(url));
    } catch (_) {
      playing = false;
      notifyListeners();
    }
  }

  Future<void> toggle() async {
    if (playing) {
      playing = false;
      notifyListeners();
      await _player?.pause();
    } else if (_player != null && position > Duration.zero) {
      playing = true;
      notifyListeners();
      await _player!.resume();
    } else {
      await playAt(index);
    }
  }

  Future<void> next() => playAt(index + 1);
  Future<void> previous() => playAt(index - 1);

  @override
  void dispose() {
    _disposed = true;
    for (final s in _subs) {
      s.cancel();
    }
    _player?.dispose();
    super.dispose();
  }
}
