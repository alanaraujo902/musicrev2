import 'playlist.dart';

class PlaylistFolder {
  String name;
  List<Playlist> playlists;
  bool isChecked;

  PlaylistFolder({required this.name, required this.playlists, this.isChecked = false});

  Map<String, dynamic> toJson() => {
    'name': name,
    'isChecked': isChecked,
    'playlists': playlists.map((p) => p.toJson()).toList(),
  };

  factory PlaylistFolder.fromJson(Map<String, dynamic> json) => PlaylistFolder(
    name: json['name'],
    isChecked: json['isChecked'] ?? false,
    playlists: (json['playlists'] as List).map((e) => Playlist.fromJson(e)).toList(),
  );
}
