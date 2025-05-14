import 'package:flutter/material.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import '../controllers/music/music_controller.dart';

class NowPlayingProgress extends StatelessWidget {
  final MusicController controller;

  const NowPlayingProgress({required this.controller});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration>(
      stream: controller.positionStream,
      builder: (context, positionSnapshot) {
        final position = positionSnapshot.data ?? Duration.zero;
        return StreamBuilder<Duration?>(
          stream: controller.durationStream,
          builder: (context, durationSnapshot) {
            final duration = durationSnapshot.data ?? Duration.zero;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ProgressBar(
                progress: position,
                total: duration,
                onSeek: controller.seek,
                baseBarColor: Colors.grey.shade700,
                progressBarColor: Colors.purpleAccent,
                thumbColor: Colors.purpleAccent,
                timeLabelTextStyle: TextStyle(color: Colors.white),
              ),
            );
          },
        );
      },
    );
  }
}