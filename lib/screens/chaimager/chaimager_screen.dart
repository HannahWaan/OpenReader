import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/chaimager_character.dart';
import '../../services/chaimager/chaimager_service.dart';
import '../../widgets/character_popup.dart';

class ChaimagerScreen extends StatefulWidget {
  const ChaimagerScreen({super.key});

  @override
  State<ChaimagerScreen> createState() => _ChaimagerScreenState();
}

class _ChaimagerScreenState extends State<ChaimagerScreen> {
  List<ChaimagerCharacter> _characters = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCharacters();
  }

  Future<void> _loadCharacters() async {
    setState(() => _loading = true);
    final chars = await ChaimagerService.getAllCharacters();
    setState(() {
      _characters = chars;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chaimager'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadCharacters),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _characters.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.people_outline, size: 64, color: theme.colorScheme.outline),
                      const SizedBox(height: 16),
                      Text('No characters yet', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.outline)),
                      const SizedBox(height: 8),
                      Text('Add characters to track them\nacross your books',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _characters.length,
                  itemBuilder: (context, index) {
                    final char = _characters[index];
                    return Dismissible(
                      key: ValueKey(char.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: Colors.red,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) async {
                        await ChaimagerService.deleteCharacter(char.id);
                        await _loadCharacters();
                      },
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.primaryContainer,
                          child: Text(char.name[0].toUpperCase(),
                              style: TextStyle(color: theme.colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold)),
                        ),
                        title: Text(char.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(
                          [
                            if (char.role != null) char.role!,
                            if (char.aliases.isNotEmpty) 'aka: ${char.aliases.join(", ")}',
                          ].join(' · '),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (_) => CharacterPopup(character: char),
                          );
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.person_add),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final aliasCtrl = TextEditingController();
    final roleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    final pageCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Character'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name *', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: aliasCtrl, decoration: const InputDecoration(labelText: 'Aliases (comma separated)', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: roleCtrl, decoration: const InputDecoration(labelText: 'Role (protagonist, antagonist...)', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()), maxLines: 2),
              const SizedBox(height: 10),
              TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'Notes', border: OutlineInputBorder()), maxLines: 2),
              const SizedBox(height: 10),
              TextField(controller: pageCtrl, decoration: const InputDecoration(labelText: 'First appear page', border: OutlineInputBorder()), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty) return;
              final char = ChaimagerCharacter(
                id: const Uuid().v4(),
                bookId: 'general',
                name: nameCtrl.text.trim(),
                aliases: aliasCtrl.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
                role: roleCtrl.text.trim().isEmpty ? null : roleCtrl.text.trim(),
                description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
                notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
                firstAppearPage: int.tryParse(pageCtrl.text) ?? 0,
                createdAt: DateTime.now(),
              );
              await ChaimagerService.addCharacter(char);
              if (ctx.mounted) Navigator.pop(ctx);
              await _loadCharacters();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
