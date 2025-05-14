import 'package:flutter/material.dart';
import '../models/playlist.dart';
import '../models/local_song.dart';
//import '../controllers/music_controller.dart';
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

  @override
  void initState() {
    super.initState();
    sortedSongs = List.of(widget.playlist.songs);
    controller.loadPlaylist(widget.playlist); // CORREÇÃO AQUI
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
      body: SongListWidget(songs: sortedSongs, controller: controller),
    );
  }
}
