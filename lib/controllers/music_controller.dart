import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/audio_service.dart';
import '../models/local_song.dart';
import '../services/playlist_service.dart';
import '../models/playlist.dart';
import 'package:flutter/foundation.dart';


class MusicController {
  static final MusicController _instance = MusicController._internal();

  factory MusicController() => _instance;

  MusicController._internal() {
    _audioService.onSongComplete = _handleSongComplete;
  }

  final _audioService = AudioService();
  final PlaylistService _playlistService = PlaylistService();
  final ValueNotifier<dynamic> currentSongNotifier = ValueNotifier(null);


  List<dynamic> songs = [];
  int _currentSongIndex = -1;
  Playlist? _loadedPlaylist;

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
    await _audioService.playFromUri(uri, song: song);
    currentSongNotifier.value = song;
  }

  Future<void> togglePlayPause() async {
    await _audioService.togglePlayPause();
  }

  Future<void> playNext() async {
    if (_currentSongIndex < songs.length - 1) {
      await playSong(songs[_currentSongIndex + 1]);
      currentSongNotifier.value = currentSong;
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

  Stream<Duration> get positionStream => _audioService.positionStream;

  Stream<Duration?> get durationStream => _audioService.durationStream;

  Future<void> seek(Duration position) async {
    await _audioService.seek(position);
  }

  Future<void> loadSongsFromDirectory(String directoryPath) async {
    _loadedPlaylist = null;
    songs = await _audioService.loadSongs(directoryPath: directoryPath);
  }

  void loadPlaylist(Playlist playlist) {
    _loadedPlaylist = playlist;
    songs = playlist.songs;
  }

  void updateCurrentIndex() {
    final current = currentSong;
    if (current != null) {
      _currentSongIndex = songs.indexWhere((s) => s.uri == current.uri);
    }
  }

  void _handleSongComplete() {
    final current = currentSong;
    if (current != null) {
      current.isChecked = true;
    }
    playNext();
  }



  Future<void> persistOrderIfPlaylist() async {
    if (_loadedPlaylist != null) {
      final updated = Playlist(name: _loadedPlaylist!.name, songs: List<LocalSong>.from(songs));
      final all = await _playlistService.loadPlaylists();
      final idx = all.indexWhere((p) => p.name == _loadedPlaylist!.name);
      if (idx != -1) {
        all[idx] = updated;
        await _playlistService.savePlaylists(all);
      }
    }
  }

  void dispose() {
    _audioService.dispose();
  }
}
