import 'music_base.dart';
import 'music_init_controller.dart';
import 'music_playback_controller.dart';
import 'music_playlist_controller.dart';
import 'music_state_controller.dart';

class MusicController extends MusicControllerBase
    with
        MusicInitController,
        MusicPlaybackController,
        MusicPlaylistController,
        MusicStateController {
  /* ----------------------- SINGLETON ----------------------- */
  static final MusicController _instance = MusicController._internal();
  factory MusicController() {
    _instance._initializeController();
    return _instance;
  }
  MusicController._internal();

  /* ---------------------- CALLBACK ------------------------- */
  void _initializeController() {
    audioService.onSongComplete = () async {
      if (currentSongIndex < songs.length - 1) {
        await playNext();                               // vem do mixin
      }
    };
  }
}
