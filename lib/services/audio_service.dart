import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

class AudioService {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<List<SongModel>> loadSongs() async {
    return await _audioQuery.querySongs();
  }

  Future<void> playSong(SongModel song) async {
    await _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(song.uri!)));
    await _audioPlayer.play();
  }

  Future<void> togglePlayPause() async {
    if (_audioPlayer.playing) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
  }

  Stream<bool> get playingStream => _audioPlayer.playingStream;

  void dispose() {
    _audioPlayer.dispose();
  }
}
