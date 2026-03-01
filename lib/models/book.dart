import 'package:equatable/equatable.dart';

enum BookType { epub, pdf, scan }
enum ReadingStatus { unread, reading, finished }

class Book extends Equatable {
  final String id, title, filePath;
  final String? author, coverPath;
  final BookType type;
  final int totalPages, currentPage;
  final double progress;
  final ReadingStatus status;
  final List<String> tags;
  final int? rating;
  final DateTime createdAt, updatedAt;
  final bool isSynced;

  const Book({required this.id, required this.title, this.author, this.coverPath,
    required this.filePath, required this.type, this.totalPages = 0,
    this.currentPage = 0, this.progress = 0.0, this.status = ReadingStatus.unread,
    this.tags = const [], this.rating, required this.createdAt, required this.updatedAt,
    this.isSynced = false});

  Map<String, dynamic> toMap() => {
    'id': id, 'title': title, 'author': author, 'cover_path': coverPath,
    'file_path': filePath, 'type': type.name, 'total_pages': totalPages,
    'current_page': currentPage, 'progress': progress, 'status': status.name,
    'tags': tags.join(','), 'rating': rating,
    'created_at': createdAt.toIso8601String(), 'updated_at': updatedAt.toIso8601String(),
    'is_synced': isSynced ? 1 : 0};

  factory Book.fromMap(Map<String, dynamic> m) => Book(
    id: m['id'], title: m['title'], author: m['author'], coverPath: m['cover_path'],
    filePath: m['file_path'] ?? '', type: BookType.values.byName(m['type'] ?? 'pdf'),
    totalPages: m['total_pages'] ?? 0, currentPage: m['current_page'] ?? 0,
    progress: (m['progress'] ?? 0).toDouble(),
    status: ReadingStatus.values.byName(m['status'] ?? 'unread'),
    tags: m['tags'] is String ? (m['tags'] as String).split(',').where((t) => t.isNotEmpty).toList() : [],
    rating: m['rating'],
    createdAt: DateTime.parse(m['created_at'] ?? DateTime.now().toIso8601String()),
    updatedAt: DateTime.parse(m['updated_at'] ?? DateTime.now().toIso8601String()),
    isSynced: m['is_synced'] == 1 || m['is_synced'] == true);

  @override
  List<Object?> get props => [id];
}
