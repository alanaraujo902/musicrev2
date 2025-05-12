import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../../models/local_song.dart';
import '../../controllers/music_controller.dart';
import '../pages/now_playing_page.dart';

class SongListWidget extends StatefulWidget {
  final List<dynamic> songs;
  final MusicController controller;

  const SongListWidget({
    super.key,
    required this.songs,
    required this.controller,
  });

  @override
  State<SongListWidget> createState() => _SongListWidgetState();
}

class _SongListWidgetState extends State<SongListWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<bool>(
            stream: widget.controller.playingStream,
            builder: (context, snapshot) {
              return ListView.builder(
                itemCount: widget.songs.length,
                itemBuilder: (context, index) {
                  final song = widget.songs[index];
                  final title = song.title;
                  final artist = song.artist ?? "Artista desconhecido";
                  final isPlaying = widget.controller.currentSong?.uri == song.uri;

                  return Container(
                    color: isPlaying ? Colors.orange.withOpacity(0.3) : null,
                    child: ListTile(
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
                        widget.controller.playSong(song);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => NowPlayingPage(
                              song: song,
                              controller: widget.controller,
                            ),
                          ),
                        ).then((_) => setState(() {}));
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
        StreamBuilder<bool>(
          stream: widget.controller.playingStream,
          builder: (context, snapshot) {
            final isPlaying = snapshot.data ?? false;
            return ElevatedButton.icon(
              icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
              label: Text(isPlaying ? "Pausar" : "Tocar"),
              onPressed: () async {
                await widget.controller.togglePlayPause();
                setState(() {});
              },
            );
          },
        ),
      ],
    );
  }
}
