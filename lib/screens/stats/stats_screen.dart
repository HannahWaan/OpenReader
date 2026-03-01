import 'package:flutter/material.dart';
import '../../services/stats/stats_service.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  Map<String, dynamic>? _stats;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final stats = await StatsService.getStats();
    setState(() { _stats = stats; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Reading Stats')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _stats == null
              ? const Center(child: Text('No data'))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Overview cards
                      Row(children: [
                        _StatCard(icon: Icons.menu_book, label: 'Books', value: '${_stats!['total_books']}', color: Colors.blue),
                        const SizedBox(width: 12),
                        _StatCard(icon: Icons.check_circle, label: 'Finished', value: '${_stats!['finished_books']}', color: Colors.green),
                      ]),
                      const SizedBox(height: 12),
                      Row(children: [
                        _StatCard(icon: Icons.auto_stories, label: 'Pages', value: '${_stats!['total_pages']}', color: Colors.orange),
                        const SizedBox(width: 12),
                        _StatCard(icon: Icons.timer, label: 'Hours', value: '${_stats!['total_hours']}', color: Colors.purple),
                      ]),
                      const SizedBox(height: 12),
                      Row(children: [
                        _StatCard(icon: Icons.highlight, label: 'Highlights', value: '${_stats!['total_highlights']}', color: Colors.amber),
                        const SizedBox(width: 12),
                        _StatCard(icon: Icons.translate, label: 'Words', value: '${_stats!['total_vocab']}', color: Colors.teal),
                      ]),

                      const SizedBox(height: 24),

                      // Weekly chart
                      Text('Last 7 Days (minutes)', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 150,
                        child: _WeeklyChart(dailyMinutes: Map<String, int>.from(_stats!['daily_minutes'])),
                      ),
                    ],
                  ),
                ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(value, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              Text(label, style: TextStyle(color: theme.colorScheme.outline, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  final Map<String, int> dailyMinutes;
  const _WeeklyChart({required this.dailyMinutes});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entries = dailyMinutes.entries.toList().reversed.toList();
    final maxVal = entries.fold<int>(1, (prev, e) => e.value > prev ? e.value : prev);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: entries.map((e) {
        final ratio = e.value / maxVal;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('${e.value}', style: TextStyle(fontSize: 10, color: theme.colorScheme.outline)),
                const SizedBox(height: 4),
                Container(
                  height: (ratio * 100).clamp(4, 100),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3 + ratio * 0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                Text(e.key, style: TextStyle(fontSize: 10, color: theme.colorScheme.outline)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
