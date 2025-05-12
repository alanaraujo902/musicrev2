import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/playlist.dart';

class PlaylistService {
  Future<String> _getFilePath() async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/playlists.json';
  }

  Future<List<Playlist>> loadPlaylists() async {
    final path = await _getFilePath();
    final file = File(path);

    if (!await file.exists()) return [];

    final content = await file.readAsString();
    final List data = jsonDecode(content);
    return data.map((e) => Playlist.fromJson(e)).toList();
  }

  Future<void> savePlaylists(List<Playlist> playlists) async {
    final path = await _getFilePath();
    final file = File(path);
    final jsonStr = jsonEncode(playlists.map((e) => e.toJson()).toList());
    await file.writeAsString(jsonStr);
  }
}
