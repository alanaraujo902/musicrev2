import 'package:flutter/material.dart';
import '../models/playlist.dart';
import '../services/playlist_service.dart';
import 'playlist_songs_page.dart';
import '../controllers/music_controller.dart';

class PlaylistPage extends StatefulWidget {
  @override
  _PlaylistPageState createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  final PlaylistService _service = PlaylistService();
  List<Playlist> _playlists = [];

  @override
  void initState() {
    super.initState();
    _loadPlaylists();
  }

  Future<void> _loadPlaylists() async {
    final loaded = await _service.loadPlaylists();
    setState(() {
      _playlists = loaded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Playlists'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _playlists.isEmpty
          ? Center(child: Text('Nenhuma playlist salva'))
          : ListView.builder(
        itemCount: _playlists.length,
        itemBuilder: (context, index) {
          final playlist = _playlists[index];
          return ListTile(
            title: Text(playlist.name),
            subtitle: Text('${playlist.songs.length} músicas'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PlaylistSongsPage(
                    playlist: playlist,
                    onOrderSaved: (updatedPlaylist) {
                      final controller = MusicController();
                      if (controller.currentSong != null &&
                          updatedPlaylist.songs.any((s) => s.uri == controller.currentSong.uri)) {
                        controller.loadPlaylist(updatedPlaylist);
                      }

                      setState(() {
                        _playlists[index] = updatedPlaylist;
                      });

                      // Garante atualização visual ao retornar para a tela principal
                      Future.microtask(() {
                        Navigator.pop(context);
                      });
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
