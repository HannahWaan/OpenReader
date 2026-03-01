import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../models/chaimager_character.dart';
import '../../services/database/local_db.dart';

// ─── PROVIDER ───
class ChaimagerNotifier extends StateNotifier<List<ChaimagerCharacter>> {
  ChaimagerNotifier() : super([]) { _load(); }

  Future<void> _load() async {
    final db = await LocalDatabase.instance;
    final rows = await db.query('chaimager_characters', orderBy: 'name ASC');
    state = rows.map((r) => ChaimagerCharacter.fromMap(r)).toList();
  }

  List<ChaimagerCharacter> forBook(String bookId) =>
      state.where((c) => c.bookId == bookId).toList();

  Future<void> addCharacter(ChaimagerCharacter c) async {
    final db = await LocalDatabase.instance;
    await db.insert('chaimager_characters', c.toMap());
    state = [...state, c];
  }

  Future<void> updateCharacter(ChaimagerCharacter c) async {
    final db = await LocalDatabase.instance;
    await db.update('chaimager_characters', c.toMap(),
        where: 'id = ?', whereArgs: [c.id]);
    state = state.map((x) => x.id == c.id ? c : x).toList();
  }

  Future<void> deleteCharacter(String id) async {
    final db = await LocalDatabase.instance;
    await db.delete('chaimager_characters', where: 'id = ?', whereArgs: [id]);
    state = state.where((c) => c.id != id).toList();
  }

  /// Tìm nhân vật match với keyword (để hiện popup khi tap trong reader)
  ChaimagerCharacter? findMatch(String bookId, String keyword) {
    final chars = forBook(bookId);
    for (final c in chars) {
      if (c.matchesKeyword(keyword)) return c;
    }
    return null;
  }
}

final chaimagerProvider =
    StateNotifierProvider<ChaimagerNotifier, List<ChaimagerCharacter>>(
  (ref) => ChaimagerNotifier(),
);

// ─── SCREEN ───
class ChaimagerScreen extends ConsumerWidget {
  const ChaimagerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final characters = ref.watch(chaimagerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Chaimager')),
      body: characters.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.people_outline, size: 80,
                      color: theme.colorScheme.outline),
                  const SizedBox(height: 16),
                  Text('Chưa có nhân vật nào',
                      style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text(
                    'Thêm nhân vật cho từng cuốn sách\n'
                    'để không bao giờ quên tên họ',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: characters.length,
              itemBuilder: (_, i) => _CharacterCard(character: characters[i]),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        child: const Icon(Icons.person_add),
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final aliasCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final roleCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Thêm nhân vật'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Tên nhân vật')),
              const SizedBox(height: 8),
              TextField(controller: aliasCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Biệt danh (cách bằng dấu phẩy)',
                    hintText: 'VD: Jon, Lord Snow, King in the North',
                  )),
              const SizedBox(height: 8),
              TextField(controller: roleCtrl,
                  decoration: const InputDecoration(labelText: 'Vai trò')),
              const SizedBox(height: 8),
              TextField(controller: descCtrl, maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Mô tả / Tiểu sử')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: const Text('Hủy')),
          FilledButton(
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty) return;
              final c = ChaimagerCharacter(
                id: const Uuid().v4(),
                bookId: 'global', // TODO: chọn sách cụ thể
                name: nameCtrl.text.trim(),
                aliases: aliasCtrl.text.split(',')
                    .map((a) => a.trim()).where((a) => a.isNotEmpty).toList(),
                description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
                role: roleCtrl.text.trim().isEmpty ? null : roleCtrl.text.trim(),
                createdAt: DateTime.now(),
              );
              ref.read(chaimagerProvider.notifier).addCharacter(c);
              Navigator.pop(context);
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }
}

// ─── CHARACTER CARD ───
class _CharacterCard extends StatelessWidget {
  final ChaimagerCharacter character;
  const _CharacterCard({required this.character});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Text(
            character.name[0].toUpperCase(),
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(character.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (character.role != null)
              Text(character.role!, style: theme.textTheme.bodySmall),
            if (character.aliases.isNotEmpty)
              Text('aka: ${character.aliases.join(", ")}',
                  style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic)),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // TODO: chi tiết nhân vật + edit
        },
      ),
    );
  }
}
