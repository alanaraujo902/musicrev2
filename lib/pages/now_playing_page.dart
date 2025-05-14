import 'package:flutter/material.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
//import '../controllers/music_controller.dart';
import '../controllers/music/music_controller.dart';


class NowPlayingPage extends StatefulWidget {
  final dynamic song;
  final MusicController controller;

  NowPlayingPage({required this.song, required this.controller});

  @override
  _NowPlayingPageState createState() => _NowPlayingPageState();
}

class _NowPlayingPageState extends State<NowPlayingPage> {
  String? lyrics;

  @override
  void initState() {
    super.initState();
    _loadLyrics();
  }

  void _loadLyrics() {
    final title = widget.song.title.toLowerCase().replaceAll(RegExp(r'\.mp3$'), '');
    final mockLyrics = {
      'example': 'Esta é a letra da música exemplo.\nLinha 2...\nLinha 3...',
    };

    setState(() {
      lyrics = mockLyrics[title] ?? 'Letra não disponível para esta música.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.controller.currentSongNotifier,
      builder: (context, currentSong, _) {
        final title = currentSong?.title ?? "Sem música";
        final artist = currentSong?.artist ?? "Artista desconhecido";

        return Scaffold(
          appBar: AppBar(
            title: Text("Tocando agora"),
          ),
          body: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
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
                SizedBox(height: 30),
                if (currentSong != null)
                  CheckboxListTile(
                    title: Text("Marcar como ouvida"),
                    value: currentSong.isChecked,
                    onChanged: (value) async {
                      await widget.controller.toggleChecked(currentSong, value ?? false);
                      await widget.controller.evaluatePlaylistCheckedStatus(); // garante update do isChecked da playlist
                      setState(() {}); // força rebuild da UI com o novo status
                    },

                  ),

                IconButton(
                  icon: Icon(
                    currentSong.isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: currentSong.isFavorite ? Colors.red : null,
                  ),
                  onPressed: () async {
                    await widget.controller.toggleFavorite(currentSong);
                    setState(() {});
                  },
                ),


                SizedBox(height: 20),
                StreamBuilder<Duration>(
                  stream: widget.controller.positionStream,
                  builder: (context, positionSnapshot) {
                    final position = positionSnapshot.data ?? Duration.zero;
                    return StreamBuilder<Duration?>(
                      stream: widget.controller.durationStream,
                      builder: (context, durationSnapshot) {
                        final duration = durationSnapshot.data ?? Duration.zero;
                        return ProgressBar(
                          progress: position,
                          total: duration,
                          onSeek: (duration) {
                            widget.controller.seek(duration);
                          },
                        );
                      },
                    );
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
                SizedBox(height: 30),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      lyrics ?? "Carregando letra...",
                      style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
