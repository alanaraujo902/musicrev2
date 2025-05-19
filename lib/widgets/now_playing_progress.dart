import 'package:flutter/material.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import '../controllers/music/music_controller.dart';

class NowPlayingProgress extends StatelessWidget {
  final MusicController controller;

  const NowPlayingProgress({required this.controller});

  String _fmt(Duration d) =>
      '${d.inMinutes.remainder(60).toString().padLeft(2, '0')}:'
          '${d.inSeconds.remainder(60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration>(
      stream: controller.positionStream,
      builder: (context, posSnap) {
        final pos = posSnap.data ?? Duration.zero;

        return StreamBuilder<Duration?>(
          stream: controller.durationStream,
          builder: (context, durSnap) {
            final dur = durSnap.data ?? Duration.zero;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ProgressBar(
                    progress: pos,
                    total: dur,
                    onSeek: controller.seek,
                    baseBarColor: Colors.grey.shade300,
                    progressBarColor: Colors.purpleAccent,
                    thumbColor: Colors.purpleAccent,
                    timeLabelLocation: TimeLabelLocation.sides,
                    timeLabelTextStyle: const TextStyle(
                      color: Colors.black,          // ← visível!
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
              ],
            );
          },
        );
      },
    );
  }
}
