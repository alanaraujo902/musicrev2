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
                Icon(Icons.queue_music, color: Colors.white),
                SizedBox(width: 10),
                Text("Próximas Músicas", style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: remaining.length,
              itemBuilder: (context, index) {
                final song = remaining[index];
                return ListTile(
                  title: Text(song.title, style: TextStyle(color: Colors.white)),
                  subtitle: Text(song.artist, style: TextStyle(color: Colors.grey)),
                  trailing: Icon(Icons.more_vert, color: Colors.white),
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
