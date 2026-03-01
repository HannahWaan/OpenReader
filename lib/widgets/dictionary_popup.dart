import 'package:flutter/material.dart';
import '../services/dictionary/dictionary_service.dart';

class DictionaryPopup extends StatefulWidget {
  final String initialWord;
  final String? bookId;
  final String? bookTitle;
  final String? contextSentence;

  const DictionaryPopup({super.key, required this.initialWord,
    this.bookId, this.bookTitle, this.contextSentence});

  @override
  State<DictionaryPopup> createState() => _DictionaryPopupState();

  static void show(BuildContext context, {required String word,
    String? bookId, String? bookTitle, String? contextSentence}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DictionaryPopup(initialWord: word,
        bookId: bookId, bookTitle: bookTitle, contextSentence: contextSentence),
    );
  }
}

class _DictionaryPopupState extends State<DictionaryPopup> {
  DictEntry? _result;
  List<DictEntry> _suggestions = [];
  bool _loading = true;
  bool _saved = false;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialWord);
    _lookup(widget.initialWord);
  }

  Future<void> _lookup(String word) async {
    setState(() { _loading = true; _result = null; _suggestions = []; });
    final exact = await DictionaryService.lookup(word);
    final suggestions = await DictionaryService.search(word);
    setState(() {
      _result = exact;
      _suggestions = suggestions.where((s) => s.word.toLowerCase() != word.toLowerCase()).toList();
      _loading = false;
    });
  }

  Future<void> _saveToVocab() async {
    if (_result == null) return;
    await DictionaryService.saveToVocabulary(
      word: _result!.word, definition: _result!.definition,
      contextSentence: widget.contextSentence,
      bookId: widget.bookId, bookTitle: widget.bookTitle);
    setState(() => _saved = true);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
      decoration: BoxDecoration(color: scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Handle
        Container(width: 40, height: 4, decoration: BoxDecoration(
          color: scheme.outline.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 16),

        // Search bar
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Tra tu...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(icon: const Icon(Icons.clear, size: 18),
              onPressed: () { _searchController.clear(); }),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            isDense: true),
          onSubmitted: (v) => _lookup(v.trim()),
        ),
        const SizedBox(height: 16),

        // Result
        Flexible(child: SingleChildScrollView(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_loading)
              const Center(child: Padding(padding: EdgeInsets.all(24),
                child: CircularProgressIndicator()))
            else if (_result != null) ...[
              // Word + phonetic
              Row(children: [
                Expanded(child: Text(_result!.word,
                  style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold))),
                // Save button
                IconButton(
                  icon: Icon(_saved ? Icons.bookmark : Icons.bookmark_outline,
                    color: _saved ? scheme.primary : null),
                  tooltip: _saved ? 'Da luu' : 'Luu vao Vocabulary',
                  onPressed: _saved ? null : _saveToVocab),
              ]),
              if (_result!.phonetic != null)
                Text(_result!.phonetic!, style: textTheme.bodyMedium?.copyWith(
                  color: scheme.primary, fontStyle: FontStyle.italic)),
              if (_result!.partOfSpeech != null)
                Padding(padding: const EdgeInsets.only(top: 4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(4)),
                    child: Text(_result!.partOfSpeech!, style: textTheme.bodySmall?.copyWith(
                      color: scheme.primary, fontWeight: FontWeight.w600)))),
              const SizedBox(height: 12),
              // Definition
              Text(_result!.definition, style: textTheme.bodyLarge),
              // Example
              if (_result!.example != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8)),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Icon(Icons.format_quote, size: 16, color: scheme.outline),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_result!.example!,
                      style: textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic))),
                  ])),
              ],
            ] else ...[
              // Khong tim thay
              Padding(padding: const EdgeInsets.all(24),
                child: Column(children: [
                  Icon(Icons.search_off, size: 48, color: scheme.outline),
                  const SizedBox(height: 8),
                  Text('Khong tim thay "${_searchController.text}"',
                    style: textTheme.bodyLarge, textAlign: TextAlign.center),
                  const SizedBox(height: 4),
                  Text('Thu tra tu khac hoac them tu moi',
                    style: textTheme.bodyMedium),
                ])),
            ],

            // Suggestions
            if (_suggestions.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Goi y:', style: textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8,
                children: _suggestions.take(8).map((s) => ActionChip(
                  label: Text(s.word),
                  onPressed: () {
                    _searchController.text = s.word;
                    _lookup(s.word);
                  })).toList()),
            ],
          ],
        ))),
      ]),
    );
  }
}
