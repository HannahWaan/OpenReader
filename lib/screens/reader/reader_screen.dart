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
  void initState() {
    super.initState();
    WakelockPlus.enable(); // Giữ màn hình sáng
    _enterImmersive();
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    _exitImmersive();
    super.dispose();
  }

  void _enterImmersive() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _exitImmersive() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  void _toggleUI() => setState(() => _showUI = !_showUI);

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final readerTheme = themeState.readerThemeData;
    final books = ref.watch(libraryProvider);
    final book = books.where((b) => b.id == widget.bookId).firstOrNull;

    if (book == null) {
      return const Scaffold(body: Center(child: Text('Không tìm thấy sách')));
    }

    return Scaffold(
      backgroundColor: readerTheme.background,
      body: GestureDetector(
        onTap: _toggleUI,
        child: Stack(
          children: [
            // ─── NỘI DUNG SÁCH ───
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: themeState.marginH),
                child: Text(
                  'Reader Engine cho "${book.title}"\n\n'
                  'File: ${book.filePath}\n'
                  'Type: ${book.type.name}\n\n'
                  'Tap để ẩn/hiện UI.\n'
                  'Phần render EPUB/PDF/Scan sẽ được '
                  'tích hợp ở bước tiếp theo.',
                  style: TextStyle(
                    fontFamily: themeState.fontFamily,
                    fontSize: themeState.fontSize,
                    height: themeState.lineHeight,
                    color: readerTheme.text,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            // ─── TOP BAR ───
            if (_showUI)
              Positioned(
                top: 0, left: 0, right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        readerTheme.background,
                        readerTheme.background.withOpacity(0),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back, color: readerTheme.text),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: Text(
                            book.title,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: readerTheme.text,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.people_outline, color: readerTheme.text),
                          tooltip: 'Chaimager',
                          onPressed: () {
                            // TODO: mở Chaimager panel cho sách này
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // ─── BOTTOM BAR ───
            if (_showUI)
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        readerTheme.background,
                        readerTheme.background.withOpacity(0),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          // Page indicator
                          Text(
                            'Trang ${book.currentPage}/${book.totalPages}',
                            style: TextStyle(color: readerTheme.secondaryText, fontSize: 12),
                          ),
                          const Spacer(),
                          // Settings
                          IconButton(
                            icon: Icon(Icons.text_fields, color: readerTheme.text),
                            tooltip: 'Cài đặt đọc',
                            onPressed: () => _showSettings(context),
                          ),
                          // Bookmark
                          IconButton(
                            icon: Icon(Icons.bookmark_outline, color: readerTheme.text),
                            tooltip: 'Đánh dấu',
                            onPressed: () {
                              // TODO: toggle bookmark
                            },
                          ),
                          // TOC
                          IconButton(
                            icon: Icon(Icons.list, color: readerTheme.text),
                            tooltip: 'Mục lục',
                            onPressed: () {
                              // TODO: open TOC drawer
                            },
                          ),
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

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const ReaderSettingsSheet(),
    );
  }
}
