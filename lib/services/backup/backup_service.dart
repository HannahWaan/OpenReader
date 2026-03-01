import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../database/local_db.dart';

class BackupService {
  static Future<String> createBackup() async {
    final db = await LocalDatabase.instance;

    final books = await db.query('books');
    final highlights = await db.query('highlights');
    final characters = await db.query('chaimager_characters');
    final vocab = await db.query('looked_up_words');
    final sessions = await db.query('reading_sessions');

    final backup = {
      'version': 1,
      'created_at': DateTime.now().toIso8601String(),
      'books': books,
      'highlights': highlights,
      'chaimager_characters': characters,
      'vocabulary': vocab,
      'reading_sessions': sessions,
    };

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/openreader_backup.json');
    await file.writeAsString(jsonEncode(backup));
    return file.path;
  }

  static Future<int> restoreBackup(String filePath) async {
    final file = File(filePath);
    if (!file.existsSync()) throw Exception('Backup file not found');

    final content = await file.readAsString();
    final data = jsonDecode(content) as Map<String, dynamic>;
    final db = await LocalDatabase.instance;

    int count = 0;

    if (data['books'] != null) {
      for (final row in data['books']) {
        try {
          await db.insert('books', Map<String, dynamic>.from(row));
          count++;
        } catch (_) {}
      }
    }
    if (data['highlights'] != null) {
      for (final row in data['highlights']) {
        try {
          await db.insert('highlights', Map<String, dynamic>.from(row));
          count++;
        } catch (_) {}
      }
    }
    if (data['chaimager_characters'] != null) {
      for (final row in data['chaimager_characters']) {
        try {
          await db.insert('chaimager_characters', Map<String, dynamic>.from(row));
          count++;
        } catch (_) {}
      }
    }
    if (data['vocabulary'] != null) {
      for (final row in data['vocabulary']) {
        try {
          await db.insert('looked_up_words', Map<String, dynamic>.from(row));
          count++;
        } catch (_) {}
      }
    }

    return count;
  }
}
