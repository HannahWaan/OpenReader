import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../providers/theme_provider.dart';
import '../../providers/library_provider.dart';
import 'reader_settings_sheet.dart';

class ReaderScreen extends ConsumerStatefulWidget {
  final String bookId;
  const ReaderScreen({super.key, required this.bookId});
  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}
class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  bool _showUI = true;
  @override
  void initState() { super.initState(); WakelockPlus.enable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky); }
  @override
  void dispose() { WakelockPlus.disable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final ts = ref.watch(themeProvider);
    final rt = ts.readerThemeData;
    final books = ref.watch(libraryProvider);
    final book = books.where((b) => b.id == widget.bookId).firstOrNull;
    if (book == null) return const Scaffold(body: Center(child: Text('Khong tim thay sach')));

    return Scaffold(backgroundColor: rt.background, body: GestureDetector(
      onTap: () => setState(() => _showUI = !_showUI),
      child: Stack(children: [
        Center(child: Padding(padding: EdgeInsets.symmetric(horizontal: ts.marginH),
          child: Text('"${book.title}"\n\nReader Engine Phase 2.\nTap de an/hien UI.',
            style: TextStyle(fontFamily: ts.fontFamily, fontSize: ts.fontSize,
              height: ts.lineHeight, color: rt.text), textAlign: TextAlign.center))),
        if (_showUI) Positioned(top: 0, left: 0, right: 0,
          child: Container(
            decoration: BoxDecoration(gradient: LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [rt.background, rt.background.withValues(alpha: 0)])),
            child: SafeArea(child: Row(children: [
              IconButton(icon: Icon(Icons.arrow_back, color: rt.text),
                onPressed: () => Navigator.pop(context)),
              Expanded(child: Text(book.title, overflow: TextOverflow.ellipsis,
                style: TextStyle(color: rt.text, fontWeight: FontWeight.w600))),
              IconButton(icon: Icon(Icons.people_outline, color: rt.text),
                tooltip: 'Chaimager', onPressed: () {})])))),
        if (_showUI) Positioned(bottom: 0, left: 0, right: 0,
          child: Container(
            decoration: BoxDecoration(gradient: LinearGradient(
              begin: Alignment.bottomCenter, end: Alignment.topCenter,
              colors: [rt.background, rt.background.withValues(alpha: 0)])),
            child: SafeArea(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(children: [
                Text('Trang ${book.currentPage}/${book.totalPages}',
                  style: TextStyle(color: rt.secondaryText, fontSize: 12)),
                const Spacer(),
                IconButton(icon: Icon(Icons.text_fields, color: rt.text),
                  onPressed: () => showModalBottomSheet(context: context,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const ReaderSettingsSheet())),
                IconButton(icon: Icon(Icons.bookmark_outline, color: rt.text), onPressed: () {}),
                IconButton(icon: Icon(Icons.list, color: rt.text), onPressed: () {})]))))),
      ])));
  }
}
