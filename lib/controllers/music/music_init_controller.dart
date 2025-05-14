import 'package:permission_handler/permission_handler.dart';
import '../../services/audio_service.dart';
import 'music_base.dart'; // ✅ Adicione esta linha

mixin MusicInitController on MusicControllerBase {
  final _audioService = AudioService();

  Future<bool> _requestPermissions() async {
    return await Permission.storage.request().isGranted ||
        await Permission.audio.request().isGranted;
  }

  Future<bool> requestPermission() async => await _requestPermissions();

  Future<List<dynamic>> initSongs() async {
    final granted = await _requestPermissions();
    if (granted) {
      return await _audioService.loadSongs();
    }
    return [];
  }

  Future<void> loadSongsFromDirectory(String path) async {
    songs = await _audioService.loadSongs(directoryPath: path);
    currentSongNotifier.value = null;
    currentSongIndex = -1;
    currentSong = null;
  }

  void dispose() {
    _audioService.dispose();
  }
}
