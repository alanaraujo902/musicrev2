import 'package:flutter/material.dart';
import 'package:untitled1/models/playlist.dart';
import 'package:untitled1/models/playlist_folder.dart';
import 'package:untitled1/services/playlist_service.dart';
import 'package:untitled1/services/playlist_folder_service.dart';
import 'package:untitled1/pages/playlist_songs_page.dart';

class PlaylistPageController {
  final PlaylistService _playlistService = PlaylistService();
  final PlaylistFolderService _folderService = PlaylistFolderService();

  List<Playlist> loosePlaylists = [];
  List<PlaylistFolder> folders = [];

  void loadData(VoidCallback refresh) async {
    final all = await _playlistService.loadPlaylists();
    final saved = await _folderService.loadFolders();

    final foldered = saved.expand((f) => f.playlists.map((p) => p.name)).toSet();
    loosePlaylists = all.where((p) => !foldered.contains(p.name)).toList();
    folders = saved;
    refresh();
  }

  Future<void> createFolder(BuildContext context, VoidCallback refresh) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Nova Pasta"),
        content: TextField(controller: controller),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancelar")),
          ElevatedButton(
              onPressed: () {
                final txt = controller.text.trim();
                if (txt.isNotEmpty) Navigator.pop(context, txt);
              },
              child: Text("Criar")),
        ],
      ),
    );
    if (name != null) {
      folders.add(PlaylistFolder(name: name, playlists: []));
      await _folderService.saveFolders(folders);
      refresh();
    }
  }

  Future<void> saveFolders() async {
    await _folderService.saveFolders(folders);
  }

  void addToFolder(BuildContext context, Playlist playlist, VoidCallback refresh) async {
    final selected = await showDialog<PlaylistFolder>(
      context: context,
      builder: (_) => SimpleDialog(
        title: Text("Mover para pasta"),
        children: folders.map((f) => SimpleDialogOption(
          onPressed: () => Navigator.pop(context, f),
          child: Text(f.name),
        )).toList(),
      ),
    );
    if (selected != null) {
      folders.forEach((f) => f.playlists.removeWhere((p) => p.name == playlist.name));
      loosePlaylists.removeWhere((p) => p.name == playlist.name);
      selected.playlists.add(playlist);
      await saveFolders();
      refresh();
    }
  }

  //garante que os dados da playlist sejam sempre recarregados do disco:
  void openPlaylist(BuildContext context, Playlist playlist) async {
    final all = await _playlistService.loadPlaylists();
    final updated = all.firstWhere((p) => p.name == playlist.name, orElse: () => playlist);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlaylistSongsPage(
          playlist: updated,
          onOrderSaved: (_) => loadData(() {}),
        ),
      ),
    );
  }


}
