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
    final title = widget.song.title;
    final artist = widget.song.artist ?? "Artista desconhecido";

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
            Text(widget.controller.currentSong.title,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            SizedBox(height: 10),
            Text(widget.controller.currentSong.artist ?? "Artista desconhecido",
                style: TextStyle(fontSize: 18, color: Colors.grey),
                textAlign: TextAlign.center),
            SizedBox(height: 40),
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