import 'package:flutter/material.dart';
import '../models/playlist.dart';
import '../controllers/music_controller.dart';
import '../widgets/song_list_widget.dart';

class PlaylistSongsPage extends StatelessWidget {
  final Playlist playlist;

  const PlaylistSongsPage({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    final controller = MusicController();
    final current = controller.currentSong;
    controller.songs = playlist.songs;
    if (current != null && playlist.songs.any((s) => s.uri == current.uri)) {
      controller.playSong(current);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Playlist: ${playlist.name}'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SongListWidget(songs: playlist.songs, controller: controller),
    );
  }
}
