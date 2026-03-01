import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../models/chaimager_character.dart';
import '../../services/database/local_db.dart';

class ChaimagerNotifier extends StateNotifier<List<ChaimagerCharacter>> {
  ChaimagerNotifier() : super([]) { _load(); }
  Future<void> _load() async {
    final db = await LocalDatabase.instance;
    final rows = await db.query('chaimager_characters', orderBy: 'name ASC');
    state = rows.map((r) => ChaimagerCharacter.fromMap(r)).toList();
  }
  Future<void> addCharacter(ChaimagerCharacter c) async {
    final db = await LocalDatabase.instance;
    await db.insert('chaimager_characters', c.toMap());
    state = [...state, c];
  }
  Future<void> deleteCharacter(String id) async {
    final db = await LocalDatabase.instance;
    await db.delete('chaimager_characters', where: 'id = ?', whereArgs: [id]);
    state = state.where((c) => c.id != id).toList();
  }
  ChaimagerCharacter? findMatch(String bookId, String keyword) {
    for (final c in state.where((c) => c.bookId == bookId)) { if (c.matchesKeyword(keyword)) return c; }
    return null;
  }
}
final chaimagerProvider = StateNotifierProvider<ChaimagerNotifier, List<ChaimagerCharacter>>(
  (ref) => ChaimagerNotifier());

class ChaimagerScreen extends ConsumerWidget {
  const ChaimagerScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chars = ref.watch(chaimagerProvider);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Chaimager')),
      body: chars.isEmpty
        ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.people_outline, size: 80, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text('Chua co nhan vat nao', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('Them nhan vat cho tung cuon sach\nde khong bao gio quen ten ho',
              textAlign: TextAlign.center, style: theme.textTheme.bodyMedium)]))
        : ListView.builder(padding: const EdgeInsets.all(16), itemCount: chars.length,
            itemBuilder: (_, i) {
              final c = chars[i];
              return Card(margin: const EdgeInsets.only(bottom: 12), child: ListTile(
                leading: CircleAvatar(backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(c.name[0].toUpperCase(), style: TextStyle(
                    color: theme.colorScheme.primary, fontWeight: FontWeight.bold))),
                title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  if (c.role != null) Text(c.role!, style: theme.textTheme.bodySmall),
                  if (c.aliases.isNotEmpty) Text('aka: ${c.aliases.join(", ")}',
                    style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic))]),
                trailing: const Icon(Icons.chevron_right)));
            }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final nameC = TextEditingController(); final aliasC = TextEditingController();
          final descC = TextEditingController(); final roleC = TextEditingController();
          showDialog(context: context, builder: (_) => AlertDialog(
            title: const Text('Them nhan vat'),
            content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: nameC, decoration: const InputDecoration(labelText: 'Ten nhan vat')),
              const SizedBox(height: 8),
              TextField(controller: aliasC, decoration: const InputDecoration(
                labelText: 'Biet danh (phay)', hintText: 'VD: Jon, Lord Snow')),
              const SizedBox(height: 8),
              TextField(controller: roleC, decoration: const InputDecoration(labelText: 'Vai tro')),
              const SizedBox(height: 8),
              TextField(controller: descC, maxLines: 3, decoration: const InputDecoration(labelText: 'Mo ta'))])),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Huy')),
              FilledButton(onPressed: () {
                if (nameC.text.trim().isEmpty) return;
                ref.read(chaimagerProvider.notifier).addCharacter(ChaimagerCharacter(
                  id: const Uuid().v4(), bookId: 'global', name: nameC.text.trim(),
                  aliases: aliasC.text.split(',').map((a) => a.trim()).where((a) => a.isNotEmpty).toList(),
                  description: descC.text.trim().isEmpty ? null : descC.text.trim(),
                  role: roleC.text.trim().isEmpty ? null : roleC.text.trim(),
                  createdAt: DateTime.now()));
                Navigator.pop(context);
              }, child: const Text('Them'))]));
        },
        child: const Icon(Icons.person_add)));
  }
}
