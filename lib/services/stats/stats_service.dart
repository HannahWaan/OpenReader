import '../database/local_db.dart';

class StatsService {
  static Future<void> logSession(String bookId, int pagesRead, int durationSeconds) async {
    final db = await LocalDatabase.instance;
    await db.insert('reading_sessions', {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'book_id': bookId,
      'pages_read': pagesRead,
      'duration_seconds': durationSeconds,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<Map<String, dynamic>> getStats() async {
    final db = await LocalDatabase.instance;

    final totalBooks = (await db.query('books')).length;
    final finishedBooks = (await db.query('books', where: 'status = ?', whereArgs: ['finished'])).length;
    final sessions = await db.query('reading_sessions');

    int totalPages = 0;
    int totalSeconds = 0;
    for (final s in sessions) {
      totalPages += (s['pages_read'] as int?) ?? 0;
      totalSeconds += (s['duration_seconds'] as int?) ?? 0;
    }

    final highlights = (await db.query('highlights')).length;
    final vocab = (await db.query('looked_up_words')).length;

    // Sessions per day (last 7 days)
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final recentSessions = await db.query('reading_sessions',
        where: 'created_at >= ?', whereArgs: [weekAgo.toIso8601String()]);

    final dailyMinutes = <String, int>{};
    for (var i = 0; i < 7; i++) {
      final day = now.subtract(Duration(days: i));
      final key = '${day.month}/${day.day}';
      dailyMinutes[key] = 0;
    }
    for (final s in recentSessions) {
      final date = DateTime.parse(s['created_at'] as String);
      final key = '${date.month}/${date.day}';
      dailyMinutes[key] = (dailyMinutes[key] ?? 0) + ((s['duration_seconds'] as int?) ?? 0) ~/ 60;
    }

    return {
      'total_books': totalBooks,
      'finished_books': finishedBooks,
      'total_pages': totalPages,
      'total_hours': (totalSeconds / 3600).toStringAsFixed(1),
      'total_minutes': totalSeconds ~/ 60,
      'total_highlights': highlights,
      'total_vocab': vocab,
      'total_sessions': sessions.length,
      'daily_minutes': dailyMinutes,
    };
  }
}
