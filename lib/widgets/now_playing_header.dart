import 'package:flutter/material.dart';
import '../controllers/music/music_controller.dart';

class NowPlayingHeader extends StatefulWidget {
  final dynamic currentSong;

  const NowPlayingHeader({required this.currentSong});

  @override
  State<NowPlayingHeader> createState() => _NowPlayingHeaderState();
}

class _NowPlayingHeaderState extends State<NowPlayingHeader> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 40, bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Colors.grey.shade100],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
        boxShadow: [
          BoxShadow(
            color: Colors.purpleAccent.withOpacity(0.2),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 220,
                height: 350,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.3),
                      blurRadius: 30,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(0),
                    bottom: Radius.circular(140),
                  ),
                  child: Container(
                    color: Colors.deepPurple,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.music_note, size: 80, color: Colors.white),
                        SizedBox(height: 20),
                        Text(
                          widget.currentSong.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          widget.currentSong.artist,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Checkbox(
                              value: widget.currentSong.isChecked,
                              onChanged: (value) async {
                                await MusicController().toggleChecked(
                                  widget.currentSong,
                                  value ?? false,
                                );
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
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}