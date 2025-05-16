import 'package:flutter/material.dart';
import '../../controllers/music/music_controller.dart';
import 'playlist_controller.dart';
import 'playlist_folder_tile.dart';
import 'playlist_card_tile.dart';

extension StreamExt<T> on Stream<T> {
  ValueNotifier<T> asValueNotifier(T initial) {
    final notifier = ValueNotifier<T>(initial);
    listen((value) => notifier.value = value);
    return notifier;
  }
}


class PlaylistPage extends StatefulWidget {
  @override
  State<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  final controller = PlaylistPageController();

  @override
  void initState() {
    super.initState();
    controller.loadData(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Playlists'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.create_new_folder),
            onPressed: () => controller.createFolder(context, () => setState(() {})),
            tooltip: 'Nova Pasta',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: Icon(Icons.playlist_play),
              title: Text('Playlists'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/playlists');
              },
            ),
            ListTile(
              leading: Icon(Icons.library_music),
              title: Text('Músicas'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/');
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.only(bottom: 80), // espaço para o botão
            children: [
              if (controller.loosePlaylists.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text("Sem pasta", style: Theme.of(context).textTheme.titleLarge),
                ),
                ...controller.loosePlaylists.map((p) => PlaylistCardTile(
                  playlist: p,
                  onTap: () => controller.openPlaylist(context, p),
                  onMoveToFolder: () => controller.addToFolder(context, p, () => setState(() {})),
                )),
                const SizedBox(height: 20),
              ],
              ...controller.folders.map((folder) => PlaylistFolderTile(
                folder: folder,
                controller: controller,
                onUpdate: () => setState(() {}),
              )),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 12,
            child: Center(
              child: ValueListenableBuilder<bool>(
                valueListenable: MusicController().audioService.playingStream.asBroadcastStream().map((b) => b).asBroadcastStream().asValueNotifier(false),
                builder: (context, isPlaying, _) {
                  return ElevatedButton.icon(
                    icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                    label: Text(isPlaying ? 'Pausar Música' : 'Tocar Música'),
                    onPressed: () async {
                      await MusicController().togglePlayPause();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
