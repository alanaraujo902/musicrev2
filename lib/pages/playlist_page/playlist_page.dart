import 'package:flutter/material.dart';
import 'playlist_controller.dart';
import 'playlist_folder_tile.dart';
import 'playlist_card_tile.dart';


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
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.create_new_folder),
            onPressed: () => controller.createFolder(context, () => setState(() {})),
            tooltip: 'Nova Pasta',
          ),
        ],
      ),
      body: ListView(
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
    );
  }
}
