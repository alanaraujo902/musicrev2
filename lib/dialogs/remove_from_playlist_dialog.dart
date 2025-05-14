import 'package:flutter/material.dart';
import 'package:untitled1/models/playlist.dart';
import '../../models/local_song.dart';

void showRemoveFromPlaylistDialog({
  required BuildContext context,
  required Playlist playlist,
  required void Function(Playlist) onUpdated,
}) {
  final selectedSongs = <LocalSong>{};

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text("Remover músicas de ${playlist.name}"),
            content: Container(
              width: double.maxFinite,
              height: 400,
              child: ListView.builder(
                itemCount: playlist.songs.length,
                itemBuilder: (context, index) {
                  final song = playlist.songs[index];
                  return CheckboxListTile(
                    value: selectedSongs.contains(song),
                    title: Text(song.title),
                    subtitle: Text(song.artist),
                    onChanged: (checked) {
                      setStateDialog(() {
                        if (checked == true) {
                          selectedSongs.add(song);
                        } else {
                          selectedSongs.remove(song);
                        }
                      });
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancelar"),
              ),
              ElevatedButton(
                onPressed: () {
                  final updatedSongs = playlist.songs
                      .where((s) => !selectedSongs.contains(s))
                      .toList();

                  final updatedPlaylist = Playlist(
                    name: playlist.name,
                    songs: updatedSongs,
                  );

                  onUpdated(updatedPlaylist);
                  Navigator.pop(context);
                },
                child: Text("Remover"),
              ),
            ],
          );
        },
      );
    },
  );
}
