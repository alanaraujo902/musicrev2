import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:extended_text_field/extended_text_field.dart';
import '../services/note_service.dart';

class TextNotePage extends StatefulWidget {
  final String songKey;
  const TextNotePage({super.key, required this.songKey});

  @override
  State<TextNotePage> createState() => _TextNotePageState();
}

class _TextNotePageState extends State<TextNotePage>
    with SingleTickerProviderStateMixin {
  final _controller       = TextEditingController();
  final _searchController = TextEditingController();
  final _scroll           = ScrollController();
  final _fieldKey         = GlobalKey<ExtendedEditableTextState>();
  final _service          = NoteService();

  late TabController _tab;
  Timer? _debounce;
  String _searchTerm = '';
  bool _showSearch   = false;

  List<int> _hits = [];
  int _hitPtr = -1;

  /* ======================== INIT / DISPOSE ======================== */
  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _load();
    _controller.addListener(_onTextChanged);

    _searchController.addListener(() {
      _searchTerm = _searchController.text.trim();
      _updateHits();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _save();
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _tab.dispose();
    _scroll.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /* ======================== DATA I/O ======================== */
  Future<void> _load() async {
    _controller.text = await _service.loadNote(widget.songKey);
    _updateHits();
    setState(() {});
  }

  Future<void> _save() async =>
      _service.saveNote(widget.songKey, _controller.text);

  /* ====================== TEXT LISTENERS ===================== */
  void _onTextChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _save();
      if (_searchTerm.isNotEmpty) _updateHits();
    });
  }

  /* ======================= SEARCH HELPERS ===================== */
  void _updateHits() {
    _hits.clear();
    _hitPtr = -1;

    if (_searchTerm.isEmpty) return;

    final src = _controller.text.toLowerCase();
    final pat = _searchTerm.toLowerCase();

    int i = src.indexOf(pat);
    while (i != -1) {
      _hits.add(i);
      i = src.indexOf(pat, i + pat.length);
    }
  }

  void _jump(int dir) {
    if (_hits.isEmpty) return;

    // Avança / retrocede circularmente
    _hitPtr = (_hitPtr + dir) % _hits.length;
    if (_hitPtr < 0) _hitPtr += _hits.length;

    final pos = _hits[_hitPtr];
    _controller.selection =
        TextSelection(baseOffset: pos, extentOffset: pos + _searchTerm.length);

    // Espera o frame para ter o caret na posição certa, depois centraliza
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCaret());
    setState(() {});
  }

  void _scrollToCaret() {
    final state = _fieldKey.currentState;
    if (state == null) return;

    final caretRect =
    state.renderEditable.getLocalRectForCaret(_controller.selection.extent);

    final scrollOffset     = _scroll.offset;
    final viewportHeight   = _scroll.position.viewportDimension;
    final caretGlobalY     = caretRect.top + scrollOffset;
    final targetScrollY    = caretGlobalY - viewportHeight / 2;

    _scroll.animateTo(
      targetScrollY.clamp(0.0, _scroll.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }


  /* =========================== UI =========================== */
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
                    _updateHits();
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
            /* =================== TAB “EDITAR” =================== */
            Column(
              children: [
                if (_showSearch) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Buscar palavra…',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.keyboard_arrow_up),
                        onPressed: _hits.isEmpty ? null : () => _jump(-1),
                      ),
                      Text(_hits.isEmpty
                          ? '0/0'
                          : '${_hitPtr + 1}/${_hits.length}'),
                      IconButton(
                        icon: const Icon(Icons.keyboard_arrow_down),
                        onPressed: _hits.isEmpty ? null : () => _jump(1),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ],
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: ExtendedTextField(
                      key: _fieldKey,
                      controller: _controller,
                      scrollController: _scroll,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      expands: true,
                      specialTextSpanBuilder:
                      HighlightSpanBuilder(_searchTerm),
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
            /* =================== TAB “PREVIEW” ================== */
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

/* ============================================================= */
/*                 HIGHLIGHT BUILD (sem alterações)               */
/* ============================================================= */

class HighlightSpanBuilder extends SpecialTextSpanBuilder {
  final String searchTerm;
  HighlightSpanBuilder(this.searchTerm);

  @override
  SpecialText? createSpecialText(String flag,
      {TextStyle? textStyle,
        SpecialTextGestureTapCallback? onTap,
        required int index}) =>
      null;

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
