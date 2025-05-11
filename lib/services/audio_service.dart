import 'dart:io';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../models/local_song.dart';

class AudioService {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<List<dynamic>> loadSongs({String? directoryPath}) async {
    if (directoryPath != null) {
      final directory = Directory(directoryPath);
      final files = directory
          .listSync(recursive: true)
          .where((file) => file.path.endsWith('.mp3'))
          .toList();

      List<LocalSong> songs = [];
      for (var file in files) {
        final song = LocalSong(
          id: file.hashCode,
          title: file.uri.pathSegments.last,
          artist: 'Desconhecido',
          uri: file.uri.toString(),
        );
        songs.add(song);
      }
      return songs;
    } else {
      return await _audioQuery.querySongs();
    }
  }

  Future<void> playFromUri(String uri) async {
    try {
      await _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(uri)));
      await _audioPlayer.play();
    } catch (e) {
      print("Erro ao tocar música: $e");
    }
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