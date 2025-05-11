import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../controllers/music_controller.dart';

class MusicPlayerPage extends StatefulWidget {
  @override
  _MusicPlayerPageState createState() => _MusicPlayerPageState();
}

class _MusicPlayerPageState extends State<MusicPlayerPage> {
  final controller = MusicController();

  @override
  void initState() {
    super.initState();
    controller.init().then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Músicas Locais')),
      body: Column(
        children: [
          Expanded(
            child: controller.songs.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: controller.songs.length,
              itemBuilder: (context, index) {
                final song = controller.songs[index];
                return ListTile(
                  leading: QueryArtworkWidget(
                    id: song.id,
                    type: ArtworkType.AUDIO,
                    nullArtworkWidget: Icon(Icons.music_note),
                  ),
                  title: Text(song.title),
                  subtitle: Text(song.artist ?? "Artista desconhecido"),
                  onTap: () => controller.playSong(song),
                );
              },
            ),
          ),
          StreamBuilder<bool>(
            stream: controller.playingStream,
            builder: (context, snapshot) {
              final isPlaying = snapshot.data ?? false;
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                  label: Text(isPlaying ? "Pausar" : "Tocar"),
                  onPressed: controller.togglePlayPause,
                ),
              );
            },
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
