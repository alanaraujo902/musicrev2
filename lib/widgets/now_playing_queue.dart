import 'package:flutter/material.dart';
import '../controllers/music/music_controller.dart';

class NowPlayingQueue extends StatelessWidget {
  final List<dynamic> remaining;
  final MusicController controller;
  final VoidCallback onSongTap;

  const NowPlayingQueue({
    required this.remaining,
    required this.controller,
    required this.onSongTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.queue_music, color: Colors.black),
                SizedBox(width: 10),
                Text("Próximas Músicas", style: TextStyle(color: Colors.black)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: remaining.length,
              itemBuilder: (context, index) {
                final song = remaining[index];
                return ListTile(
                  title: Text(song.title, style: TextStyle(color: Colors.black)),
                  subtitle: Text(song.artist, style: TextStyle(color: Colors.grey.shade600)),
                  trailing: Icon(Icons.more_vert, color: Colors.black),
                  onTap: () async {
                    await controller.playSong(song);
                    onSongTap();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
