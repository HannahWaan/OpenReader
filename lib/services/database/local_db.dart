import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabase {
  static Database? _db;
  static Future<Database> get instance async { _db ??= await _initDb(); return _db!; }

  static Future<Database> _initDb() async {
    final dbPath = join(await getDatabasesPath(), 'open_reader.db');
    return openDatabase(dbPath, version: 1, onCreate: (db, v) async {
      await db.execute('''CREATE TABLE books (
        id TEXT PRIMARY KEY, title TEXT NOT NULL, author TEXT, cover_path TEXT,
        file_path TEXT NOT NULL, type TEXT NOT NULL DEFAULT 'pdf',
        total_pages INTEGER DEFAULT 0, current_page INTEGER DEFAULT 0,
        progress REAL DEFAULT 0.0, status TEXT DEFAULT 'unread',
        tags TEXT DEFAULT '', rating INTEGER,
        created_at TEXT NOT NULL, updated_at TEXT NOT NULL, is_synced INTEGER DEFAULT 0)''');
      await db.execute('''CREATE TABLE highlights (
        id TEXT PRIMARY KEY, book_id TEXT NOT NULL, text TEXT NOT NULL,
        note TEXT, color TEXT DEFAULT '#FFF176', page_number INTEGER DEFAULT 0,
        chapter TEXT, created_at TEXT NOT NULL,
        FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE CASCADE)''');
      await db.execute('''CREATE TABLE bookmarks (
        id TEXT PRIMARY KEY, book_id TEXT NOT NULL, page_number INTEGER NOT NULL,
        title TEXT, created_at TEXT NOT NULL,
        FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE CASCADE)''');
      await db.execute('''CREATE TABLE chaimager_characters (
        id TEXT PRIMARY KEY, book_id TEXT NOT NULL, name TEXT NOT NULL,
        aliases TEXT DEFAULT '', image_path TEXT, description TEXT, role TEXT,
        first_appear_page INTEGER DEFAULT 0, created_at TEXT NOT NULL,
        FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE CASCADE)''');
      await db.execute('''CREATE TABLE vocabulary (
        id TEXT PRIMARY KEY, word TEXT NOT NULL, definition TEXT,
        context_sentence TEXT, book_id TEXT, mastery_level INTEGER DEFAULT 0,
        next_review_at TEXT, review_count INTEGER DEFAULT 0, created_at TEXT NOT NULL)''');
      await db.execute('''CREATE TABLE reading_sessions (
        id TEXT PRIMARY KEY, book_id TEXT NOT NULL, started_at TEXT NOT NULL,
        ended_at TEXT, pages_read INTEGER DEFAULT 0, duration_seconds INTEGER DEFAULT 0,
        FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE CASCADE)''');
    });
  }
}
