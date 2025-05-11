import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/audio_service.dart';

class MusicController {
  final _audioService = AudioService();
  List<SongModel> songs = [];

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

  Future<void> playSong(SongModel song) async {
    await _audioService.playSong(song);
  }

  Future<void> togglePlayPause() async {
    await _audioService.togglePlayPause();
  }

  Stream<bool> get playingStream => _audioService.playingStream;

  void dispose() {
    _audioService.dispose();
  }
}
