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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: widget.controller.currentSongNotifier,
          builder: (context, currentSong, _) {
            if (currentSong == null) {
              return const Center(child: Text("Nenhuma música"));
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
                /* ------- Botões padrão (play/pause/next/prev) ------- */
                NowPlayingControls(controller: widget.controller),

                /* ===== NOVO: seletor de modo de reprodução ===== */
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: ValueListenableBuilder<bool>(
                    valueListenable:
                    widget.controller.continuePlayingNotifier,
                    builder: (context, cont, _) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Continuar reprodução"),
                          const SizedBox(width: 12),
                          Switch(
                            value: cont,
                            onChanged: (v) =>
                            widget.controller.continuePlaying = v,
                          ),
                        ],
                      );
                    },
                  ),
                ),

                /* -------------- Fila de próximas músicas ------------- */
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
