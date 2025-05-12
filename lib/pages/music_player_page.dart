import 'dart:io';
import 'package:flutter/material.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import '../controllers/music_controller.dart';
import '../models/playlist.dart';
import '../models/local_song.dart';
import '../services/playlist_service.dart';
import '../widgets/song_list_widget.dart';
import '../widgets/playlist_card.dart';
import '../dialogs/save_playlist_dialog.dart';
import '../dialogs/add_to_playlist_dialog.dart';

class MusicPlayerPage extends StatefulWidget {
  @override
  _MusicPlayerPageState createState() => _MusicPlayerPageState();
}

class _MusicPlayerPageState extends State<MusicPlayerPage> {
  final controller = MusicController();
  final PlaylistService playlistService = PlaylistService();
  List<Playlist> playlists = [];
  bool hasSongs = false;

  @override
  void initState() {
    super.initState();
    _loadPlaylists();
  }

  Future<void> _loadPlaylists() async {
    final loaded = await playlistService.loadPlaylists();
    setState(() {
      playlists = loaded;
    });
  }

  Future<void> _selectDirectory() async {
    final rootPath = Directory('/storage/emulated/0');

    String? path = await FilesystemPicker.open(
      title: 'Selecione uma pasta',
      context: context,
      rootDirectory: rootPath,
      fsType: FilesystemType.folder,
      folderIconColor: Colors.teal,
      pickText: 'Selecionar esta pasta',
      requestPermission: () async {
        return await controller.requestPermission();
      },
    );

    if (path != null) {
      await controller.loadSongsFromDirectory(path);
      setState(() {
        hasSongs = controller.songs.isNotEmpty;
      });
    }
  }

  void _savePlaylist() {
    showSavePlaylistDialog(
      context: context,
      songs: controller.songs,
      onSaved: (playlist) async {
        playlists.add(playlist);
        await playlistService.savePlaylists(playlists);
        await _loadPlaylists();
      },
    );
  }

  void _addToPlaylist(Playlist playlist) {
    showAddToPlaylistDialog(
      context: context,
      availableSongs: controller.songs,
      playlist: playlist,
      onUpdated: (updatedPlaylist) async {
        final index = playlists.indexWhere((p) => p.name == updatedPlaylist.name);
        if (index != -1) {
          playlists[index] = updatedPlaylist;
          await playlistService.savePlaylists(playlists);
          setState(() {});
        }
      },
    );
  }

  void _loadPlaylist(Playlist playlist) {
    setState(() {
      controller.songs = playlist.songs;
      hasSongs = playlist.songs.isNotEmpty;
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Músicas Locais')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: Icon(Icons.library_music),
              title: Text('Músicas'),
              onTap: () {
                Navigator.pop(context); // Fecha o drawer
                Navigator.pushNamed(context, '/'); // Para Músicas
              },
            ),
            ListTile(
              leading: Icon(Icons.playlist_play),
              title: Text('Playlists'),
              onTap: () {
                Navigator.pop(context); // Fecha o drawer
                Navigator.pushNamed(context, '/playlists'); // Vai para a tela de playlists
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              icon: Icon(Icons.folder_open),
              label: Text('Selecionar Músicas'),
              onPressed: _selectDirectory,
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              icon: Icon(Icons.save),
              label: Text("Salvar Playlist"),
              onPressed: hasSongs ? _savePlaylist : null,
            ),
            SizedBox(height: 10),
            Text("Playlists Salvas", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: playlists.length,
                itemBuilder: (context, index) {
                  return PlaylistCard(
                    playlist: playlists[index],
                    onAddSongs: _addToPlaylist,
                    onLoad: _loadPlaylist,
                    onRemoveSongs: (updated) async {
                      final idx = playlists.indexWhere((p) => p.name == updated.name);
                      if (idx != -1) {
                        playlists[idx] = updated;
                        await playlistService.savePlaylists(playlists);
                        setState(() {});
                      }
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            if (hasSongs)
              Expanded(
                child: SongListWidget(
                  songs: controller.songs,
                  controller: controller,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
