import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'pages/music_player_page.dart';
import 'pages/playlist_page/playlist_page.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /* ----------- Hive ----------- */
  await Hive.initFlutter();
  // 👍 agora tipada como <String>
  await Hive.openBox<String>('notesBox');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
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
