import '../../models/chaimager_character.dart';
import '../database/local_db.dart';

class ChaimagerService {
  static Future<List<ChaimagerCharacter>> getCharacters(String bookId) async {
    final db = await LocalDatabase.instance;
    final rows = await db.query(
      'chaimager_characters',
      where: 'book_id = ?',
      whereArgs: [bookId],
      orderBy: 'first_appear_page ASC',
    );
    return rows.map((r) => ChaimagerCharacter.fromMap(r)).toList();
  }

  static Future<List<ChaimagerCharacter>> getAllCharacters() async {
    final db = await LocalDatabase.instance;
    final rows = await db.query('chaimager_characters', orderBy: 'name ASC');
    return rows.map((r) => ChaimagerCharacter.fromMap(r)).toList();
  }

  static Future<void> addCharacter(ChaimagerCharacter char) async {
    final db = await LocalDatabase.instance;
    await db.insert('chaimager_characters', char.toMap());
  }

  static Future<void> updateCharacter(ChaimagerCharacter char) async {
    final db = await LocalDatabase.instance;
    await db.update('chaimager_characters', char.toMap(),
        where: 'id = ?', whereArgs: [char.id]);
  }

  static Future<void> deleteCharacter(String id) async {
    final db = await LocalDatabase.instance;
    await db.delete('chaimager_characters', where: 'id = ?', whereArgs: [id]);
  }

  /// Detect all characters that appear in a given text
  static List<CharacterMatch> detectInText(
      String text, List<ChaimagerCharacter> characters) {
    final allMatches = <CharacterMatch>[];
    for (final char in characters) {
      allMatches.addAll(char.findInText(text));
    }
    allMatches.sort((a, b) => a.start.compareTo(b.start));
    return allMatches;
  }
}
