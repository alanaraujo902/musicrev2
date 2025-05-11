import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/audio_service.dart';
import '../models/local_song.dart';

class MusicController {
  final _audioService = AudioService();
  List<dynamic> songs = [];

  Future<void> init() async {
    final granted = await _requestPermissions();
    if (granted) {
      songs = await _audioService.loadSongs();
    }
  }

  Future<bool> _requestPermissions() async {
    return await Permission.storage.request().isGranted ||
        await Permission.audio.request().isGranted;
  }

  Future<bool> requestPermission() async {
    return await _requestPermissions();
  }

  Future<void> playSong(dynamic song) async {
    final uri = song is SongModel ? song.uri! : song.uri;
    await _audioService.playFromUri(uri);
  }

  Future<void> togglePlayPause() async {
    await _audioService.togglePlayPause();
  }

  Stream<bool> get playingStream => _audioService.playingStream;

  Future<void> loadSongsFromDirectory(String directoryPath) async {
    songs = await _audioService.loadSongs(directoryPath: directoryPath);
  }

  void dispose() {
    _audioService.dispose();
  }
}