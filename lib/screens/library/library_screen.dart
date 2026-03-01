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
      appBar: AppBar(
        title: const Text('OpenReader'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: search delegate
            },
          ),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'scan') context.push('/scanner');
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'scan', child: Text('Scan sách giấy')),
              const PopupMenuItem(value: 'sort', child: Text('Sắp xếp')),
            ],
          ),
        ],
      ),

      body: books.isEmpty
          ? _EmptyLibrary()
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.55,
                crossAxisSpacing: 12,
                mainAxisSpacing: 16,
              ),
              itemCount: books.length,
              itemBuilder: (_, i) => _BookCard(
                book: books[i],
                onTap: () => context.push('/reader/${books[i].id}'),
              ),
            ),

      // FAB: Thêm sách
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _importBook(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Thêm sách'),
      ),
    );
  }

  Future<void> _importBook(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'epub'],
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      final now = DateTime.now();
      final book = Book(
        id: const Uuid().v4(),
        title: file.name.replaceAll(RegExp(r'\.(pdf|epub)$'), ''),
        filePath: file.path!,
        type: file.extension == 'epub' ? BookType.epub : BookType.pdf,
        createdAt: now,
        updatedAt: now,
      );
      ref.read(libraryProvider.notifier).addBook(book);
    }
  }
}

// ─── EMPTY STATE ───
class _EmptyLibrary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.menu_book_rounded, size: 80,
              color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 16),
          Text('Chưa có sách nào',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text('Nhấn + để thêm PDF, EPUB\nhoặc quét sách giấy',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

// ─── BOOK CARD ───
class _BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;
  const _BookCard({required this.book, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8, offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    book.title,
                    textAlign: TextAlign.center,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          // Title
          Text(book.title, maxLines: 2, overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
          // Progress
          if (book.progress > 0)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: LinearProgressIndicator(
                value: book.progress,
                minHeight: 2,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
        ],
      ),
    );
  }
}
