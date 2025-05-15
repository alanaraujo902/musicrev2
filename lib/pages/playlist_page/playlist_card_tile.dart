import 'package:flutter/material.dart';
import 'package:untitled1/models/playlist.dart';
import 'package:untitled1/models/playlist_folder.dart';
import 'package:untitled1/controllers/music/music_controller.dart';

class PlaylistCardTile extends StatelessWidget {
  final Playlist playlist;
  final PlaylistFolder? folder;
  final void Function() onTap;
  final void Function()? onMoveToFolder;
  final void Function()? onRemoveFromFolder;

  const PlaylistCardTile({
    super.key,
    required this.playlist,
    required this.onTap,
    this.onMoveToFolder,
    this.onRemoveFromFolder,
    this.folder,
  });

  // 👉 formata 75 min → "1 h 15 m" | 4 min → "04:00"
  String _fmtTotal(int millis) {
    if (millis == 0) return '--:--';
    final d = Duration(milliseconds: millis);
    if (d.inHours > 0) {
      return '${d.inHours} h ${d.inMinutes.remainder(60).toString().padLeft(2, '0')} m';
    }
    return '${d.inMinutes.remainder(60).toString().padLeft(2, '0')}:'
        '${d.inSeconds.remainder(60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    // soma das durações (se faltar alguma fica 0)
    final totalMs = playlist.songs.fold<int>(
        0, (sum, s) => sum + (s.durationMillis ?? 0));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
      child: Card(
        child: ListTile(
          onTap: onTap,
          leading: const Icon(Icons.library_music),
          title: ValueListenableBuilder<List<Playlist>>(
            valueListenable: MusicController().playlistsNotifier,
            builder: (_, playlists, __) {
              final updated = playlists.firstWhere(
                    (p) => p.name == playlist.name,
                orElse: () => playlist,
              );
              return Text(updated.isChecked ? '${updated.name} ✔️' : updated.name);
            },
          ),
          // 🚀 agora mostra qtd + duração total
          subtitle: Text(
            '${playlist.songs.length} músicas • ${_fmtTotal(totalMs)}',
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (onMoveToFolder != null)
                IconButton(icon: const Icon(Icons.folder_open), onPressed: onMoveToFolder),
              if (onRemoveFromFolder != null)
                IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: onRemoveFromFolder),
            ],
          ),
        ),
      ),
    );
  }
}
