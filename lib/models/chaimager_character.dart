import 'package:equatable/equatable.dart';

class ChaimagerCharacter extends Equatable {
  final String id, bookId, name;
  final List<String> aliases;
  final String? imagePath, description, role;
  final int firstAppearPage;
  final DateTime createdAt;

  const ChaimagerCharacter({required this.id, required this.bookId, required this.name,
    this.aliases = const [], this.imagePath, this.description, this.role,
    this.firstAppearPage = 0, required this.createdAt});

  bool matchesKeyword(String keyword) {
    final lower = keyword.toLowerCase().trim();
    if (name.toLowerCase().contains(lower)) return true;
    return aliases.any((a) => a.toLowerCase().contains(lower));
  }

  Map<String, dynamic> toMap() => {
    'id': id, 'book_id': bookId, 'name': name, 'aliases': aliases.join('|'),
    'image_path': imagePath, 'description': description, 'role': role,
    'first_appear_page': firstAppearPage, 'created_at': createdAt.toIso8601String()};

  factory ChaimagerCharacter.fromMap(Map<String, dynamic> m) => ChaimagerCharacter(
    id: m['id'], bookId: m['book_id'], name: m['name'],
    aliases: (m['aliases'] as String?)?.split('|').where((a) => a.isNotEmpty).toList() ?? [],
    imagePath: m['image_path'], description: m['description'], role: m['role'],
    firstAppearPage: m['first_appear_page'] ?? 0,
    createdAt: DateTime.parse(m['created_at']));

  @override
  List<Object?> get props => [id];
}
