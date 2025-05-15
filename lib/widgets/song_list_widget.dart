import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../models/local_song.dart';
import '../controllers/music/music_controller.dart';
import '../pages/now_playing_page.dart';

/// Lista de músicas com suporte a reordenação, exibição do tempo de duração
/// (mm:ss) ao lado do título e indicações de favorito / ouvido.
class SongListWidget extends StatefulWidget {
  final List<dynamic> songs;
  final MusicController controller;

  const SongListWidget({
    Key? key,
    required this.songs,
    required this.controller,
  }) : super(key: key);

  @override
  State<SongListWidget> createState() => _SongListWidgetState();
}

class _SongListWidgetState extends State<SongListWidget> {
  /// Formata [Duration] em "MM:SS".
  String _fmt(Duration d) =>
      "${d.inMinutes.remainder(60).toString().padLeft(2, '0')}:" // MM
          "${d.inSeconds.remainder(60).toString().padLeft(2, '0')}";     // SS

  /// Retorna um [Future] que resolve para a duração da música.
  Future<Duration?> _durationOf(dynamic song) async {
    if (song is LocalSong) {
      // Já temos em cache
      if (song.durationMillis != null) {
        return Duration(milliseconds: song.durationMillis!);
      }
      // Consulta serviço e persiste para uso futuro
      final d = await widget.controller.audioService.fetchDuration(song.uri);
      song.durationMillis = d?.inMilliseconds;
      return d;
    } else if (song is SongModel) {
      final ms = (song.duration ?? 0) as int;
      return Duration(milliseconds: ms);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ValueListenableBuilder(
            valueListenable: widget.controller.currentSongNotifier,
            builder: (context, value, _) {
              return ReorderableListView.builder(
                itemCount: widget.songs.length,
                onReorder: (oldIndex, newIndex) async {
                  setState(() {
                    if (newIndex > oldIndex) newIndex -= 1;
                    final item = widget.songs.removeAt(oldIndex);
                    widget.songs.insert(newIndex, item);
                    widget.controller.updateCurrentIndex();
                  });
                  await widget.controller.persistOrderIfPlaylist();
                },
                itemBuilder: (context, index) {
                  final song = widget.songs[index];
                  final title = song.title;
                  final artist = song.artist ?? 'Artista desconhecido';
                  final isPlaying = widget.controller.currentSong?.uri == song.uri;

                  return Container(
                    key: ValueKey(song.uri),
                    color: isPlaying ? Colors.orange.withOpacity(0.3) : null,
                    child: ListTile(
                      onTap: () async {
                        final isCurrent = widget.controller.currentSong?.uri == song.uri;
                        if (!isCurrent) {
                          await widget.controller.playSong(song);
                        }
                        if (mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => NowPlayingPage(
                                song: song,
                                controller: widget.controller,
                              ),
                            ),
                          ).then((_) => setState(() {}));
                        }
                      },
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: song.isChecked,
                            onChanged: (value) async {
                              await widget.controller.toggleChecked(song, value ?? false);
                              await widget.controller.evaluatePlaylistCheckedStatus(
                                onStatusChanged: () => setState(() {}),
                              );
                              setState(() {});
                            },
                          ),
                          if (song.isFavorite)
                            const Icon(Icons.favorite, color: Colors.red, size: 18),
                        ],
                      ),
                      trailing: isPlaying
                          ? const Icon(Icons.play_arrow)
                          : (song is SongModel
                          ? QueryArtworkWidget(
                        id: song.id,
                        type: ArtworkType.AUDIO,
                        nullArtworkWidget: const Icon(Icons.music_note),
                      )
                          : const Icon(Icons.music_note)),
                      // ----- TÍTULO + DURAÇÃO ----- //
                      title: Row(
                        children: [
                          Expanded(
                            child: isPlaying
                                ? SizedBox(
                              height: 20,
                              child: Marquee(
                                text: title,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                blankSpace: 60,
                                velocity: 30,
                                pauseAfterRound: const Duration(seconds: 1),
                                startPadding: 10,
                              ),
                            )
                                : Text(title),
                          ),
                          const SizedBox(width: 8),
                          FutureBuilder<Duration?>(
                            future: _durationOf(song),
                            builder: (context, snap) {
                              return Text(
                                snap.hasData ? _fmt(snap.data!) : '--:--',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      subtitle: Text(artist),
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
            final currentSong = widget.controller.currentSong;
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                  label: Text(isPlaying ? 'Pausar' : 'Tocar'),
                  onPressed: () async {
                    await widget.controller.togglePlayPause();
                    setState(() {});
                  },
                ),
                const SizedBox(width: 12),
                if (currentSong != null)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.fullscreen),
                    label: const Text('Modo Tela Cheia'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => NowPlayingPage(
                            song: currentSong,
                            controller: widget.controller,
                          ),
                        ),
                      ).then((_) => setState(() {}));
                    },
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
