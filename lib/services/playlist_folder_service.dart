import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/playlist_folder.dart';

class PlaylistFolderService {
  Future<String> _getFilePath() async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/playlist_folders.json';
  }

  Future<List<PlaylistFolder>> loadFolders() async {
    final path = await _getFilePath();
    final file = File(path);
    if (!await file.exists()) return [];

    final content = await file.readAsString();
    final data = jsonDecode(content);
    return (data as List).map((e) => PlaylistFolder.fromJson(e)).toList();
  }

  Future<void> saveFolders(List<PlaylistFolder> folders) async {
    final path = await _getFilePath();
    final file = File(path);
    final jsonStr = jsonEncode(folders.map((f) => f.toJson()).toList());
    await file.writeAsString(jsonStr);
  }
}
