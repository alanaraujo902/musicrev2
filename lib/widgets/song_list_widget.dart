import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../../models/local_song.dart';
import '../../controllers/music_controller.dart';
import '../pages/now_playing_page.dart';

class SongListWidget extends StatelessWidget {
  final List<dynamic> songs;
  final MusicController controller;

  const SongListWidget({
    super.key,
    required this.songs,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];
              final title = song.title;
              final artist = song.artist ?? "Artista desconhecido";

              return ListTile(
                leading: song is SongModel
                    ? QueryArtworkWidget(
                  id: song.id,
                  type: ArtworkType.AUDIO,
                  nullArtworkWidget: Icon(Icons.music_note),
                )
                    : Icon(Icons.music_note),
                title: Text(title),
                subtitle: Text(artist),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NowPlayingPage(
                        song: song,
                        controller: controller,
                      ),
                    ),
                  );
                  controller.playSong(song);
                },
              );
            },
          ),
        ),
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
    );
  }
}
