import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../models/local_song.dart';
import '../controllers/music/music_controller.dart';
import '../pages/now_playing_page.dart';

class SongListWidget extends StatefulWidget {
  final List<dynamic> songs;
  final MusicController controller;
  final void Function(List<LocalSong> songs)? onConfirmRemove;
  final bool showRemoveIcon;

  const SongListWidget({
    Key? key,
    required this.songs,
    required this.controller,
    this.onConfirmRemove,
    this.showRemoveIcon = false,
  }) : super(key: key);

  @override
  State<SongListWidget> createState() => _SongListWidgetState();
}

class _SongListWidgetState extends State<SongListWidget> {
  final Set<LocalSong> songsToRemove = {};

  String _fmt(Duration d) =>
      "${d.inMinutes.remainder(60).toString().padLeft(2, '0')}:${d.inSeconds.remainder(60).toString().padLeft(2, '0')}";

  Future<Duration?> _durationOf(dynamic song) async {
    if (song is LocalSong) {
      if (song.durationMillis != null) {
        return Duration(milliseconds: song.durationMillis!);
      }
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
                  final marked = widget.showRemoveIcon && songsToRemove.contains(song);

                  return Container(
                    key: ValueKey(song.uri),
                    color: isPlaying ? Colors.orange.withOpacity(0.3) : null,
                    child: ListTile(
                      onTap: () async {
                        if (widget.showRemoveIcon) return;

                        await widget.controller.playSong(song);

                        // Aguarda até que currentSongNotifier seja igual à música tocada
                        while (widget.controller.currentSongNotifier.value?.uri != song.uri) {
                          await Future.delayed(Duration(milliseconds: 50));
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
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.showRemoveIcon && song is LocalSong)
                            IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: songsToRemove.contains(song) ? Colors.red : Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  if (songsToRemove.contains(song)) {
                                    songsToRemove.remove(song);
                                  } else {
                                    songsToRemove.add(song);
                                  }
                                });
                              },
                            ),
                          if (!widget.showRemoveIcon)
                            (song is SongModel
                                ? QueryArtworkWidget(
                              id: song.id,
                              type: ArtworkType.AUDIO,
                              nullArtworkWidget: const Icon(Icons.music_note),
                            )
                                : const Icon(Icons.music_note)),
                        ],
                      ),
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              FutureBuilder<Duration?>(
                                future: _durationOf(song),
                                builder: (context, snap) {
                                  return Text(
                                    snap.hasData ? '${_fmt(snap.data!)}' : '--:--',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  );
                                },
                              ),
                              if (widget.controller.currentSong?.uri == song.uri)
                                StreamBuilder<Duration>(
                                  stream: widget.controller.positionStream,
                                  builder: (context, snap) {
                                    final pos = snap.data ?? Duration.zero;
                                    return Text(
                                      '${_fmt(pos)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  },
                                ),
                            ],
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
        if (widget.showRemoveIcon && songsToRemove.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ElevatedButton.icon(
              icon: Icon(Icons.delete_forever),
              label: Text("Confirmar Exclusão (${songsToRemove.length})"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                widget.onConfirmRemove?.call(songsToRemove.toList());
                setState(() => songsToRemove.clear());
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
