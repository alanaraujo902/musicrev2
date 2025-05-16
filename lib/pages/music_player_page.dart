import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import '../controllers/music/music_controller.dart';

import '../models/playlist.dart';
import '../models/local_song.dart';
import '../services/playlist_service.dart';
import '../widgets/song_list_widget.dart';

enum SortOption { alphabetical, reverseAlphabetical, byChecked, uncheckedFirst }

class MusicPlayerPage extends StatefulWidget {
  @override
  _MusicPlayerPageState createState() => _MusicPlayerPageState();
}

class _MusicPlayerPageState extends State<MusicPlayerPage> {
  final controller = MusicController();
  final PlaylistService playlistService = PlaylistService();
  bool hasSongs = false;
  SortOption? _currentSort;

  @override
  void initState() {
    super.initState();
    controller.loadPlaylistsToNotifier();
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
      _applyCurrentSort();
      setState(() {
        hasSongs = controller.songs.isNotEmpty;
      });
    }
  }

  void _applyCurrentSort() {
    if (_currentSort != null) _sortSongs(_currentSort!);
  }

  void _sortSongs(SortOption option) {
    setState(() {
      _currentSort = option;
      switch (option) {
        case SortOption.alphabetical:
          controller.songs.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
          break;
        case SortOption.reverseAlphabetical:
          controller.songs.sort((a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()));
          break;
        case SortOption.byChecked:
          controller.songs.sort((a, b) => b.isChecked.toString().compareTo(a.isChecked.toString()));
          break;
        case SortOption.uncheckedFirst:
          controller.songs.sort((a, b) => a.isChecked.toString().compareTo(b.isChecked.toString()));
          break;
      }
    });
  }

  void _savePlaylist() {
    showDialog(
      context: context,
      builder: (context) {
        final nameController = TextEditingController();
        return AlertDialog(
          title: Text("Nome da Playlist"),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(hintText: "Digite o nome"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancelar"),
            ),
            TextButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  final playlist = Playlist(
                    name: name,
                    songs: List<LocalSong>.from(controller.songs),
                  );
                  final all = await playlistService.loadPlaylists();
                  all.add(playlist);
                  await playlistService.savePlaylists(all);
                  controller.playlistsNotifier.value = List.from(all);
                  Navigator.pop(context);
                }
              },
              child: Text("Salvar"),
            ),
          ],
        );
      },
    );
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
                Navigator.pop(context);
                Navigator.pushNamed(context, '/');
              },
            ),
            ListTile(
              leading: Icon(Icons.playlist_play),
              title: Text('Playlists'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/playlists');
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
              label: Text('Selecionar Pasta'),
              onPressed: _selectDirectory,
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              icon: Icon(Icons.audiotrack),
              label: Text("Selecionar Arquivos MP3"),
              onPressed: () async {
                final result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['mp3'],
                  allowMultiple: true,
                );

                if (result != null) {
                  final files = result.paths.whereType<String>().toList();
                  final newSongs = <LocalSong>[];

                  for (final path in files) {
                    final dur = await controller.audioService.fetchDuration(Uri.file(path).toString());
                    final song = LocalSong(
                      id: path.hashCode,
                      title: path.split('/').last,
                      artist: 'Desconhecido',
                      uri: Uri.file(path).toString(),
                      durationMillis: dur?.inMilliseconds ?? 0,
                    );
                    newSongs.add(song);
                  }

                  controller.songs = newSongs;
                  _applyCurrentSort();
                  controller.currentSongNotifier.value = null;
                  controller.currentSongIndex = -1;
                  controller.currentSong = null;

                  setState(() {
                    hasSongs = newSongs.isNotEmpty;
                  });
                }
              },
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Ordenar por:", style: TextStyle(fontWeight: FontWeight.bold)),
                PopupMenuButton<SortOption>(
                  icon: Icon(Icons.sort),
                  onSelected: _sortSongs,
                  itemBuilder: (context) => [
                    PopupMenuItem(value: SortOption.alphabetical, child: Text('A-Z')),
                    PopupMenuItem(value: SortOption.reverseAlphabetical, child: Text('Z-A')),
                    PopupMenuItem(value: SortOption.byChecked, child: Text('Ouvidas por último')),
                    PopupMenuItem(value: SortOption.uncheckedFirst, child: Text('Não ouvidas primeiro')),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              icon: Icon(Icons.save),
              label: Text("Salvar Playlist"),
              onPressed: hasSongs ? _savePlaylist : null,
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
