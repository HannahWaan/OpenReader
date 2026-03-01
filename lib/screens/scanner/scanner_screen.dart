import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../services/ocr/ocr_service.dart';
import '../../models/book.dart';
import '../../providers/library_provider.dart';

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});
  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  final _ocr = OCRService();
  final _picker = ImagePicker();
  final List<ScannedPage> _pages = [];
  bool _isProcessing = false;

  @override
  void dispose() {
    _ocr.dispose();
    super.dispose();
  }

  Future<void> _captureFromCamera() async {
    final image = await _picker.pickImage(source: ImageSource.camera, imageQuality: 90);
    if (image != null) await _processImage(image.path);
  }

  Future<void> _pickFromGallery() async {
    final images = await _picker.pickMultiImage(imageQuality: 90);
    for (final image in images) {
      await _processImage(image.path);
    }
  }

  Future<void> _processImage(String imagePath) async {
    setState(() => _isProcessing = true);
    try {
      final result = await _ocr.recognizeFromFile(imagePath);
      setState(() {
        _pages.add(ScannedPage(
          imagePath: imagePath,
          text: result.fullText,
          pageNumber: _pages.length + 1,
        ));
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Loi OCR: $e')));
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _saveAsBook() async {
    if (_pages.isEmpty) return;

    final nameController = TextEditingController(text: 'Sach scan ${DateTime.now().day}/${DateTime.now().month}');
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Dat ten sach'),
        content: TextField(controller: nameController,
          decoration: const InputDecoration(labelText: 'Ten sach')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Huy')),
          FilledButton(onPressed: () => Navigator.pop(context, nameController.text),
            child: const Text('Luu')),
        ],
      ),
    );

    if (result == null || result.trim().isEmpty) return;

    // Luu text vao file
    final dir = await getApplicationDocumentsDirectory();
    final bookId = const Uuid().v4();
    final textFile = File(p.join(dir.path, 'scan_$bookId.txt'));
    final allText = _pages.map((p) => '--- Trang ${p.pageNumber} ---\n${p.text}').join('\n\n');
    await textFile.writeAsString(allText);

    // Luu vao library
    final now = DateTime.now();
    ref.read(libraryProvider.notifier).addBook(Book(
      id: bookId,
      title: result.trim(),
      filePath: textFile.path,
      type: BookType.scan,
      totalPages: _pages.length,
      createdAt: now,
      updatedAt: now,
    ));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Da luu "${result.trim()}" voi ${_pages.length} trang')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan sach (${_pages.length} trang)'),
        actions: [
          if (_pages.isNotEmpty)
            IconButton(icon: const Icon(Icons.save),
              tooltip: 'Luu thanh sach',
              onPressed: _saveAsBook),
        ],
      ),
      body: Column(
        children: [
          // Nut chup / chon anh
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Expanded(child: OutlinedButton.icon(
                onPressed: _isProcessing ? null : _captureFromCamera,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Chup anh'),
              )),
              const SizedBox(width: 12),
              Expanded(child: OutlinedButton.icon(
                onPressed: _isProcessing ? null : _pickFromGallery,
                icon: const Icon(Icons.photo_library),
                label: const Text('Thu vien'),
              )),
            ]),
          ),

          if (_isProcessing)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Column(children: [
                CircularProgressIndicator(),
                SizedBox(height: 8),
                Text('Dang nhan dien chu...'),
              ]),
            ),

          // Danh sach trang da scan
          Expanded(
            child: _pages.isEmpty
              ? Center(child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.document_scanner_outlined, size: 80,
                      color: theme.colorScheme.outline),
                    const SizedBox(height: 16),
                    Text('Chup hoac chon anh trang sach',
                      style: theme.textTheme.bodyLarge),
                    const SizedBox(height: 8),
                    Text('OCR se tu dong nhan dien chu',
                      style: theme.textTheme.bodyMedium),
                  ],
                ))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _pages.length,
                  itemBuilder: (_, i) {
                    final page = _pages[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ExpansionTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(File(page.imagePath),
                            width: 48, height: 64, fit: BoxFit.cover),
                        ),
                        title: Text('Trang ${page.pageNumber}',
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(
                          page.text.length > 80
                            ? '${page.text.substring(0, 80)}...'
                            : page.text,
                          maxLines: 2, overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Anh goc
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(File(page.imagePath),
                                    width: double.infinity, fit: BoxFit.fitWidth)),
                                const SizedBox(height: 12),
                                const Divider(),
                                const SizedBox(height: 8),
                                // Text nhan dien
                                SelectableText(page.text,
                                  style: theme.textTheme.bodyMedium),
                                const SizedBox(height: 8),
                                // Nut xoa
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton.icon(
                                    onPressed: () => setState(() => _pages.removeAt(i)),
                                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                                    label: const Text('Xoa trang', style: TextStyle(color: Colors.red)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
          ),
        ],
      ),
    );
  }
}

class ScannedPage {
  final String imagePath;
  final String text;
  final int pageNumber;
  ScannedPage({required this.imagePath, required this.text, required this.pageNumber});
}
