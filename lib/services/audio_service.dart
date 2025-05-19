import 'dart:io';
import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../controllers/music/music_controller.dart';
import '../models/local_song.dart';
import '../models/playlist.dart';

class AudioService {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final AudioPlayer _audioPlayer = AudioPlayer();
  LocalSong? _lastPlayedLocalSong;
  final Map<String, Duration?> _durationCache = {};

  void Function()? onSongComplete;

  AudioService() {
    _audioPlayer.playerStateStream.listen((state) async {
      if (state.processingState == ProcessingState.completed) {
        // guarda e limpa a referência para evitar marcação dupla
        final finishedSong = _lastPlayedLocalSong;
        _lastPlayedLocalSong = null;

        if (finishedSong != null) {
          await _handleSongCompleted(finishedSong);
        }

        if (onSongComplete != null) {
          onSongComplete!();
        }
      }
    });
  }

  Future<void> _handleSongCompleted(LocalSong song) async {
    final controller = MusicController();

    // garante que o controller saiba de qual playlist a música veio
    if (controller.loadedPlaylist == null) {
      controller.loadedPlaylist = controller.playlistsNotifier.value.firstWhere(
            (p) => p.songs.any((s) => s.uri == song.uri),
        orElse: () => Playlist(name: 'Temp', songs: []),
      );
    }

    await controller.toggleChecked(song, true);
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
        final dur = await fetchDuration(uri);

        songs.add(LocalSong(
          id: file.hashCode,
          title: file.uri.pathSegments.last,
          artist: 'Desconhecido',
          uri: uri,
          durationMillis: dur?.inMilliseconds,
        ));
      }
      return songs;
    } else {
      final result = await _audioQuery.querySongs();
      return result; // List<SongModel>
    }
  }

  Future<void> playFromUri(String uri, {LocalSong? song}) async {
    try {
      // define ANTES de tocar para que o listener já conheça a música
      if (song != null) {
        _lastPlayedLocalSong = song;
      }

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

  Stream<Duration> get positionStream => _audioPlayer.positionStream;

  Stream<Duration?> get durationStream => _audioPlayer.durationStream;

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
