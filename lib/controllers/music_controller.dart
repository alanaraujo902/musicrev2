import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/audio_service.dart';
import '../models/local_song.dart';
import '../services/playlist_service.dart';
import '../models/playlist.dart';
import 'package:flutter/foundation.dart';
import '../services/checked_state_service.dart';
import '../services/playlist_folder_service.dart';


class MusicController {
  static final MusicController _instance = MusicController._internal();
  factory MusicController() => _instance;

  final CheckedStateService _checkedStateService = CheckedStateService();
  final _audioService = AudioService();
  final PlaylistService _playlistService = PlaylistService();
  final ValueNotifier<dynamic> currentSongNotifier = ValueNotifier(null);
  final ValueNotifier<List<Playlist>> playlistsNotifier = ValueNotifier([]);

  MusicController._internal() {
    _audioService.onSongComplete = _handleSongComplete;
  }

  List<dynamic> songs = [];
  int _currentSongIndex = -1;
  dynamic _currentSong;
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

  Future<void> loadPlaylistsToNotifier() async {
    final loaded = await _playlistService.loadPlaylists();
    playlistsNotifier.value = loaded;
  }

  Future<void> playSong(dynamic song) async {
    if (currentSong?.uri == song.uri) return;

    _currentSong = song;
    _currentSongIndex = songs.indexWhere((s) => s.uri == song.uri);
    final uri = song is SongModel ? song.uri! : song.uri;

    // 🔧 Se a playlist está carregada, verifique se isso era a última música faltando
    if (_loadedPlaylist != null) {
      final uriSet = _loadedPlaylist!.songs.map((s) => s.uri).toSet();
      final unchecked = _loadedPlaylist!.songs.where((s) => !s.isChecked).toList();

      if (unchecked.length == 1 && unchecked.first.uri == song.uri) {
        song.isChecked = true;
        await _persistSongState(song);
        await evaluatePlaylistCheckedStatus();
      }
    }

    await _audioService.playFromUri(uri, song: song);
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

  dynamic get currentSong => _currentSong;
  Stream<bool> get playingStream => _audioService.playingStream;
  Stream<Duration> get positionStream => _audioService.positionStream;
  Stream<Duration?> get durationStream => _audioService.durationStream;

  Future<void> seek(Duration position) async {
    await _audioService.seek(position);
  }

  Future<void> loadSongsFromDirectory(String directoryPath) async {
    _loadedPlaylist = null;
    songs = await _audioService.loadSongs(directoryPath: directoryPath);

    final checkedStates = await _checkedStateService.loadCheckedStates();
    for (var song in songs) {
      if (checkedStates.containsKey(song.uri)) {
        song.isChecked = checkedStates[song.uri]!;
      }
    }
  }

  void loadPlaylist(Playlist playlist) {
    _loadedPlaylist = playlist;
    songs = playlist.songs;
    updateCurrentIndex();
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
      if (_loadedPlaylist != null) {
        _persistSongState(current);
        evaluatePlaylistCheckedStatus();
      }
    }
    playNext();
  }

  Future<void> persistOrderIfPlaylist() async {
    if (_loadedPlaylist != null) {
      final updated = Playlist(
        name: _loadedPlaylist!.name,
        songs: List<LocalSong>.from(songs),
        isChecked: _loadedPlaylist!.isChecked,
      );
      final all = await _playlistService.loadPlaylists();
      final idx = all.indexWhere((p) => p.name == _loadedPlaylist!.name);
      if (idx != -1) {
        all[idx] = updated;
        await _playlistService.savePlaylists(all);
        playlistsNotifier.value = List.from(all);
      }
    }
  }

  Future<void> toggleFavorite(LocalSong song) async {
    song.isFavorite = !song.isFavorite;
    await _persistSongState(song);
  }

  Future<void> toggleChecked(LocalSong song, bool value) async {
    song.isChecked = value;

    if (_loadedPlaylist != null) {
      await _persistSongState(song);
      await evaluatePlaylistCheckedStatus(); // <-- AQUI, agora com await
    } else {
      await _checkedStateService.saveCheckedState(song.uri, value);
    }
  }

  Future<void> _persistSongState(LocalSong updatedSong) async {
    if (_loadedPlaylist != null) {
      final index = _loadedPlaylist!.songs.indexWhere((s) => s.uri == updatedSong.uri);
      if (index != -1) {
        _loadedPlaylist!.songs[index] = updatedSong;
        final all = await _playlistService.loadPlaylists();
        final idx = all.indexWhere((p) => p.name == _loadedPlaylist!.name);
        if (idx != -1) {
          all[idx] = _loadedPlaylist!;
          await _playlistService.savePlaylists(all);
          playlistsNotifier.value = List.from(all);
        }
      }
    }
  }

  Future<void> evaluatePlaylistCheckedStatus({VoidCallback? onStatusChanged}) async {

    if (_loadedPlaylist != null) {
      final allChecked = _loadedPlaylist!.songs.every((s) => s.isChecked);
      if (_loadedPlaylist!.isChecked != allChecked) {
        _loadedPlaylist!.isChecked = allChecked;
        final all = await _playlistService.loadPlaylists();
        final idx = all.indexWhere((p) => p.name == _loadedPlaylist!.name);
        if (idx != -1) {
          all[idx] = _loadedPlaylist!;
          await _playlistService.savePlaylists(all);
          playlistsNotifier.value = List.from(all);
          await evaluateFolderCheckedStatus();
          if (onStatusChanged != null) onStatusChanged();
        }
      }
    }
  }


  Future<void> evaluateFolderCheckedStatus() async {
    final folderService = PlaylistFolderService();
    final folders = await folderService.loadFolders();

    bool changed = false;
    for (var folder in folders) {
      final allChecked = folder.playlists.isNotEmpty && folder.playlists.every((p) => p.isChecked);
      if (folder.isChecked != allChecked) {
        folder.isChecked = allChecked;
        changed = true;
      }
    }

    if (changed) {
      await folderService.saveFolders(folders);
    }
  }


  void dispose() {
    _audioService.dispose();
  }
}
