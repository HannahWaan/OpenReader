import '../../models/highlight.dart';
import '../database/local_db.dart';

class HighlightService {
  static Future<List<Highlight>> getHighlights(String bookId) async {
    final db = await LocalDatabase.instance;
    final rows = await db.query('highlights',
        where: 'book_id = ?', whereArgs: [bookId], orderBy: 'page ASC');
    return rows.map((r) => Highlight.fromMap(r)).toList();
  }

  static Future<List<Highlight>> getAllHighlights() async {
    final db = await LocalDatabase.instance;
    final rows = await db.query('highlights', orderBy: 'created_at DESC');
    return rows.map((r) => Highlight.fromMap(r)).toList();
  }

  static Future<void> addHighlight(Highlight h) async {
    final db = await LocalDatabase.instance;
    await db.insert('highlights', h.toMap());
  }

  static Future<void> updateHighlight(Highlight h) async {
    final db = await LocalDatabase.instance;
    await db.update('highlights', h.toMap(), where: 'id = ?', whereArgs: [h.id]);
  }

  static Future<void> deleteHighlight(String id) async {
    final db = await LocalDatabase.instance;
    await db.delete('highlights', where: 'id = ?', whereArgs: [id]);
  }
}
