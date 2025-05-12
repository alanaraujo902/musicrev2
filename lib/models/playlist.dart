import 'local_song.dart';

class Playlist {
  final String name;
  final List<LocalSong> songs;

  Playlist({required this.name, required this.songs});

  Map<String, dynamic> toJson() => {
    'name': name,
    'songs': songs.map((s) => s.toJson()).toList(),
  };

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      name: json['name'],
      songs: (json['songs'] as List).map((e) => LocalSong.fromJson(e)).toList(),
    );
  }
}
