import 'package:flutter/material.dart';
import 'package:untitled1/models/playlist_folder.dart';
import 'package:untitled1/controllers/music/music_controller.dart';

import 'playlist_card_tile.dart';
import 'playlist_controller.dart';

class PlaylistFolderTile extends StatelessWidget {
  final PlaylistFolder folder;
  final PlaylistPageController controller;
  final VoidCallback onUpdate;

  const PlaylistFolderTile({
    super.key,
    required this.folder,
    required this.controller,
    required this.onUpdate,
  });

  String _fmtTotal(int millis) {
    if (millis == 0) return '--:--';
    final d = Duration(milliseconds: millis);
    if (d.inHours > 0) {
      return '${d.inHours} h ${d.inMinutes.remainder(60).toString().padLeft(2, '0')} m';
    }
    return '${d.inMinutes.remainder(60).toString().padLeft(2, '0')}:${d.inSeconds.remainder(60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: MusicController().playlistsNotifier,
      builder: (context, playlists, _) {
        final currentPlaylists = folder.playlists.map((fp) {
          return playlists.firstWhere((p) => p.name == fp.name, orElse: () => fp);
        }).toList();

        final isChecked = currentPlaylists.isNotEmpty && currentPlaylists.every((p) => p.isChecked);

        final totalMs = currentPlaylists.expand((p) => p.songs).fold<int>(
          0, (sum, s) => sum + (s.durationMillis ?? 0),
        );

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: ExpansionTile(
            title: Text(
              '${folder.name} ${isChecked ? "✔️" : ""} • ${_fmtTotal(totalMs)}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            children: [
              ReorderableListView(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                onReorder: (oldIdx, newIdx) async {
                  if (newIdx > oldIdx) newIdx -= 1;
                  final item = folder.playlists.removeAt(oldIdx);
                  folder.playlists.insert(newIdx, item);
                  await controller.saveFolders();
                  onUpdate();
                },
                children: currentPlaylists.map((p) => Container(
                  key: ValueKey(p.name),
                  child: PlaylistCardTile(
                    playlist: p,
                    folder: folder,
                    onTap: () => controller.openPlaylist(context, p),
                    onRemoveFromFolder: () async {
                      folder.playlists.removeWhere((x) => x.name == p.name);
                      controller.loosePlaylists.add(p);
                      await controller.saveFolders();
                      onUpdate();
                    },
                  ),
                )).toList(),
              )
            ],
          ),
        );
      },
    );
  }
}