import 'package:flutter/material.dart';
import '../models/playlist.dart';
import '../models/playlist_folder.dart';
import '../services/playlist_service.dart';
import '../services/playlist_folder_service.dart';
import 'playlist_songs_page.dart';
//import '../controllers/music_controller.dart';
import '../controllers/music/music_controller.dart';


class PlaylistPage extends StatefulWidget {
  @override
  _PlaylistPageState createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  final _playlistService = PlaylistService();
  final _folderService = PlaylistFolderService();

  List<Playlist> loosePlaylists = [];
  List<PlaylistFolder> folders = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final allPlaylists = await _playlistService.loadPlaylists();
    final savedFolders = await _folderService.loadFolders();

    final folderedPlaylists = savedFolders.expand((f) => f.playlists).map((p) => p.name).toSet();
    final ungrouped = allPlaylists.where((p) => !folderedPlaylists.contains(p.name)).toList();

    setState(() {
      loosePlaylists = ungrouped;
      folders = savedFolders;
    });
  }

  void _createFolder() async {
    final nameController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Nova Pasta"),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(hintText: "Nome da pasta"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancelar")),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isNotEmpty) Navigator.pop(context, name);
            },
            child: Text("Criar"),
          )
        ],
      ),
    );

    if (result != null) {
      setState(() {
        folders.add(PlaylistFolder(name: result, playlists: []));
      });
      await _folderService.saveFolders(folders);
    }
  }

  void _renameFolder(PlaylistFolder folder) async {
    final nameController = TextEditingController(text: folder.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Renomear pasta"),
        content: TextField(controller: nameController),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancelar")),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isNotEmpty) Navigator.pop(context, name);
            },
            child: Text("Salvar"),
          )
        ],
      ),
    );
    if (newName != null && newName != folder.name) {
      setState(() => folder.name = newName);
      await _folderService.saveFolders(folders);
    }
  }

  void _deleteFolder(PlaylistFolder folder) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Excluir pasta"),
        content: Text("Deseja excluir a pasta '${folder.name}'?\nAs playlists não serão apagadas."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text("Cancelar")),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: Text("Confirmar")),
        ],
      ),
    );
    if (confirm == true) {
      setState(() {
        loosePlaylists.addAll(folder.playlists);
        folders.remove(folder);
      });
      await _folderService.saveFolders(folders);
    }
  }

  void _addToFolder(Playlist playlist) async {
    final selected = await showDialog<PlaylistFolder>(
      context: context,
      builder: (_) => SimpleDialog(
        title: Text("Mover '${playlist.name}' para pasta"),
        children: folders.map((folder) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(context, folder),
            child: Text(folder.name),
          );
        }).toList(),
      ),
    );

    if (selected != null) {
      setState(() {
        for (final folder in folders) {
          folder.playlists.removeWhere((p) => p.name == playlist.name);
        }
        loosePlaylists.removeWhere((p) => p.name == playlist.name);
        selected.playlists.add(playlist);
      });
      await _folderService.saveFolders(folders);
    }
  }

  void _openPlaylist(Playlist playlist) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlaylistSongsPage(
          playlist: playlist,
          onOrderSaved: (updated) {
            final controller = MusicController();
            if (controller.currentSong != null &&
                updated.songs.any((s) => s.uri == controller.currentSong.uri)) {
              controller.loadPlaylist(updated);
            }
            _loadData();
          },
        ),
      ),
    );
  }

  void _sortFolderPlaylists(PlaylistFolder folder, String criteria) {
    setState(() {
      if (criteria == 'A-Z') {
        folder.playlists.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      } else if (criteria == 'Z-A') {
        folder.playlists.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
      } else if (criteria == 'Músicas') {
        folder.playlists.sort((a, b) => b.songs.length.compareTo(a.songs.length));
      }
    });
    _folderService.saveFolders(folders);
  }

  void _saveFolderOrder(PlaylistFolder folder) async {
    await _folderService.saveFolders(folders);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ordem salva para pasta "${folder.name}"')),
    );
  }

  Widget _buildPlaylistCard(Playlist playlist, {bool canMoveToFolder = false, PlaylistFolder? folder}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6),
      child: Card(
        elevation: 2,
        child: InkWell(
          onTap: () => _openPlaylist(playlist),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Icon(Icons.library_music, size: 32, color: Colors.teal),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        playlist.isChecked ? '${playlist.name} ✔️' : playlist.name,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),

                      Text('${playlist.songs.length} músicas', style: TextStyle(fontSize: 13, color: Colors.grey)),
                    ],
                  ),
                ),
                if (canMoveToFolder)
                  IconButton(
                    icon: Icon(Icons.folder_open),
                    tooltip: 'Mover para pasta',
                    onPressed: () => _addToFolder(playlist),
                  ),
                if (folder != null)
                  IconButton(
                    icon: Icon(Icons.remove_circle_outline, color: Colors.orange),
                    tooltip: 'Remover da pasta',
                    onPressed: () async {
                      setState(() {
                        folder.playlists.removeWhere((p) => p.name == playlist.name);
                        loosePlaylists.add(playlist);
                      });
                      await _folderService.saveFolders(folders);
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFolderTile(PlaylistFolder folder) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 20),
      child: ExpansionTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                folder.isChecked ? '${folder.name} ✔️' : folder.name,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _renameFolder(folder),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteFolder(folder),
            ),
            PopupMenuButton<String>(
              icon: Icon(Icons.sort),
              onSelected: (value) => _sortFolderPlaylists(folder, value),
              itemBuilder: (context) => [
                PopupMenuItem(value: 'A-Z', child: Text('Nome (A-Z)')),
                PopupMenuItem(value: 'Z-A', child: Text('Nome (Z-A)')),
                PopupMenuItem(value: 'Músicas', child: Text('Quantidade de músicas')),
              ],
            ),
            IconButton(
              icon: Icon(Icons.save, color: Colors.green),
              onPressed: () => _saveFolderOrder(folder),
              tooltip: 'Salvar ordem',
            ),
          ],
        ),
        childrenPadding: const EdgeInsets.symmetric(vertical: 4),
        children: [
          ReorderableListView(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) newIndex -= 1;
                final item = folder.playlists.removeAt(oldIndex);
                folder.playlists.insert(newIndex, item);
              });
            },
            children: [
              for (final playlist in folder.playlists)
                Container(
                  key: ValueKey(playlist.name),
                  child: _buildPlaylistCard(playlist, folder: folder),
                ),
            ],
          ),
        ],
      ),
    );
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
            onPressed: _createFolder,
            tooltip: 'Nova Pasta',
          ),
        ],
      ),
      body: ListView(
        children: [
          if (loosePlaylists.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text("Sem pasta", style: Theme.of(context).textTheme.titleLarge),
            ),
            ...loosePlaylists.map((p) => _buildPlaylistCard(p, canMoveToFolder: true)),
            const SizedBox(height: 20),
          ],
          ...folders.map(_buildFolderTile),
        ],
      ),
    );
  }
}
