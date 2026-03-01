import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../models/highlight.dart';
import '../highlight/highlight_service.dart';

class ExportService {
  static Future<String> exportMarkdown() async {
    final highlights = await HighlightService.getAllHighlights();
    final buffer = StringBuffer();
    buffer.writeln('# OpenReader Highlights');
    buffer.writeln('Exported: ${DateTime.now().toIso8601String()}\n');

    // Group by book
    final grouped = <String, List<Highlight>>{};
    for (final h in highlights) {
      grouped.putIfAbsent(h.bookId, () => []).add(h);
    }

    for (final entry in grouped.entries) {
      buffer.writeln('## Book: ${entry.key}\n');
      for (final h in entry.value) {
        buffer.writeln('> ${h.text}');
        buffer.writeln('');
        if (h.note != null) buffer.writeln('**Note:** ${h.note}\n');
        buffer.writeln('*Page ${h.page} · ${h.createdAt.toLocal().toString().substring(0, 16)}*\n');
        buffer.writeln('---\n');
      }
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/highlights_export.md');
    await file.writeAsString(buffer.toString());
    return file.path;
  }

  static Future<String> exportCsv() async {
    final highlights = await HighlightService.getAllHighlights();
    final buffer = StringBuffer();
    buffer.writeln('book_id,text,note,page,color,created_at');

    for (final h in highlights) {
      final text = h.text.replaceAll('"', '""');
      final note = (h.note ?? '').replaceAll('"', '""');
      buffer.writeln('"${h.bookId}","$text","$note",${h.page},${h.color},"${h.createdAt.toIso8601String()}"');
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/highlights_export.csv');
    await file.writeAsString(buffer.toString());
    return file.path;
  }
}
