import 'package:flutter/material.dart';
import '../controllers/music/music_controller.dart';
import '../pages/text_note_page.dart';
import '../services/note_service.dart';

class NowPlayingHeader extends StatefulWidget {
  final dynamic currentSong;

  const NowPlayingHeader({super.key, required this.currentSong});

  @override
  State<NowPlayingHeader> createState() => _NowPlayingHeaderState();
}

class _NowPlayingHeaderState extends State<NowPlayingHeader> {
  bool hasNote = false;

  @override
  void initState() {
    super.initState();
    _checkIfNoteExists();
  }

  Future<void> _checkIfNoteExists() async {
    final noteExists = await NoteService().hasNote(widget.currentSong.uri);
    setState(() {
      hasNote = noteExists;
    });
  }

  Future<void> _openNotePage() async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => TextNotePage(songKey: widget.currentSong.uri),
    ));
    await _checkIfNoteExists(); // atualiza ao voltar
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = hasNote ? Colors.deepPurple : Colors.deepPurple.shade100;

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
            onTap: _openNotePage,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: iconColor,
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
            widget.currentSong.title,
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          Text(
            widget.currentSong.artist,
            style: const TextStyle(color: Colors.black54, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),

          /* ---------- check e favorito ---------- */
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
