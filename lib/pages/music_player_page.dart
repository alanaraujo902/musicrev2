import 'dart:io';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../controllers/music_controller.dart';
import '../models/local_song.dart';
import 'now_playing_page.dart';


class MusicPlayerPage extends StatefulWidget {
  @override
  _MusicPlayerPageState createState() => _MusicPlayerPageState();
}

class _MusicPlayerPageState extends State<MusicPlayerPage> {
  final controller = MusicController();
  bool hasSongs = false;

  Future<void> _selectDirectory() async {
    final rootPath = Directory('/storage/emulated/0');

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
      setState(() {
        hasSongs = controller.songs.isNotEmpty;
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Músicas Locais'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              icon: Icon(Icons.folder_open),
              label: Text('Selecionar Músicas'),
              onPressed: _selectDirectory,
            ),
            SizedBox(height: 20),
            if (hasSongs)
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
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
                                  builder: (_) => NowPlayingPage(song: song, controller: controller),
                                ),
                              );
                              controller.playSong(song);
                            },
                          );
                        },
                      ),
                    ),
                    StreamBuilder<bool>(
                      stream: controller.playingStream,
                      builder: (context, snapshot) {
                        final isPlaying = snapshot.data ?? false;
                        return ElevatedButton.icon(
                          icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                          label: Text(isPlaying ? "Pausar" : "Tocar"),
                          onPressed: controller.togglePlayPause,
                        );
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

