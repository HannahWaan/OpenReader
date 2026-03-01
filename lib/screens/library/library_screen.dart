import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import '../../models/book.dart';
import '../../providers/library_provider.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final books = ref.watch(libraryProvider);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('OpenReader'), actions: [
        IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        IconButton(icon: const Icon(Icons.document_scanner_outlined),
          tooltip: 'Scan sach', onPressed: () => context.push('/scanner')),
      ]),
      body: books.isEmpty
        ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.menu_book_rounded, size: 80, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text('Chua co sach nao', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('Nhan + de them PDF, EPUB\nhoac quet sach giay',
              textAlign: TextAlign.center, style: theme.textTheme.bodyMedium)]))
        : GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, childAspectRatio: 0.55, crossAxisSpacing: 12, mainAxisSpacing: 16),
            itemCount: books.length,
            itemBuilder: (_, i) {
              final book = books[i];
              return GestureDetector(
                onTap: () => context.push('/reader/${book.id}'),
                onLongPress: () => showDialog(context: context, builder: (_) => AlertDialog(
                  title: const Text('Xoa sach?'),
                  content: Text('Ban co chac muon xoa "${book.title}"?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Huy')),
                    TextButton(onPressed: () { ref.read(libraryProvider.notifier).deleteBook(book.id); Navigator.pop(context); },
                      child: const Text('Xoa', style: TextStyle(color: Colors.red)))])),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: Container(
                    decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 2))]),
                    child: Center(child: Padding(padding: const EdgeInsets.all(8),
                      child: Text(book.title, textAlign: TextAlign.center, maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)))))),
                  const SizedBox(height: 6),
                  Text(book.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                  if (book.progress > 0) Padding(padding: const EdgeInsets.only(top: 4),
                    child: LinearProgressIndicator(value: book.progress, minHeight: 2,
                      borderRadius: BorderRadius.circular(1)))]));
            }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await FilePicker.platform.pickFiles(
            type: FileType.custom, allowedExtensions: ['pdf', 'epub']);
          if (result != null && result.files.isNotEmpty) {
            final file = result.files.first;
            final now = DateTime.now();
            ref.read(libraryProvider.notifier).addBook(Book(
              id: const Uuid().v4(),
              title: file.name.replaceAll(RegExp(r'\.(pdf|epub)$'), ''),
              filePath: file.path!, type: file.extension == 'epub' ? BookType.epub : BookType.pdf,
              createdAt: now, updatedAt: now));
          }
        },
        icon: const Icon(Icons.add), label: const Text('Them sach')));
  }
}
