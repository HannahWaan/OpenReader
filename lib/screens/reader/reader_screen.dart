import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../providers/theme_provider.dart';
import '../../providers/library_provider.dart';
import '../../models/book.dart';
import 'reader_settings_sheet.dart';
import 'scan_reader_view.dart';

class ReaderScreen extends ConsumerStatefulWidget {
  final String bookId;
  const ReaderScreen({super.key, required this.bookId});
  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  bool _showUI = true;
  final _pdfController = PdfViewerController();
  int _currentPage = 1;
  int _totalPages = 0;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _saveProgress(Book book) {
    if (_totalPages > 0) {
      ref.read(libraryProvider.notifier).updateBook(Book(
        id: book.id, title: book.title, author: book.author,
        coverPath: book.coverPath, filePath: book.filePath, type: book.type,
        totalPages: _totalPages, currentPage: _currentPage,
        progress: _currentPage / _totalPages, status: ReadingStatus.reading,
        tags: book.tags, rating: book.rating,
        createdAt: book.createdAt, updatedAt: DateTime.now()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final ts = ref.watch(themeProvider);
    final rt = ts.readerThemeData;
    final books = ref.watch(libraryProvider);
    final book = books.where((b) => b.id == widget.bookId).firstOrNull;

    if (book == null) {
      return Scaffold(backgroundColor: rt.background,
        body: Center(child: Text('Khong tim thay sach', style: TextStyle(color: rt.text))));
    }

    final fileExists = File(book.filePath).existsSync();

    return Scaffold(
      backgroundColor: rt.background,
      body: GestureDetector(
        onTap: () => setState(() => _showUI = !_showUI),
        child: Stack(children: [
          // ═══ CONTENT ═══
          if (book.type == BookType.pdf && fileExists)
            PdfViewer.file(book.filePath,
              controller: _pdfController,
              params: PdfViewerParams(
                backgroundColor: rt.background,
                onPageChanged: (pageNumber) {
                  setState(() => _currentPage = pageNumber ?? 1);
                },
                loadingBannerBuilder: (context, bytesDownloaded, totalBytes) =>
                  Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    CircularProgressIndicator(color: rt.text),
                    const SizedBox(height: 16),
                    Text('Dang tai...', style: TextStyle(color: rt.secondaryText))])),
                onViewerReady: (document, controller) {
                  setState(() {
                    _totalPages = document.pages.length;
                    if (book.currentPage > 1) controller.goToPage(pageNumber: book.currentPage);
                  });
                }))
          else if (book.type == BookType.scan && fileExists)
            ScanReaderView(filePath: book.filePath, theme: rt,
              fontSize: ts.fontSize, lineHeight: ts.lineHeight, fontFamily: ts.fontFamily)
          else if (!fileExists)
            Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.error_outline, size: 64, color: rt.secondaryText),
              const SizedBox(height: 16),
              Text('Khong tim thay file', style: TextStyle(color: rt.text, fontSize: 18))]))
          else
            Center(child: Text('${book.type.name.toUpperCase()} - Phase tiep theo',
              style: TextStyle(color: rt.text, fontSize: 18))),

          // ═══ TOP BAR ═══
          if (_showUI) Positioned(top: 0, left: 0, right: 0,
            child: Container(
              decoration: BoxDecoration(gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [rt.background, rt.background.withValues(alpha: 0)])),
              child: SafeArea(child: Row(children: [
                IconButton(icon: Icon(Icons.arrow_back, color: rt.text),
                  onPressed: () { _saveProgress(book); Navigator.pop(context); }),
                Expanded(child: Text(book.title, overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: rt.text, fontWeight: FontWeight.w600))),
                IconButton(icon: Icon(Icons.people_outline, color: rt.text),
                  tooltip: 'Chaimager', onPressed: () {})])))),

          // ═══ BOTTOM BAR ═══
          if (_showUI) Positioned(bottom: 0, left: 0, right: 0,
            child: Container(
              decoration: BoxDecoration(gradient: LinearGradient(
                begin: Alignment.bottomCenter, end: Alignment.topCenter,
                colors: [rt.background, rt.background.withValues(alpha: 0)])),
              child: SafeArea(child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  if (_totalPages > 0 && book.type == BookType.pdf)
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: rt.text.withValues(alpha: 0.7),
                        inactiveTrackColor: rt.secondaryText.withValues(alpha: 0.3),
                        thumbColor: rt.text, trackHeight: 2,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6)),
                      child: Slider(
                        value: _currentPage.toDouble().clamp(1, _totalPages.toDouble()),
                        min: 1, max: _totalPages.toDouble(),
                        onChanged: (v) {
                          final page = v.toInt();
                          setState(() => _currentPage = page);
                          _pdfController.goToPage(pageNumber: page);
                        })),
                  Row(children: [
                    if (book.type == BookType.pdf && _totalPages > 0)
                      Text('$_currentPage / $_totalPages  (${(_currentPage / _totalPages * 100).toInt()}%)',
                        style: TextStyle(color: rt.secondaryText, fontSize: 12)),
                    const Spacer(),
                    IconButton(icon: Icon(Icons.text_fields, color: rt.text),
                      onPressed: () => showModalBottomSheet(context: context,
                        backgroundColor: Colors.transparent,
                        builder: (_) => const ReaderSettingsSheet())),
                    IconButton(icon: Icon(Icons.bookmark_outline, color: rt.text),
                      onPressed: () {}),
                  ])]))))),
        ]),
      ),
    );
  }
}
