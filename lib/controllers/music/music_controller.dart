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
  static final MusicController _instance = MusicController._internal();
  factory MusicController() => _instance;
  MusicController._internal();
}
