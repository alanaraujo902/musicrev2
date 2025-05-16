library music_playlist_controller;                    // <— nome exclusivo

import 'music_base.dart';
import '../../models/local_song.dart';
import '../../services/playlist_service.dart';
import 'package:untitled1/models/playlist.dart';

mixin MusicPlaylistController on MusicControllerBase {
  final PlaylistService _playlistService = PlaylistService();

  /* -------------------- CARREGAR PLAYLISTS ----------------- */
  Future<void> loadPlaylistsToNotifier() async {
    final loaded = await _playlistService.loadPlaylists();
    playlistsNotifier.value = loaded;
  }

  void loadPlaylist(Playlist playlist) {
    loadedPlaylist = playlist;
    songs          = playlist.songs;
    updateCurrentIndex();
  }

  void updateCurrentIndex() {
    if (currentSong != null) {
      currentSongIndex =
          songs.indexWhere((s) => s.uri == currentSong.uri);
    }
  }

  /* --------------- SALVAR ORDEM PERSISTENTE ---------------- */
  Future<void> persistOrderIfPlaylist() async {
    if (loadedPlaylist == null) return;

    final updated = Playlist(
      name      : loadedPlaylist!.name,
      songs     : List<LocalSong>.from(songs),
      isChecked : loadedPlaylist!.isChecked,
    );

    final all  = await _playlistService.loadPlaylists();
    final idx  = all.indexWhere((p) => p.name == loadedPlaylist!.name);
    if (idx != -1) {
      all[idx] = updated;
      await _playlistService.savePlaylists(all);
      playlistsNotifier.value = List.from(all);
    }
  }
}
