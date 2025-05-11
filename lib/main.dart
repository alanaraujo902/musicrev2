import 'package:flutter/material.dart';
import 'pages/music_player_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Player',
      home: MusicPlayerPage(),
    );
  }
}
