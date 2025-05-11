import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/audio_service.dart';
import '../models/local_song.dart';

class MusicController {
  final _audioService = AudioService();
  List<dynamic> songs = [];
  int _currentSongIndex = -1;

  Future<void> init() async {
    final granted = await _requestPermissions();
    if (granted) {
      songs = await _audioService.loadSongs();
    }
  }

  Future<bool> _requestPermissions() async {
    return await Permission.storage.request().isGranted ||
        await Permission.audio.request().isGranted;
  }

  Future<bool> requestPermission() async {
    return await _requestPermissions();
  }

  Future<void> playSong(dynamic song) async {
    _currentSongIndex = songs.indexOf(song);
    final uri = song is SongModel ? song.uri! : song.uri;
    await _audioService.playFromUri(uri);
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

  dynamic get currentSong =>
      (_currentSongIndex >= 0 && _currentSongIndex < songs.length)
          ? songs[_currentSongIndex]
          : null;

  Stream<bool> get playingStream => _audioService.playingStream;

  Future<void> loadSongsFromDirectory(String directoryPath) async {
    songs = await _audioService.loadSongs(directoryPath: directoryPath);
  }

  void dispose() {
    _audioService.dispose();
  }
}