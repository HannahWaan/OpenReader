import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../models/book.dart';
import '../../models/highlight.dart';
import '../../models/chaimager_character.dart';
import '../../providers/library_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/chaimager/chaimager_service.dart';
import '../../services/highlight/highlight_service.dart';
import '../../widgets/dictionary_popup.dart';
import '../../widgets/character_popup.dart';
import 'reader_settings_sheet.dart';
import 'scan_reader_view.dart';

class ReaderScreen extends ConsumerStatefulWidget {
  final String bookId;
  const ReaderScreen({super.key, required this.bookId});

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  final PdfViewerController _pdfController = PdfViewerController();
  bool _showUI = true;
  int _currentPage = 1;
  int _totalPages = 0;
  List<ChaimagerCharacter> _characters = [];
  List<Highlight> _highlights = [];

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    _loadData();
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    super.dispose();
  }

  Future<void> _loadData() async {
    final bookChars = await ChaimagerService.getCharacters(widget.bookId);
    final allChars = await ChaimagerService.getAllCharacters();
    final uniqueChars = <String, ChaimagerCharacter>{};
    for (final c in [...bookChars, ...allChars]) {
      uniqueChars[c.id] = c;
    }
    final highlights = await HighlightService.getHighlights(widget.bookId);
    setState(() {
      _characters = uniqueChars.values.toList();
      _highlights = highlights;
    });
  }

  void _saveProgress() {
    final books = ref.read(libraryProvider);
    try {
      final book = books.firstWhere((b) => b.id == widget.bookId);
      ref.read(libraryProvider.notifier).updateBook(
        book.copyWith(currentPage: _currentPage, totalPages: _totalPages),
      );
    } catch (_) {}
  }

  void _showDictionary(String word) {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      builder: (_) => DictionaryPopup(initialWord: word, bookId: widget.bookId),
    );
  }

  void _showCharacterInfo(ChaimagerCharacter char) {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      builder: (_) => CharacterPopup(character: char),
    );
  }

  void _showNoteDialog(String text) {
    final noteCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('"$text"', style: const TextStyle(fontStyle: FontStyle.italic), maxLines: 3, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 12),
            TextField(controller: noteCtrl, decoration: const InputDecoration(labelText: 'Your note', border: OutlineInputBorder()), maxLines: 3),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(onPressed: () async {
            await HighlightService.addHighlight(Highlight(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              bookId: widget.bookId, text: text,
              note: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
              page: _currentPage, color: 0xFF81C784, createdAt: DateTime.now(),
            ));
            await _loadData();
            if (ctx.mounted) Navigator.pop(ctx);
            if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved!'), duration: Duration(seconds: 1)));
          }, child: const Text('Save')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final books = ref.watch(libraryProvider);
    final themeState = ref.watch(themeProvider);
    final readerTheme = themeState.readerThemeData;
    final now = DateTime.now();
    final book = books.firstWhere((b) => b.id == widget.bookId,
        orElse: () => Book(id: '', title: 'Not Found', filePath: '', type: BookType.pdf, createdAt: now, updatedAt: now));

    if (book.id.isEmpty || !File(book.filePath).existsSync()) {
      return Scaffold(appBar: AppBar(title: const Text('Error')), body: const Center(child: Text('Book file not found')));
    }

    if (book.type == BookType.scan) {
      return ScanReaderView(
        filePath: book.filePath,
        theme: readerTheme,
        fontSize: themeState.fontSize,
        lineHeight: themeState.lineHeight,
        fontFamily: themeState.fontFamily,
      );
    }

    final bgColor = readerTheme.background;
    final textColor = readerTheme.text;

    return Scaffold(
      backgroundColor: bgColor,
      body: GestureDetector(
        onTap: () => setState(() => _showUI = !_showUI),
        child: Stack(
          children: [
            PdfViewer.file(
              book.filePath,
              controller: _pdfController,
              params: PdfViewerParams(
                backgroundColor: bgColor,
                onPageChanged: (page) { setState(() => _currentPage = page ?? 1); },
                onViewerReady: (document, controller) {
                  setState(() {
                    _totalPages = document.pages.length;
                    if (book.currentPage > 1) controller.goToPage(pageNumber: book.currentPage);
                    _currentPage = book.currentPage > 0 ? book.currentPage : 1;
                  });
                },
              ),
            ),
            if (_showUI)
              Positioned(
                top: 0, left: 0, right: 0,
                child: Container(
                  decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [bgColor, bgColor.withValues(alpha: 0)])),
                  child: SafeArea(
                    bottom: false,
                    child: Row(
                      children: [
                        IconButton(icon: Icon(Icons.arrow_back, color: textColor), onPressed: () { _saveProgress(); Navigator.pop(context); }),
                        Expanded(child: Text(book.title, style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis)),
                        if (_characters.isNotEmpty)
                          IconButton(icon: Badge(label: Text('${_characters.length}'), child: Icon(Icons.people, color: textColor)),
                            onPressed: () { showModalBottomSheet(context: context, builder: (_) => _CharacterListSheet(characters: _characters, onTap: _showCharacterInfo)); }),
                        if (_highlights.isNotEmpty)
                          IconButton(icon: Badge(label: Text('${_highlights.length}'), child: Icon(Icons.highlight, color: textColor)),
                            onPressed: () { showModalBottomSheet(context: context, isScrollControlled: true, builder: (_) => _HighlightListSheet(highlights: _highlights, onDelete: (id) async { await HighlightService.deleteHighlight(id); await _loadData(); })); }),
                        IconButton(icon: Icon(Icons.search, color: textColor), onPressed: () => _showDictionary('')),
                        IconButton(icon: Icon(Icons.settings, color: textColor),
                          onPressed: () { showModalBottomSheet(context: context, isScrollControlled: true, builder: (_) => const ReaderSettingsSheet()); }),
                      ],
                    ),
                  ),
                ),
              ),
            if (_showUI && _totalPages > 0)
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Container(
                  decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [bgColor, bgColor.withValues(alpha: 0)])),
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Slider(value: _currentPage.toDouble().clamp(1, _totalPages.toDouble()), min: 1, max: _totalPages.toDouble(), onChanged: (v) { _pdfController.goToPage(pageNumber: v.round()); }),
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Text('$_currentPage / $_totalPages', style: TextStyle(color: textColor, fontSize: 13)),
                            Text('${(_currentPage / _totalPages * 100).toStringAsFixed(1)}%', style: TextStyle(color: textColor, fontSize: 13)),
                          ]),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CharacterListSheet extends StatelessWidget {
  final List<ChaimagerCharacter> characters;
  final void Function(ChaimagerCharacter) onTap;
  const _CharacterListSheet({required this.characters, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Padding(padding: const EdgeInsets.all(16), child: Text('Characters', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))),
      ...characters.map((c) => ListTile(
        leading: CircleAvatar(child: Text(c.name[0].toUpperCase())),
        title: Text(c.name), subtitle: c.role != null ? Text(c.role!) : null,
        onTap: () { Navigator.pop(context); onTap(c); },
      )),
      const SizedBox(height: 8),
    ]));
  }
}

class _HighlightListSheet extends StatelessWidget {
  final List<Highlight> highlights;
  final void Function(String id) onDelete;
  const _HighlightListSheet({required this.highlights, required this.onDelete});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.5, minChildSize: 0.3, maxChildSize: 0.8, expand: false,
      builder: (_, scrollCtrl) => Column(children: [
        Padding(padding: const EdgeInsets.all(16), child: Text('Highlights (${highlights.length})', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))),
        Expanded(child: ListView.builder(
          controller: scrollCtrl, itemCount: highlights.length,
          itemBuilder: (_, i) {
            final h = highlights[i];
            return Dismissible(
              key: ValueKey(h.id), direction: DismissDirection.endToStart,
              background: Container(alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), color: Colors.red, child: const Icon(Icons.delete, color: Colors.white)),
              onDismissed: (_) => onDelete(h.id),
              child: ListTile(
                leading: Container(width: 4, height: 40, decoration: BoxDecoration(color: Color(h.color), borderRadius: BorderRadius.circular(2))),
                title: Text(h.text, maxLines: 2, overflow: TextOverflow.ellipsis),
                subtitle: Text(['Page ${h.page}', if (h.note != null) h.note!].join(' · '), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: theme.colorScheme.outline, fontSize: 12)),
              ),
            );
          },
        )),
      ]),
    );
  }
}
