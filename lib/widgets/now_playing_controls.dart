import 'package:flutter/material.dart';
import '../controllers/music/music_controller.dart';

class NowPlayingControls extends StatelessWidget {
  final MusicController controller;

  const NowPlayingControls({required this.controller});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: controller.playingStream,
      builder: (context, snapshot) {
        final isPlaying = snapshot.data ?? false;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.skip_previous, color: Colors.black),
              onPressed: controller.playPrevious,
              iconSize: 40,
            ),
            SizedBox(width: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: CircleBorder(),
                padding: EdgeInsets.all(12), // 🔽 menor que 20
                backgroundColor: Colors.purpleAccent.shade100,
              ),
              child: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                size: 28, // 🔽 reduzido de 32
                color: Colors.black,
              ),
              onPressed: controller.togglePlayPause,
            ),
            SizedBox(width: 20),
            IconButton(
              icon: Icon(Icons.skip_next, color: Colors.black),
              onPressed: controller.playNext,
              iconSize: 40,
            ),
          ],
        );
      },
    );
  }
}