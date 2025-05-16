import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import '../dialogs/add_to_playlist_dialog.dart';
import '../models/playlist.dart';
import '../models/local_song.dart';
import '../controllers/music/music_controller.dart';
import '../services/playlist_service.dart';
import '../widgets/song_list_widget.dart';

enum SortOption { alphabetical, reverseAlphabetical, byChecked, uncheckedFirst }

class PlaylistSongsPage extends StatefulWidget {
  final Playlist playlist;
  final void Function(Playlist)? onOrderSaved;

  const PlaylistSongsPage({
    super.key,
    required this.playlist,
    this.onOrderSaved,
  });

  @override
  State<PlaylistSongsPage> createState() => _PlaylistSongsPageState();
}

class _PlaylistSongsPageState extends State<PlaylistSongsPage> {
  late List<LocalSong> sortedSongs;
  final controller = MusicController();
  final PlaylistService playlistService = PlaylistService();
  bool isRemoving = false;

  @override
  void initState() {
    super.initState();
    sortedSongs = List.of(widget.playlist.songs);
    controller.loadPlaylist(widget.playlist);
  }

  void _sortSongs(SortOption option) {
    setState(() {
      switch (option) {
        case SortOption.alphabetical:
          sortedSongs.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
          break;
        case SortOption.reverseAlphabetical:
          sortedSongs.sort((a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()));
          break;
        case SortOption.byChecked:
          sortedSongs.sort((a, b) => b.isChecked.toString().compareTo(a.isChecked.toString()));
          break;
        case SortOption.uncheckedFirst:
          sortedSongs.sort((a, b) => a.isChecked.toString().compareTo(b.isChecked.toString()));
          break;
      }
      controller.songs = sortedSongs;
    });
  }

  Future<void> _saveOrder() async {
    final updated = Playlist(name: widget.playlist.name, songs: sortedSongs);
    final all = await playlistService.loadPlaylists();
    final idx = all.indexWhere((p) => p.name == widget.playlist.name);
    if (idx != -1) {
      all[idx] = updated;
      await playlistService.savePlaylists(all);

      if (widget.onOrderSaved != null) {
        widget.onOrderSaved!(updated);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ordem salva com sucesso!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Playlist: ${widget.playlist.name}'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.music_note),
            tooltip: 'Adicionar músicas individuais',
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

                final updated = Playlist(
                  name: widget.playlist.name,
                  songs: [
                    ...widget.playlist.songs,
                    ...newSongs.where((s) =>
                    !widget.playlist.songs.any((e) => e.uri == s.uri)),
                  ],
                );

                final all = await playlistService.loadPlaylists();
                final idx = all.indexWhere((p) => p.name == widget.playlist.name);
                if (idx != -1) {
                  all[idx] = updated;
                  await playlistService.savePlaylists(all);
                  controller.playlistsNotifier.value = List.from(all);
                  setState(() {
                    sortedSongs = updated.songs;
                  });
                }
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.folder_open),
            tooltip: 'Adicionar músicas de uma pasta',
            onPressed: () async {
              final rootPath = Directory('/storage/emulated/0');
              String? path = await FilesystemPicker.open(
                title: 'Selecione uma pasta de músicas',
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
                final foundSongs = await controller.audioService.loadSongs(directoryPath: path);
                final localSongs = foundSongs.whereType<LocalSong>().toList();

                if (localSongs.isEmpty) return;

                final updated = Playlist(
                  name: widget.playlist.name,
                  songs: [
                    ...widget.playlist.songs,
                    ...localSongs.where((s) =>
                    !widget.playlist.songs.any((e) => e.uri == s.uri)),
                  ],
                );

                final all = await playlistService.loadPlaylists();
                final idx = all.indexWhere((p) => p.name == widget.playlist.name);
                if (idx != -1) {
                  all[idx] = updated;
                  await playlistService.savePlaylists(all);
                  controller.playlistsNotifier.value = List.from(all);
                  setState(() {
                    sortedSongs = updated.songs;
                  });
                }
              }
            },
          ),
          IconButton(
            icon: Icon(isRemoving ? Icons.cancel : Icons.playlist_remove),
            tooltip: isRemoving ? 'Cancelar remoção' : 'Remover músicas',
            onPressed: () {
              setState(() => isRemoving = !isRemoving);
            },
          ),
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveOrder,
            tooltip: 'Salvar nova ordem',
          ),
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
      body: SongListWidget(
        songs: sortedSongs,
        controller: controller,
        showRemoveIcon: isRemoving,
        onConfirmRemove: (toRemove) async {
          sortedSongs.removeWhere((s) => toRemove.contains(s));
          final updated = Playlist(name: widget.playlist.name, songs: sortedSongs);
          final all = await playlistService.loadPlaylists();
          final idx = all.indexWhere((p) => p.name == widget.playlist.name);
          if (idx != -1) {
            all[idx] = updated;
            await playlistService.savePlaylists(all);
            controller.playlistsNotifier.value = List.from(all);
          }
          setState(() {});
        },
      ),
    );
  }
}
