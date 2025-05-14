import 'package:flutter/material.dart';
//import '../../models/playlist.dart';
import 'package:untitled1/models/playlist.dart';

import '../../models/local_song.dart';

void showAddToPlaylistDialog({
  required BuildContext context,
  required List<dynamic> availableSongs,
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
            title: Text("Adicionar músicas a ${playlist.name}"),
            content: Container(
              width: double.maxFinite,
              height: 400,
              child: ListView.builder(
                itemCount: availableSongs.length,
                itemBuilder: (context, index) {
                  final song = availableSongs[index];
                  final alreadyIn = playlist.songs.any((s) => s.uri == song.uri);

                  return CheckboxListTile(
                    value: selectedSongs.contains(song),
                    title: Text(song.title),
                    subtitle: Text(song.artist),
                    onChanged: alreadyIn
                        ? null
                        : (checked) {
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
                  final updated = Playlist(
                    name: playlist.name,
                    songs: [...playlist.songs, ...selectedSongs],
                  );
                  onUpdated(updated);
                  Navigator.pop(context);
                },
                child: Text("Adicionar"),
              ),
            ],
          );
        },
      );
    },
  );
}
