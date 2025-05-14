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

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: MusicController().playlistsNotifier,
      builder: (context, playlists, _) {
        final currentPlaylists = folder.playlists.map((fp) {
          return playlists.firstWhere((p) => p.name == fp.name, orElse: () => fp);
        }).toList();

        final isChecked = currentPlaylists.isNotEmpty && currentPlaylists.every((p) => p.isChecked);

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: ExpansionTile(
            title: Text(isChecked ? '${folder.name} ✔️' : folder.name),
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
