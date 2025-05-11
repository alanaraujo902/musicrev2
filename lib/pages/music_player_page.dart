import 'dart:io';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../controllers/music_controller.dart';
import '../models/local_song.dart';
import 'music_playing_page.dart';


class MusicPlayerPage extends StatefulWidget {
  @override
  _MusicPlayerPageState createState() => _MusicPlayerPageState();
}

class _MusicPlayerPageState extends State<MusicPlayerPage> {
  final controller = MusicController();

  @override
  void initState() {
    super.initState();
    controller.init().then((_) => setState(() {}));
  }

  Future<void> _selectDirectory() async {
    final rootPath = Directory('/storage/emulated/0'); // padrão no Android

    String? path = await FilesystemPicker.open(
      title: 'Selecione uma pasta',
      context: context,
      rootDirectory: rootPath,
      fsType: FilesystemType.folder,
      folderIconColor: Colors.teal,
      pickText: 'Selecionar esta pasta',
      requestPermission: () async {
        return await controller.requestPermission();
      },
    );

    if (path != null) {
      await controller.loadSongsFromDirectory(path);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Músicas Locais'),
        actions: [
          IconButton(
            icon: Icon(Icons.folder_open),
            onPressed: _selectDirectory,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: controller.songs.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: controller.songs.length,
              itemBuilder: (context, index) {
                final song = controller.songs[index];
                final title = song.title;
                final artist = song.artist ?? "Artista desconhecido";

                return ListTile(
                  leading: song is SongModel
                      ? QueryArtworkWidget(
                    id: song.id,
                    type: ArtworkType.AUDIO,
                    nullArtworkWidget: Icon(Icons.music_note),
                  )
                      : Icon(Icons.music_note),
                  title: Text(title),
                  subtitle: Text(artist),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MusicPlayingPage(song: song, controller: controller),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          StreamBuilder<bool>(
            stream: controller.playingStream,
            builder: (context, snapshot) {
              final isPlaying = snapshot.data ?? false;
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                  label: Text(isPlaying ? "Pausar" : "Tocar"),
                  onPressed: controller.togglePlayPause,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}