import 'package:hive_flutter/hive_flutter.dart';

class NoteService {
  static const _boxName = 'notesBox';

  Box<String> get _box => Hive.box<String>(_boxName);

  /// Carrega a anotação da música identificada por [songKey].
  Future<String> loadNote(String songKey) async =>
      _box.get(songKey, defaultValue: '') ?? '';

  /// Salva a anotação [text] para a música identificada por [songKey].
  Future<void> saveNote(String songKey, String text) async =>
      _box.put(songKey, text);

  Future<bool> hasNote(String key) async =>
      (_box.get(key, defaultValue: '') ?? '').trim().isNotEmpty;

}
