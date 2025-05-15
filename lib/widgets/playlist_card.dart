import 'package:flutter/material.dart';
import 'package:untitled1/models/playlist.dart';
import '../dialogs/remove_from_playlist_dialog.dart';
import 'package:untitled1/controllers/music/music_controller.dart';
import 'package:untitled1/services/playlist_service.dart';

class PlaylistCard extends StatelessWidget {
  final Playlist playlist;
  final void Function(Playlist) onAddSongs;
  final void Function(Playlist) onLoad;
  final void Function(Playlist) onRemoveSongs;

  const PlaylistCard({
    super.key,
    required this.playlist,
    required this.onAddSongs,
    required this.onLoad,
    required this.onRemoveSongs,
  });

  String _formatTotalDuration(int millis) {
    if (millis == 0) return '--:--';
    final d = Duration(milliseconds: millis);
    if (d.inHours > 0) {
      return '${d.inHours} h ${d.inMinutes.remainder(60).toString().padLeft(2, '0')} m';
    }
    return '${d.inMinutes.remainder(60).toString().padLeft(2, '0')}:${d.inSeconds.remainder(60).toString().padLeft(2, '0')}';
  }

  Future<int> _getAndPersistDurations() async {
    final service = MusicController().audioService;
    final updatedSongs = playlist.songs;

    int total = 0;
    bool changed = false;

    for (var song in updatedSongs) {
      if (song.durationMillis == null) {
        final dur = await service.fetchDuration(song.uri);
        song.durationMillis = dur?.inMilliseconds ?? 0;
        changed = true;
      }
      total += song.durationMillis!;
    }

    if (changed) {
      final updated = Playlist(
        name: playlist.name,
        songs: updatedSongs,
        isChecked: playlist.isChecked,
      );

      final playlistService = PlaylistService();
      final all = await playlistService.loadPlaylists();
      final idx = all.indexWhere((p) => p.name == playlist.name);
      if (idx != -1) {
        all[idx] = updated;
        await playlistService.savePlaylists(all);
      }
    }

    return total;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              ValueListenableBuilder<List<Playlist>>(
                valueListenable: MusicController().playlistsNotifier,
                builder: (_, playlists, __) {
                  final updated = playlists.firstWhere(
                        (p) => p.name == playlist.name,
                    orElse: () => playlist,
                  );

                  return Column(
                    children: [
                      Text(
                        updated.isChecked ? "${updated.name} ✔️" : updated.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      FutureBuilder<int>(
                        future: _getAndPersistDurations(),
                        builder: (context, snap) {
                          final dur = snap.data ?? 0;
                          return Text(
                            '${playlist.songs.length} músicas • ${_formatTotalDuration(dur)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                            textAlign: TextAlign.center,
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 10),
              Flexible(
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () => onAddSongs(playlist),
                      child: const Text("+ song", textAlign: TextAlign.center),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        showRemoveFromPlaylistDialog(
                          context: context,
                          playlist: playlist,
                          onUpdated: onRemoveSongs,
                        );
                      },
                      child: const Text("- song", textAlign: TextAlign.center),
                    ),
                    ElevatedButton(
                      onPressed: () => onLoad(playlist),
                      child: const Text("Carregar", textAlign: TextAlign.center),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
