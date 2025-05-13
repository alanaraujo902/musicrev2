import 'playlist.dart';

class PlaylistFolder {
  String name;
  List<Playlist> playlists;

  PlaylistFolder({required this.name, required this.playlists});

  Map<String, dynamic> toJson() => {
    'name': name,
    'playlists': playlists.map((p) => p.toJson()).toList(),
  };

  factory PlaylistFolder.fromJson(Map<String, dynamic> json) => PlaylistFolder(
    name: json['name'],
    playlists: (json['playlists'] as List).map((e) => Playlist.fromJson(e)).toList(),
  );
}
