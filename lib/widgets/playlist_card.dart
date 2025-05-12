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
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 6),
      child: Container(
        height: 220, // Ajustado de 220 para 240 para resolver o overflow de 16 pixels
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(playlist.name, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => onAddSongs(playlist),
              child: Text("Adicionar músicas"),
            ),
            ElevatedButton(
              onPressed: () => onRemoveSongs(playlist),
              child: Text("Remover músicas"),
            ),
            ElevatedButton(
              onPressed: () => onLoad(playlist),
              child: Text("Carregar"),
            ),
          ],
        ),
      ),
    );
  }
}
