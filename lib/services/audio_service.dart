import 'dart:io';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../models/local_song.dart';

class AudioService {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final AudioPlayer _audioPlayer = AudioPlayer();
  LocalSong? _lastPlayedLocalSong;
  final Map<String, Duration?> _durationCache = {};           // ⬅️ CACHE


  void Function()? onSongComplete;


  AudioService() {
    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        if (_lastPlayedLocalSong != null) {
          _lastPlayedLocalSong!.isChecked = true;
        }
        if (onSongComplete != null) {
          onSongComplete!();
        }
      }
    });
  }

  /// Recupera (e armazena em cache) a duração de um arquivo local.
  Future<Duration?> fetchDuration(String uri) async {
    if (_durationCache.containsKey(uri)) return _durationCache[uri];

    final player = AudioPlayer();
    try {
      await player.setAudioSource(AudioSource.uri(Uri.parse(uri)));
      final dur = player.duration;
      _durationCache[uri] = dur;
      return dur;
    } finally {
      await player.dispose();
    }
  }

  Future<List<dynamic>> loadSongs({String? directoryPath}) async {
    if (directoryPath != null) {
      final directory = Directory(directoryPath);
      final files = directory
          .listSync(recursive: true)
          .where((f) => f.path.endsWith('.mp3'))
          .toList();

      List<LocalSong> songs = [];
      for (var file in files) {
        final uri = file.uri.toString();
        final dur = await fetchDuration(uri);                 // ⬅️

        songs.add(LocalSong(
          id: file.hashCode,
          title: file.uri.pathSegments.last,
          artist: 'Desconhecido',
          uri: uri,
          durationMillis: dur?.inMilliseconds,                // ⬅️
        ));
      }
      return songs;
    } else {
      // Mantém funcionalidade original – SongModel já expõe duration (ms ou null).
      // Caso o valor venha null, tratamos na UI; não é possível alterar o campo (somente-leitura).
      final result = await _audioQuery.querySongs();
      return result; // List<SongModel>
    }
  }


  Future<void> playFromUri(String uri, {LocalSong? song}) async {
    try {
      await _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(uri)));
      await _audioPlayer.play();
      if (song != null) {
        _lastPlayedLocalSong = song;
      }
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

  Stream<Duration> get positionStream => _audioPlayer.positionStream;

  Stream<Duration?> get durationStream => _audioPlayer.durationStream;

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}