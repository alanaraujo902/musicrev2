import 'package:flutter/material.dart';
import 'pages/music_player_page.dart';
import 'pages/playlist_page/playlist_page.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // 👈 adicionado aqui
      title: 'Music Player',
      debugShowCheckedModeBanner: false,
      initialRoute: '/playlists',
      routes: {
        '/': (context) => MusicPlayerPage(),
        '/playlists': (context) => PlaylistPage(),
      },
    );
  }
}
