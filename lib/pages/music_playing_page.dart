import 'package:flutter/material.dart';
import '../controllers/music_controller.dart';
import '../models/local_song.dart';
import 'package:on_audio_query/on_audio_query.dart';

class MusicPlayingPage extends StatelessWidget {
  final dynamic song;
  final MusicController controller;

  MusicPlayingPage({required this.song, required this.controller});

  @override
  Widget build(BuildContext context) {
    final title = song.title;
    final artist = song.artist ?? 'Artista desconhecido';

    return Scaffold(
      appBar: AppBar(title: Text('Tocando agora')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (song is SongModel)
              QueryArtworkWidget(
                id: song.id,
                type: ArtworkType.AUDIO,
                artworkHeight: 250,
                artworkWidth: 250,
                nullArtworkWidget: Icon(Icons.music_note, size: 250),
              )
            else
              Icon(Icons.music_note, size: 250),
            SizedBox(height: 20),
            Text(title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(artist, style: TextStyle(fontSize: 18)),
            SizedBox(height: 40),
            StreamBuilder<bool>(
              stream: controller.playingStream,
              builder: (context, snapshot) {
                final isPlaying = snapshot.data ?? false;
                return ElevatedButton.icon(
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                  label: Text(isPlaying ? "Pausar" : "Tocar"),
                  onPressed: controller.togglePlayPause,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
