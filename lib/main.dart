import 'package:flutter/material.dart';
import 'pages/music_player_page.dart';
import 'pages/playlist_page//playlist_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Player',
      initialRoute: '/',
      routes: {
        '/': (context) => MusicPlayerPage(),
        '/playlists': (context) => PlaylistPage(),
      },
    );
  }
}
