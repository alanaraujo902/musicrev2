import 'package:flutter/material.dart';
import '../../models/local_song.dart';
import 'package:untitled1/models/playlist.dart';

void showSavePlaylistDialog({
  required BuildContext context,
  required List<dynamic> songs,
  required void Function(Playlist) onSaved,
}) {
  final nameController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Nome da Playlist"),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(hintText: "Digite o nome"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                final playlist = Playlist(
                  name: name,
                  songs: List<LocalSong>.from(songs),
                );
                onSaved(playlist);
                Navigator.pop(context);
              }
            },
            child: Text("Salvar"),
          ),
        ],
      );
    },
  );
}
