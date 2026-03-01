import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DictionaryService {
  static Database? _db;

  static Future<Database> get _instance async {
    _db ??= await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final dbPath = join(await getDatabasesPath(), 'dictionary.db');
    return openDatabase(dbPath, version: 1, onCreate: (db, v) async {
      // Bang tu dien (nguoi dung co the tu them tu)
      await db.execute('''CREATE TABLE dict_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        word TEXT NOT NULL COLLATE NOCASE,
        definition TEXT NOT NULL,
        phonetic TEXT,
        part_of_speech TEXT,
        example TEXT)''');

      // Index de tra nhanh
      await db.execute('CREATE INDEX idx_word ON dict_entries(word)');

      // Bang tu da tra (vocabulary builder)
      await db.execute('''CREATE TABLE looked_up_words (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        word TEXT NOT NULL,
        definition TEXT,
        context_sentence TEXT,
        book_id TEXT,
        book_title TEXT,
        mastery_level INTEGER DEFAULT 0,
        review_count INTEGER DEFAULT 0,
        next_review_at TEXT,
        created_at TEXT NOT NULL)''');

      // Them 1 so tu mau de test
      await _insertSampleWords(db);
    });
  }

  static Future<void> _insertSampleWords(Database db) async {
    final samples = [
      {'word': 'serendipity', 'definition': 'Su tinh co may man; kha nang tim thay dieu tot dep mot cach bat ngo', 'phonetic': '/ˌserənˈdɪpɪti/', 'part_of_speech': 'noun', 'example': 'Finding that book was pure serendipity.'},
      {'word': 'ephemeral', 'definition': 'Chop nhoang, phu du, ngan ngui', 'phonetic': '/ɪˈfemərəl/', 'part_of_speech': 'adjective', 'example': 'The ephemeral beauty of cherry blossoms.'},
      {'word': 'ubiquitous', 'definition': 'Co mat o khap noi, pho bien', 'phonetic': '/juːˈbɪkwɪtəs/', 'part_of_speech': 'adjective', 'example': 'Smartphones have become ubiquitous.'},
      {'word': 'eloquent', 'definition': 'Hung bien, co tai an noi, tran day cam xuc', 'phonetic': '/ˈeləkwənt/', 'part_of_speech': 'adjective', 'example': 'She gave an eloquent speech.'},
      {'word': 'resilient', 'definition': 'Co kha nang phuc hoi, ben bi, doi hoi', 'phonetic': '/rɪˈzɪliənt/', 'part_of_speech': 'adjective', 'example': 'Children are remarkably resilient.'},
      {'word': 'pragmatic', 'definition': 'Thuc te, thuc dung', 'phonetic': '/præɡˈmætɪk/', 'part_of_speech': 'adjective', 'example': 'We need a pragmatic approach to this problem.'},
      {'word': 'benevolent', 'definition': 'Nhan tu, tot bung, hay lam viec thien', 'phonetic': '/bəˈnevələnt/', 'part_of_speech': 'adjective', 'example': 'A benevolent smile crossed her face.'},
      {'word': 'meticulous', 'definition': 'Ti mi, can than, chu dao', 'phonetic': '/məˈtɪkjələs/', 'part_of_speech': 'adjective', 'example': 'He is meticulous about his work.'},
      {'word': 'candid', 'definition': 'Than that, bo bach, khong giau giem', 'phonetic': '/ˈkændɪd/', 'part_of_speech': 'adjective', 'example': 'I appreciate your candid feedback.'},
      {'word': 'profound', 'definition': 'Sau sac, tham thuy, uyên thâm', 'phonetic': '/prəˈfaʊnd/', 'part_of_speech': 'adjective', 'example': 'The book had a profound impact on me.'},
    ];
    for (final s in samples) {
      await db.insert('dict_entries', s);
    }
  }

  /// Tra tu - exact match
  static Future<DictEntry?> lookup(String word) async {
    final db = await _instance;
    final rows = await db.query('dict_entries',
      where: 'word = ? COLLATE NOCASE', whereArgs: [word.trim()], limit: 1);
    if (rows.isEmpty) return null;
    return DictEntry.fromMap(rows.first);
  }

  /// Tra tu - prefix search (goi y)
  static Future<List<DictEntry>> search(String query) async {
    final db = await _instance;
    final rows = await db.query('dict_entries',
      where: 'word LIKE ? COLLATE NOCASE', whereArgs: ['${query.trim()}%'], limit: 20);
    return rows.map((r) => DictEntry.fromMap(r)).toList();
  }

  /// Them tu moi vao tu dien
  static Future<void> addEntry(DictEntry entry) async {
    final db = await _instance;
    await db.insert('dict_entries', {
      'word': entry.word, 'definition': entry.definition,
      'phonetic': entry.phonetic, 'part_of_speech': entry.partOfSpeech,
      'example': entry.example});
  }

  /// Luu tu da tra vao vocabulary
  static Future<void> saveToVocabulary({
    required String word, required String definition,
    String? contextSentence, String? bookId, String? bookTitle}) async {
    final db = await _instance;
    // Kiem tra trung
    final existing = await db.query('looked_up_words',
      where: 'word = ? COLLATE NOCASE', whereArgs: [word.trim()], limit: 1);
    if (existing.isNotEmpty) return; // Da co roi

    await db.insert('looked_up_words', {
      'word': word.trim(), 'definition': definition,
      'context_sentence': contextSentence, 'book_id': bookId,
      'book_title': bookTitle, 'mastery_level': 0, 'review_count': 0,
      'created_at': DateTime.now().toIso8601String()});
  }

  /// Lay danh sach vocabulary
  static Future<List<VocabWord>> getVocabulary() async {
    final db = await _instance;
    final rows = await db.query('looked_up_words', orderBy: 'created_at DESC');
    return rows.map((r) => VocabWord.fromMap(r)).toList();
  }

  /// Xoa vocabulary
  static Future<void> deleteVocab(int id) async {
    final db = await _instance;
    await db.delete('looked_up_words', where: 'id = ?', whereArgs: [id]);
  }

  /// Cap nhat mastery level
  static Future<void> updateMastery(int id, int level) async {
    final db = await _instance;
    await db.update('looked_up_words', {'mastery_level': level, 'review_count': level},
      where: 'id = ?', whereArgs: [id]);
  }
}

class DictEntry {
  final int? id;
  final String word, definition;
  final String? phonetic, partOfSpeech, example;

  DictEntry({this.id, required this.word, required this.definition,
    this.phonetic, this.partOfSpeech, this.example});

  factory DictEntry.fromMap(Map<String, dynamic> m) => DictEntry(
    id: m['id'], word: m['word'], definition: m['definition'],
    phonetic: m['phonetic'], partOfSpeech: m['part_of_speech'], example: m['example']);
}

class VocabWord {
  final int id;
  final String word;
  final String? definition, contextSentence, bookId, bookTitle;
  final int masteryLevel, reviewCount;
  final DateTime createdAt;

  VocabWord({required this.id, required this.word, this.definition,
    this.contextSentence, this.bookId, this.bookTitle,
    this.masteryLevel = 0, this.reviewCount = 0, required this.createdAt});

  factory VocabWord.fromMap(Map<String, dynamic> m) => VocabWord(
    id: m['id'], word: m['word'], definition: m['definition'],
    contextSentence: m['context_sentence'], bookId: m['book_id'],
    bookTitle: m['book_title'], masteryLevel: m['mastery_level'] ?? 0,
    reviewCount: m['review_count'] ?? 0,
    createdAt: DateTime.parse(m['created_at']));
}
