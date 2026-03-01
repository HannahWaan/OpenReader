import 'package:equatable/equatable.dart';

/// Chaimager: Mỗi nhân vật có ảnh đại diện, tiểu sử,
/// và danh sách tên/biệt danh để nhận diện trong sách.
class ChaimagerCharacter extends Equatable {
  final String id;
  final String bookId;
  final String name;
  final List<String> aliases;     // Biệt danh, tên khác
  final String? imagePath;        // Ảnh đại diện
  final String? description;      // Tiểu sử / ghi chú
  final String? role;             // Protagonist, Antagonist, Side...
  final int firstAppearPage;      // Xuất hiện lần đầu trang mấy
  final DateTime createdAt;

  const ChaimagerCharacter({
    required this.id,
    required this.bookId,
    required this.name,
    this.aliases = const [],
    this.imagePath,
    this.description,
    this.role,
    this.firstAppearPage = 0,
    required this.createdAt,
  });

  /// Kiểm tra xem 1 từ/cụm từ có match với nhân vật này không
  bool matchesKeyword(String keyword) {
    final lower = keyword.toLowerCase().trim();
    if (name.toLowerCase().contains(lower)) return true;
    return aliases.any((a) => a.toLowerCase().contains(lower));
  }

  Map<String, dynamic> toMap() => {
    'id': id, 'book_id': bookId, 'name': name,
    'aliases': aliases.join('|'), 'image_path': imagePath,
    'description': description, 'role': role,
    'first_appear_page': firstAppearPage,
    'created_at': createdAt.toIso8601String(),
  };

  factory ChaimagerCharacter.fromMap(Map<String, dynamic> m) =>
      ChaimagerCharacter(
        id: m['id'], bookId: m['book_id'], name: m['name'],
        aliases: (m['aliases'] as String?)?.split('|')
            .where((a) => a.isNotEmpty).toList() ?? [],
        imagePath: m['image_path'], description: m['description'],
        role: m['role'], firstAppearPage: m['first_appear_page'] ?? 0,
        createdAt: DateTime.parse(m['created_at']),
      );

  @override
  List<Object?> get props => [id];
}
