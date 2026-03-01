class Highlight {
  final String id;
  final String bookId;
  final String text;
  final String? note;
  final int page;
  final int color;
  final DateTime createdAt;

  const Highlight({
    required this.id,
    required this.bookId,
    required this.text,
    this.note,
    required this.page,
    this.color = 0xFFFFF176,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'book_id': bookId,
    'text': text,
    'note': note,
    'page': page,
    'color': color,
    'created_at': createdAt.toIso8601String(),
  };

  factory Highlight.fromMap(Map<String, dynamic> m) => Highlight(
    id: m['id'].toString(),
    bookId: m['book_id'] ?? '',
    text: m['text'] ?? '',
    note: m['note'],
    page: m['page'] ?? 0,
    color: m['color'] ?? 0xFFFFF176,
    createdAt: DateTime.parse(m['created_at']),
  );
}
