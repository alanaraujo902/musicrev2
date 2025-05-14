import 'package:flutter/material.dart';
import '../controllers/music/music_controller.dart';
import '../widgets/now_playing_controls.dart';
import '../widgets/now_playing_header.dart';
import '../widgets/now_playing_progress.dart';
import '../widgets/now_playing_queue.dart';

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
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: widget.controller.currentSongNotifier,
          builder: (context, currentSong, _) {
            if (currentSong == null) {
              return Center(
                child: Text("Nenhuma música", style: TextStyle(color: Colors.white)),
              );
            }

            final remaining = widget.controller.songs
                .skipWhile((s) => s.uri != currentSong.uri)
                .skip(1)
                .toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                NowPlayingHeader(currentSong: currentSong),
                NowPlayingProgress(controller: widget.controller),
                NowPlayingControls(controller: widget.controller),
                NowPlayingQueue(
                  controller: widget.controller,
                  remaining: remaining,
                  onSongTap: () => setState(() {}),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

