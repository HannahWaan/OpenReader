import 'package:flutter/material.dart';
import '../../models/highlight.dart';
import '../../services/highlight/highlight_service.dart';

class HighlightsScreen extends StatefulWidget {
  const HighlightsScreen({super.key});

  @override
  State<HighlightsScreen> createState() => _HighlightsScreenState();
}

class _HighlightsScreenState extends State<HighlightsScreen> {
  List<Highlight> _highlights = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final hl = await HighlightService.getAllHighlights();
    setState(() { _highlights = hl; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Highlights (${_highlights.length})'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _highlights.isEmpty
              ? Center(child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.highlight_off, size: 64, color: theme.colorScheme.outline),
                    const SizedBox(height: 16),
                    Text('No highlights yet', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.outline)),
                    const SizedBox(height: 8),
                    Text('Select text while reading to highlight', textAlign: TextAlign.center, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline)),
                  ],
                ))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _highlights.length,
                  itemBuilder: (_, i) {
                    final h = _highlights[i];
                    return Dismissible(
                      key: ValueKey(h.id),
                      direction: DismissDirection.endToStart,
                      background: Container(alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), color: Colors.red, child: const Icon(Icons.delete, color: Colors.white)),
                      onDismissed: (_) async {
                        await HighlightService.deleteHighlight(h.id);
                        await _load();
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Color(h.color).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border(left: BorderSide(color: Color(h.color), width: 3)),
                                ),
                                child: Text(h.text, style: theme.textTheme.bodyMedium),
                              ),
                              const SizedBox(height: 8),
                              Row(children: [
                                Icon(Icons.menu_book, size: 14, color: theme.colorScheme.outline),
                                const SizedBox(width: 4),
                                Text('Page ${h.page}', style: TextStyle(fontSize: 12, color: theme.colorScheme.outline)),
                                if (h.note != null) ...[
                                  const SizedBox(width: 12),
                                  Icon(Icons.note, size: 14, color: theme.colorScheme.outline),
                                  const SizedBox(width: 4),
                                  Expanded(child: Text(h.note!, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: theme.colorScheme.outline))),
                                ],
                              ]),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
