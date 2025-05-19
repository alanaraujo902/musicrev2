import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../services/note_service.dart';

class TextNotePage extends StatefulWidget {
  final String songKey;                     // 🔑 URI ou id da música

  const TextNotePage({super.key, required this.songKey});

  @override
  State<TextNotePage> createState() => _TextNotePageState();
}

class _TextNotePageState extends State<TextNotePage>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  final _service    = NoteService();
  late TabController _tab;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _load();
    _controller.addListener(_onTextChanged);
  }

  /* ---------------- load / save ---------------- */
  Future<void> _load() async {
    _controller.text = await _service.loadNote(widget.songKey);
    setState(() {});
  }

  Future<void> _save() async =>
      _service.saveNote(widget.songKey, _controller.text);

  /* --------- auto-save com debounce --------- */
  void _onTextChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), _save);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _save();
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _tab.dispose();
    super.dispose();
  }

  /* -------------------- UI ------------------- */
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _save();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              await _save();
              Navigator.pop(context);
            },
          ),
          title: const Text('Anotações'),
          bottom: TabBar(
            controller: _tab,
            tabs: const [Tab(text: 'Editar'), Tab(text: 'Pré-visualizar')],
          ),
          actions: [
            IconButton(icon: const Icon(Icons.save), onPressed: _save),
          ],
        ),
        body: TabBarView(
          controller: _tab,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _controller,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Digite aqui em Markdown…',
                ),
              ),
            ),
            Markdown(
              data: _controller.text,
              styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)),
            ),
          ],
        ),
      ),
    );
  }
}
