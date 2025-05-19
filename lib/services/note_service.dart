import 'package:shared_preferences/shared_preferences.dart';

class NoteService {
  static const _key = 'fullscreen_note_markdown';

  Future<String> loadNote() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key) ?? '';
  }

  Future<void> saveNote(String text) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, text);
  }
}
