import 'package:equatable/equatable.dart';

class Highlight extends Equatable {
  final String id;
  final String bookId;
  final String text;
  final String? note;
  final String color;       // hex
  final int pageNumber;
  final String? chapter;
  final DateTime createdAt;

  const Highlight({
    required this.id, required this.bookId, required this.text,
    this.note, this.color = '#FFF176', this.pageNumber = 0,
    this.chapter, required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id, 'book_id': bookId, 'text': text, 'note': note,
    'color': color, 'page_number': pageNumber, 'chapter': chapter,
    'created_at': createdAt.toIso8601String(),
  };

  factory Highlight.fromMap(Map<String, dynamic> m) => Highlight(
    id: m['id'], bookId: m['book_id'], text: m['text'],
    note: m['note'], color: m['color'] ?? '#FFF176',
    pageNumber: m['page_number'] ?? 0, chapter: m['chapter'],
    createdAt: DateTime.parse(m['created_at']),
  );

  @override
  List<Object?> get props => [id];
}
