import 'package:flutter/material.dart';
import '../controllers/music/music_controller.dart';
import '../pages/text_note_page.dart';

class NowPlayingHeader extends StatefulWidget {
  final dynamic currentSong;

  const NowPlayingHeader({required this.currentSong, super.key});

  @override
  State<NowPlayingHeader> createState() => _NowPlayingHeaderState();
}

class _NowPlayingHeaderState extends State<NowPlayingHeader> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 40, bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Colors.grey.shade100],
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
          /* ------------ ÍCONE DE ARQUIVO-TEXTO (tocável) ------------ */
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TextNotePage()),
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
          /* ---------------- TÍTULO / ARTISTA ---------------- */
          Text(
            widget.currentSong.title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            widget.currentSong.artist,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          /* -------------- CHECK / FAVORITO ---------------- */
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Checkbox(
                value: widget.currentSong.isChecked,
                onChanged: (v) async {
                  await MusicController()
                      .toggleChecked(widget.currentSong, v ?? false);
                  setState(() {});
                },
                checkColor: Colors.white,
                activeColor: Colors.purpleAccent,
              ),
              IconButton(
                icon: Icon(
                  widget.currentSong.isFavorite
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: Colors.redAccent,
                ),
                onPressed: () async {
                  await MusicController().toggleFavorite(widget.currentSong);
                  setState(() {});
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
