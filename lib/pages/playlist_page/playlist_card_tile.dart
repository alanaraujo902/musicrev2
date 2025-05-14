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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
      child: Card(
        child: ListTile(
          onTap: onTap,
          leading: Icon(Icons.library_music),
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
          subtitle: Text('${playlist.songs.length} músicas'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (onMoveToFolder != null)
                IconButton(icon: Icon(Icons.folder_open), onPressed: onMoveToFolder),
              if (onRemoveFromFolder != null)
                IconButton(icon: Icon(Icons.remove_circle_outline), onPressed: onRemoveFromFolder),
            ],
          ),
        ),
      ),
    );
  }
}
