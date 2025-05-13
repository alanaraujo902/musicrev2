class LocalSong {
  final int id;
  final String title;
  final String artist;
  final String uri;
  bool isChecked;
  bool isFavorite;

  LocalSong({
    required this.id,
    required this.title,
    required this.artist,
    required this.uri,
    this.isChecked = false,
    this.isFavorite = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'artist': artist,
    'uri': uri,
    'isChecked': isChecked,
    'isFavorite': isFavorite,
  };

  factory LocalSong.fromJson(Map<String, dynamic> json) => LocalSong(
    id: json['id'],
    title: json['title'],
    artist: json['artist'],
    uri: json['uri'],
    isChecked: json['isChecked'] ?? false,
    isFavorite: json['isFavorite'] ?? false,
  );
}