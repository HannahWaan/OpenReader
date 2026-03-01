import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/book.dart';
import '../services/database/local_db.dart';

class LibraryNotifier extends StateNotifier<List<Book>> {
  LibraryNotifier() : super([]) { _loadBooks(); }
  Future<void> _loadBooks() async {
    final db = await LocalDatabase.instance;
    final rows = await db.query('books', orderBy: 'updated_at DESC');
    state = rows.map((r) => Book.fromMap(r)).toList();
  }
  Future<void> addBook(Book book) async {
    final db = await LocalDatabase.instance;
    await db.insert('books', book.toMap());
    state = [book, ...state];
  }
  Future<void> updateBook(Book book) async {
    final db = await LocalDatabase.instance;
    await db.update('books', book.toMap(), where: 'id = ?', whereArgs: [book.id]);
    state = state.map((b) => b.id == book.id ? book : b).toList();
  }
  Future<void> deleteBook(String id) async {
    final db = await LocalDatabase.instance;
    await db.delete('books', where: 'id = ?', whereArgs: [id]);
    state = state.where((b) => b.id != id).toList();
  }
}

final libraryProvider = StateNotifierProvider<LibraryNotifier, List<Book>>((ref) => LibraryNotifier());
