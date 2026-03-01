import 'package:flutter/material.dart';
import '../../services/dictionary/dictionary_service.dart';
import '../../widgets/dictionary_popup.dart';

class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({super.key});

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  List<VocabWord> _words = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadVocabulary();
  }

  Future<void> _loadVocabulary() async {
    setState(() => _loading = true);
    final words = await DictionaryService.getVocabulary();
    setState(() {
      _words = words;
      _loading = false;
    });
  }

  Future<void> _deleteWord(int id) async {
    await DictionaryService.deleteVocab(id);
    await _loadVocabulary();
  }

  Future<void> _updateMastery(int id, int newLevel) async {
    await DictionaryService.updateMastery(id, newLevel);
    await _loadVocabulary();
  }

  Color _masteryColor(int level) {
    if (level <= 1) return Colors.red.shade300;
    if (level == 2) return Colors.orange.shade300;
    if (level == 3) return Colors.yellow.shade700;
    if (level == 4) return Colors.lightGreen;
    return Colors.green;
  }

  String _masteryLabel(int level) {
    const labels = ['New', 'Learning', 'Familiar', 'Good', 'Mastered'];
    return labels[level.clamp(0, 4)];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Vocabulary (${_words.length})'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadVocabulary,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _words.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.book_outlined, size: 64, color: theme.colorScheme.outline),
                      const SizedBox(height: 16),
                      Text('No saved words yet',
                        style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.outline)),
                      const SizedBox(height: 8),
                      Text('Look up words while reading to build\nyour vocabulary',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _words.length,
                  itemBuilder: (context, index) {
                    final vocab = _words[index];

                    return Dismissible(
                      key: ValueKey(vocab.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: Colors.red,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) => _deleteWord(vocab.id),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _masteryColor(vocab.masteryLevel),
                          radius: 18,
                          child: Text('${vocab.masteryLevel + 1}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                        title: Text(vocab.word,
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        subtitle: Text(vocab.definition ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_masteryLabel(vocab.masteryLevel),
                              style: TextStyle(color: _masteryColor(vocab.masteryLevel), fontSize: 11, fontWeight: FontWeight.w500)),
                            if (vocab.masteryLevel < 4)
                              IconButton(
                                icon: const Icon(Icons.arrow_upward, size: 18),
                                onPressed: () => _updateMastery(vocab.id, vocab.masteryLevel + 1),
                                tooltip: 'Level up',
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => const DictionaryPopup(initialWord: ''),
          );
        },
        child: const Icon(Icons.search),
      ),
    );
  }
}
