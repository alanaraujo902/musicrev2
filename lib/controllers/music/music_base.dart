import 'package:flutter/foundation.dart';
import 'package:untitled1/models/playlist.dart';

abstract class MusicControllerBase {
  /* ---------------- LISTA / PLAYLIST ---------------- */
  List<dynamic> songs = [];
  int _currentSongIndex = -1;
  dynamic _currentSong;
  Playlist? _loadedPlaylist;

  /* ------------- NOTIFIERS PARA A UI --------------- */
  final ValueNotifier<dynamic>      currentSongNotifier   = ValueNotifier(null);
  final ValueNotifier<List<Playlist>> playlistsNotifier   = ValueNotifier([]);

  /// 🔄 Liga/desliga continuação automática após o término da faixa
  final ValueNotifier<bool> continuePlayingNotifier = ValueNotifier(true);

  /* ---------------- GETTERS / SETTERS -------------- */
  dynamic get currentSong        => _currentSong;
  set currentSong(dynamic song)  => _currentSong = song;

  int  get currentSongIndex      => _currentSongIndex;
  set currentSongIndex(int idx)  => _currentSongIndex = idx;

  Playlist? get loadedPlaylist   => _loadedPlaylist;
  set loadedPlaylist(Playlist? p) => _loadedPlaylist = p;

  bool get continuePlaying       => continuePlayingNotifier.value;
  set continuePlaying(bool v)    => continuePlayingNotifier.value = v;
}
