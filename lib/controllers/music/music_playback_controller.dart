library music_playback_controller;
import '../../models/local_song.dart';
import '../../services/audio_service.dart';
import 'music_base.dart';
import '../music/music_controller.dart'; // para acesso direto se precisar

mixin MusicPlaybackController on MusicControllerBase {
  /* ---------------------- DEPENDÊNCIA ---------------------- */
  final AudioService _audioService = AudioService();
  AudioService get audioService => _audioService;

  /* ----------------------- CONTROLES ----------------------- */
  Future<void> playSong(dynamic song) async {
    if (currentSong?.uri == song.uri) return;

    // 1️⃣ Atualiza estado e notifica imediatamente
    currentSong = song;
    currentSongIndex = songs.indexWhere((s) => s.uri == song.uri);
    currentSongNotifier.value = song;

    // ✅ Define a música antes de tocar (corrige bug do primeiro clique)
    if (song is LocalSong) {
      audioService.lastPlayed = song;
    }

    // 2️⃣ Agora sim, toca a música
    await _audioService.playFromUri(song.uri, song: song);
  }

  Future<void> togglePlayPause() => _audioService.togglePlayPause();
  Future<void> seek(Duration pos) => _audioService.seek(pos);

  Future<void> playNext() async {
    if (currentSongIndex < songs.length - 1) {
      await playSong(songs[currentSongIndex + 1]);
    }
  }

  Future<void> playPrevious() async {
    if (currentSongIndex > 0) {
      await playSong(songs[currentSongIndex - 1]);
    }
  }

  /* ------------------------ STREAMS ------------------------ */
  Stream<bool> get playingStream => _audioService.playingStream;
  Stream<Duration> get positionStream => _audioService.positionStream;
  Stream<Duration?> get durationStream => _audioService.durationStream;
}
