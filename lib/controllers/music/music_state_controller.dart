import '../../models/local_song.dart';
//import '../../models/playlist.dart';
import 'package:untitled1/models/playlist.dart';
import '../../services/checked_state_service.dart';
import '../../services/playlist_service.dart';
import '../../services/playlist_folder_service.dart';
import 'music_base.dart';
import 'package:flutter/foundation.dart';

mixin MusicStateController on MusicControllerBase {
  final _checkedStateService = CheckedStateService();
  final PlaylistService _playlistService = PlaylistService();

  Future<void> toggleFavorite(LocalSong song) async {
    song.isFavorite = !song.isFavorite;
    await _persistSongState(song);
  }

  Future<void> toggleChecked(LocalSong song, bool value) async {
    song.isChecked = value;
    if (loadedPlaylist != null) {
      await _persistSongState(song);
      await evaluatePlaylistCheckedStatus();
    } else {
      await _checkedStateService.saveCheckedState(song.uri, value);
    }
  }

  Future<void> _persistSongState(LocalSong updatedSong) async {
    if (loadedPlaylist != null) {
      final index = loadedPlaylist!.songs.indexWhere((s) => s.uri == updatedSong.uri);
      if (index != -1) {
        loadedPlaylist!.songs[index] = updatedSong;

        final all = await _playlistService.loadPlaylists();
        final idx = all.indexWhere((p) => p.name == loadedPlaylist!.name);
        if (idx != -1) {
          // ✅ recria a playlist com nova instância
          final updatedPlaylist = Playlist(
            name: loadedPlaylist!.name,
            songs: List<LocalSong>.from(loadedPlaylist!.songs),
            isChecked: loadedPlaylist!.isChecked,
          );
          all[idx] = updatedPlaylist;
          await _playlistService.savePlaylists(all);

          // ✅ notifica com nova lista de instâncias
          playlistsNotifier.value = List<Playlist>.from(all);
          loadedPlaylist = updatedPlaylist; // atualiza referência também
        }
      }
    }
  }


  Future<void> evaluatePlaylistCheckedStatus({VoidCallback? onStatusChanged}) async {
    if (loadedPlaylist != null) {
      final allChecked = loadedPlaylist!.songs.every((s) => s.isChecked);
      if (loadedPlaylist!.isChecked != allChecked) {
        loadedPlaylist!.isChecked = allChecked;
        final all = await _playlistService.loadPlaylists();
        final idx = all.indexWhere((p) => p.name == loadedPlaylist!.name);
        if (idx != -1) {
          all[idx] = loadedPlaylist!;
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
    final playlistService = PlaylistService();

    final folders = await folderService.loadFolders();
    final allPlaylists = await playlistService.loadPlaylists();

    bool changed = false;

    for (var folder in folders) {
      final upToDatePlaylists = folder.playlists.map((fp) {
        return allPlaylists.firstWhere((p) => p.name == fp.name, orElse: () => fp);
      }).toList();

      folder.playlists = upToDatePlaylists;

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
}
