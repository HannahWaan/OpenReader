import 'package:equatable/equatable.dart';

class ChaimagerCharacter extends Equatable {
  final String id;
  final String bookId;
  final String name;
  final List<String> aliases;
  final String? role;
  final String? description;
  final String? notes;
  final int firstAppearPage;
  final String? imageUrl;
  final DateTime createdAt;

  const ChaimagerCharacter({
    required this.id,
    required this.bookId,
    required this.name,
    this.aliases = const [],
    this.role,
    this.description,
    this.notes,
    this.firstAppearPage = 0,
    this.imageUrl,
    required this.createdAt,
  });

  /// Check if a text contains this character's name or aliases
  bool matchesText(String text) {
    final lower = text.toLowerCase();
    if (lower.contains(name.toLowerCase())) return true;
    for (final alias in aliases) {
      if (alias.isNotEmpty && lower.contains(alias.toLowerCase())) return true;
    }
    return false;
  }

  /// Find all positions of character name/aliases in text
  List<CharacterMatch> findInText(String text) {
    final matches = <CharacterMatch>[];
    final lower = text.toLowerCase();

    // Search for main name
    _findAllOccurrences(lower, name.toLowerCase(), name, matches);

    // Search for aliases
    for (final alias in aliases) {
      if (alias.isNotEmpty) {
        _findAllOccurrences(lower, alias.toLowerCase(), alias, matches);
      }
    }

    // Sort by position
    matches.sort((a, b) => a.start.compareTo(b.start));
    return matches;
  }

  void _findAllOccurrences(String text, String pattern, String original, List<CharacterMatch> matches) {
    int start = 0;
    while (true) {
      final index = text.indexOf(pattern, start);
      if (index == -1) break;
      matches.add(CharacterMatch(
        character: this,
        matchedText: original,
        start: index,
        end: index + pattern.length,
      ));
      start = index + 1;
    }
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'book_id': bookId,
    'name': name,
    'aliases': aliases.join(','),
    'role': role,
    'description': description,
    'notes': notes,
    'first_appear_page': firstAppearPage,
    'image_url': imageUrl,
    'created_at': createdAt.toIso8601String(),
  };

  factory ChaimagerCharacter.fromMap(Map<String, dynamic> m) => ChaimagerCharacter(
    id: m['id'],
    bookId: m['book_id'] ?? '',
    name: m['name'],
    aliases: (m['aliases'] as String?)?.split(',').where((s) => s.isNotEmpty).toList() ?? [],
    role: m['role'],
    description: m['description'],
    notes: m['notes'],
    firstAppearPage: m['first_appear_page'] ?? 0,
    imageUrl: m['image_url'],
    createdAt: DateTime.parse(m['created_at']),
  );

  ChaimagerCharacter copyWith({
    String? name,
    List<String>? aliases,
    String? role,
    String? description,
    String? notes,
    int? firstAppearPage,
    String? imageUrl,
  }) => ChaimagerCharacter(
    id: id,
    bookId: bookId,
    name: name ?? this.name,
    aliases: aliases ?? this.aliases,
    role: role ?? this.role,
    description: description ?? this.description,
    notes: notes ?? this.notes,
    firstAppearPage: firstAppearPage ?? this.firstAppearPage,
    imageUrl: imageUrl ?? this.imageUrl,
    createdAt: createdAt,
  );

  @override
  List<Object?> get props => [id];
}

class CharacterMatch {
  final ChaimagerCharacter character;
  final String matchedText;
  final int start;
  final int end;

  const CharacterMatch({
    required this.character,
    required this.matchedText,
    required this.start,
    required this.end,
  });
}
