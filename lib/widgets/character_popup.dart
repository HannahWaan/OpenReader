import 'package:flutter/material.dart';
import '../models/chaimager_character.dart';

class CharacterPopup extends StatelessWidget {
  final ChaimagerCharacter character;

  const CharacterPopup({super.key, required this.character});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Text(
                  character.name.isNotEmpty ? character.name[0].toUpperCase() : '?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(character.name,
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    if (character.role != null && character.role!.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _roleColor(character.role!).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(character.role!,
                            style: TextStyle(
                              fontSize: 12,
                              color: _roleColor(character.role!),
                              fontWeight: FontWeight.w600,
                            )),
                      ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Aliases
          if (character.aliases.isNotEmpty) ...[
            Text('Also known as',
                style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.outline)),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: character.aliases.map((alias) => Chip(
                label: Text(alias, style: const TextStyle(fontSize: 12)),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              )).toList(),
            ),
            const SizedBox(height: 12),
          ],

          // First appearance
          if (character.firstAppearPage > 0) ...[
            Row(
              children: [
                Icon(Icons.menu_book, size: 16, color: theme.colorScheme.outline),
                const SizedBox(width: 6),
                Text('First appears on page ${character.firstAppearPage}',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
              ],
            ),
            const SizedBox(height: 12),
          ],

          // Description
          if (character.description != null && character.description!.isNotEmpty) ...[
            Text('Description',
                style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.outline)),
            const SizedBox(height: 4),
            Text(character.description!, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 12),
          ],

          // Notes
          if (character.notes != null && character.notes!.isNotEmpty) ...[
            Text('Notes',
                style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.outline)),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(character.notes!, style: theme.textTheme.bodyMedium),
            ),
          ],

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Color _roleColor(String role) {
    switch (role.toLowerCase()) {
      case 'protagonist':
      case 'main':
        return Colors.blue;
      case 'antagonist':
      case 'villain':
        return Colors.red;
      case 'supporting':
      case 'side':
        return Colors.green;
      case 'mentor':
        return Colors.purple;
      default:
        return Colors.orange;
    }
  }
}
