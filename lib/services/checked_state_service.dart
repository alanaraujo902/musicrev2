import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class CheckedStateService {
  Future<String> _getFilePath() async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/checked_states.json';
  }

  Future<Map<String, bool>> loadCheckedStates() async {
    final path = await _getFilePath();
    final file = File(path);
    if (!await file.exists()) return {};

    final content = await file.readAsString();
    final data = jsonDecode(content);
    return Map<String, bool>.from(data);
  }

  Future<void> saveCheckedState(String uri, bool isChecked) async {
    final states = await loadCheckedStates();
    states[uri] = isChecked;
    final path = await _getFilePath();
    final file = File(path);
    await file.writeAsString(jsonEncode(states));
  }
}
