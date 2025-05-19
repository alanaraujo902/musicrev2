import 'package:flutter/material.dart';
import '../controllers/music/music_controller.dart';
import '../pages/text_note_page.dart';

class NowPlayingHeader extends StatelessWidget {
  final dynamic currentSong;

  const NowPlayingHeader({required this.currentSong, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 40, bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey.shade100],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
        boxShadow: [
          BoxShadow(
            color: Colors.purpleAccent.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          /* ------------ ícone do bloco de notas ------------ */
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => TextNotePage(songKey: currentSong.uri),
                ),
              );
            },
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.description,
                  size: 60, color: Colors.white),
            ),
          ),
          const SizedBox(height: 20),
          /* ---------------- título / artista --------------- */
          Text(
            currentSong.title,
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          Text(
            currentSong.artist,
            style: const TextStyle(color: Colors.black54, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          /* ---------- check e favorito ---------- */
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Checkbox(
                value: currentSong.isChecked,
                onChanged: (v) =>
                    MusicController().toggleChecked(currentSong, v ?? false),
              ),
              IconButton(
                icon: Icon(
                  currentSong.isFavorite
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: Colors.redAccent,
                ),
                onPressed: () =>
                    MusicController().toggleFavorite(currentSong),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
