import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:extended_text_field/extended_text_field.dart';
import '../services/note_service.dart';

class TextNotePage extends StatefulWidget {
  final String songKey; // 🔑 URI ou id da música

  const TextNotePage({super.key, required this.songKey});

  @override
  State<TextNotePage> createState() => _TextNotePageState();
}

class _TextNotePageState extends State<TextNotePage>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  final _searchController = TextEditingController();
  final _service = NoteService();
  late TabController _tab;
  Timer? _debounce;
  String _searchTerm = '';
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _load();
    _controller.addListener(_onTextChanged);
    _searchController.addListener(() {
      setState(() {
        _searchTerm = _searchController.text.trim();
      });
    });
  }

  Future<void> _load() async {
    _controller.text = await _service.loadNote(widget.songKey);
    setState(() {});
  }

  Future<void> _save() async =>
      _service.saveNote(widget.songKey, _controller.text);

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
    _searchController.dispose();
    super.dispose();
  }

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
            if (_tab.index == 0) ...[
              IconButton(
                icon: Icon(_showSearch ? Icons.close : Icons.search),
                onPressed: () {
                  setState(() {
                    _showSearch = !_showSearch;
                    _searchController.clear();
                  });
                },
              ),
              IconButton(icon: const Icon(Icons.save), onPressed: _save),
            ]
          ],
        ),
        body: TabBarView(
          controller: _tab,
          children: [
            Column(
              children: [
                if (_showSearch)
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Buscar palavra...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: ExtendedTextField(
                      controller: _controller,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      expands: true,
                      specialTextSpanBuilder: HighlightSpanBuilder(_searchTerm),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Digite aqui em Markdown…',
                      ),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
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

class HighlightSpanBuilder extends SpecialTextSpanBuilder {
  final String searchTerm;

  HighlightSpanBuilder(this.searchTerm);

  @override
  SpecialText? createSpecialText(String flag,
      {TextStyle? textStyle,
        SpecialTextGestureTapCallback? onTap,
        required int index}) {
    return null; // Não usamos textos especiais com marcador, só realce geral
  }

  @override
  TextSpan build(String data,
      {TextStyle? textStyle,
        SpecialTextGestureTapCallback? onTap,
        bool? deleteAll}) {
    if (searchTerm.isEmpty) {
      return TextSpan(text: data, style: textStyle);
    }

    final spans = <TextSpan>[];
    final lcData = data.toLowerCase();
    final lcSearch = searchTerm.toLowerCase();
    int start = 0;

    while (true) {
      final idx = lcData.indexOf(lcSearch, start);
      if (idx == -1) {
        spans.add(TextSpan(text: data.substring(start), style: textStyle));
        break;
      }
      if (idx > start) {
        spans.add(TextSpan(text: data.substring(start, idx), style: textStyle));
      }
      spans.add(TextSpan(
        text: data.substring(idx, idx + lcSearch.length),
        style: textStyle?.copyWith(
          backgroundColor: Colors.yellow.shade300,
          fontWeight: FontWeight.bold,
        ),
      ));
      start = idx + lcSearch.length;
    }

    return TextSpan(children: spans);
  }
}