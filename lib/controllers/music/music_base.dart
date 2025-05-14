import 'package:flutter/foundation.dart';
import '../../models/playlist.dart';

abstract class MusicControllerBase {
  List<dynamic> songs = [];
  int _currentSongIndex = -1;
  dynamic _currentSong;
  Playlist? _loadedPlaylist;
  final ValueNotifier<dynamic> currentSongNotifier = ValueNotifier(null);
  final ValueNotifier<List<Playlist>> playlistsNotifier = ValueNotifier([]);

  dynamic get currentSong => _currentSong;
  set currentSong(dynamic song) => _currentSong = song;

  int get currentSongIndex => _currentSongIndex;
  set currentSongIndex(int index) => _currentSongIndex = index;

  Playlist? get loadedPlaylist => _loadedPlaylist;
  set loadedPlaylist(Playlist? playlist) => _loadedPlaylist = playlist;
}
