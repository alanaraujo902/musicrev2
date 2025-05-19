import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../services/note_service.dart';

class TextNotePage extends StatefulWidget {
  const TextNotePage({super.key});

  @override
  State<TextNotePage> createState() => _TextNotePageState();
}

class _TextNotePageState extends State<TextNotePage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final _controller = TextEditingController();
  final _service = NoteService();
  late TabController _tab;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _load();
    _controller.addListener(_onTextChanged);
  }

  /* -------------------- LOAD / SAVE -------------------- */
  Future<void> _load() async {
    _controller.text = await _service.loadNote();
    setState(() {});
  }

  Future<void> _save() async {
    await _service.saveNote(_controller.text);
  }

  /* ---- auto-save com debounce (500 ms depois da última tecla) ---- */
  void _onTextChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), _save);
  }

  /* -------------------- CICLO DE VIDA ------------------ */
  @override
  void dispose() {
    _debounce?.cancel();
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _tab.dispose();
    super.dispose();
  }

  /* --------------------- UI ---------------------------- */
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _save(); // garante persistência antes de sair
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Anotações'),
          bottom: TabBar(
            controller: _tab,
            tabs: const [Tab(text: 'Editar'), Tab(text: 'Pré-visualizar')],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _save,
              tooltip: 'Salvar agora',
            ),
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
              styleSheet:
              MarkdownStyleSheet.fromTheme(Theme.of(context)),
            ),
          ],
        ),
      ),
    );
  }
}
