import '../../services/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'music_base.dart'; // ✅ Importar a base corretamente

mixin MusicPlaybackController on MusicControllerBase {
  final AudioService _audioService = AudioService();
  AudioService get audioService => _audioService;

  final ValueNotifier<dynamic> currentSongNotifier = ValueNotifier(null);

  List<dynamic> songs = [];
  int _currentSongIndex = -1;
  dynamic _currentSong;

  Future<void> playSong(dynamic song) async {
    if (_currentSong?.uri == song.uri) return;
    _currentSong = song;
    _currentSongIndex = songs.indexWhere((s) => s.uri == song.uri);
    await _audioService.playFromUri(song.uri, song: song);
    currentSongNotifier.value = song;
  }

  Future<void> togglePlayPause() async {
    await _audioService.togglePlayPause();
  }

  Future<void> playNext() async {
    if (_currentSongIndex < songs.length - 1) {
      await playSong(songs[_currentSongIndex + 1]);
    }
  }

  Future<void> playPrevious() async {
    if (_currentSongIndex > 0) {
      await playSong(songs[_currentSongIndex - 1]);
    }
  }

  Future<void> seek(Duration position) async {
    await _audioService.seek(position);
  }

  dynamic get currentSong => _currentSong;
  Stream<bool> get playingStream => _audioService.playingStream;
  Stream<Duration> get positionStream => _audioService.positionStream;
  Stream<Duration?> get durationStream => _audioService.durationStream;
}
