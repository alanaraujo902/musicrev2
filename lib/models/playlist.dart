import 'local_song.dart';

class Playlist {
  final String name;
  final List<LocalSong> songs;
  bool isChecked;

  Playlist({required this.name, required this.songs, this.isChecked = false});

  Map<String, dynamic> toJson() => {
    'name': name,
    'songs': songs.map((s) => s.toJson()).toList(),
    'isChecked': isChecked,
  };

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      name: json['name'],
      songs: (json['songs'] as List).map((e) => LocalSong.fromJson(e)).toList(),
      isChecked: json['isChecked'] ?? false,
    );
  }
}
