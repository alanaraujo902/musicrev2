import 'package:flutter/material.dart';
import '../../models/playlist.dart';
import '../dialogs/remove_from_playlist_dialog.dart';

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
              Text(
                playlist.isChecked ? "${playlist.name} ✔️" : playlist.name,
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Flexible(
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () => onAddSongs(playlist),
                      child: Text("+ song", textAlign: TextAlign.center),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        showRemoveFromPlaylistDialog(
                          context: context,
                          playlist: playlist,
                          onUpdated: onRemoveSongs,
                        );
                      },
                      child: Text("- song", textAlign: TextAlign.center),
                    ),
                    ElevatedButton(
                      onPressed: () => onLoad(playlist),
                      child: Text("Carregar", textAlign: TextAlign.center),
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

