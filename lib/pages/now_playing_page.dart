import 'package:flutter/material.dart';
import '../controllers/music_controller.dart';

class NowPlayingPage extends StatefulWidget {
  final dynamic song;
  final MusicController controller;

  NowPlayingPage({required this.song, required this.controller});

  @override
  _NowPlayingPageState createState() => _NowPlayingPageState();
}

class _NowPlayingPageState extends State<NowPlayingPage> {
  @override
  Widget build(BuildContext context) {
    final currentSong = widget.controller.currentSong;
    final title = currentSong?.title ?? "Sem música";
    final artist = currentSong?.artist ?? "Artista desconhecido";

    return Scaffold(
      appBar: AppBar(
        title: Text("Tocando agora"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.music_note, size: 100),
            SizedBox(height: 30),
            Text(
              title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              artist,
              style: TextStyle(fontSize: 18, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.check),
              label: Text("Marcar como ouvida"),
              onPressed: () {
                setState(() {
                  if (currentSong != null) currentSong.isChecked = true;
                });
              },
            ),
            SizedBox(height: 20),
            StreamBuilder<bool>(
              stream: widget.controller.playingStream,
              builder: (context, snapshot) {
                final isPlaying = snapshot.data ?? false;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.skip_previous, size: 36),
                      onPressed: () async {
                        await widget.controller.playPrevious();
                        setState(() {});
                      },
                    ),
                    SizedBox(width: 20),
                    ElevatedButton.icon(
                      icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                      label: Text(isPlaying ? "Pausar" : "Tocar"),
                      onPressed: () async {
                        await widget.controller.togglePlayPause();
                        setState(() {});
                      },
                    ),
                    SizedBox(width: 20),
                    IconButton(
                      icon: Icon(Icons.skip_next, size: 36),
                      onPressed: () async {
                        await widget.controller.playNext();
                        setState(() {});
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
