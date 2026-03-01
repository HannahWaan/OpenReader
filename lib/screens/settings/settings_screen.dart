import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ts = ref.watch(themeProvider);
    final n = ref.read(themeProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(children: [
        Padding(padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text('Giao dien', style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.primary))),
        ListTile(leading: const Icon(Icons.palette_outlined), title: const Text('App Theme'),
          trailing: SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode, size: 18)),
              ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.auto_mode, size: 18)),
              ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode, size: 18))],
            selected: {ts.themeMode}, onSelectionChanged: (s) => n.setThemeMode(s.first),
            style: const ButtonStyle(visualDensity: VisualDensity.compact,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap))),
        Padding(padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text('Cloud Sync', style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.primary))),
        const ListTile(leading: Icon(Icons.cloud_outlined), title: Text('Supabase Sync'),
          subtitle: Text('Dang nhap de sync giua cac thiet bi'), trailing: Icon(Icons.chevron_right)),
        Padding(padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text('Thong tin', style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.primary))),
        const ListTile(leading: Icon(Icons.info_outline), title: Text('OpenReader v1.0.0'),
          subtitle: Text('Built with Flutter — 100% Free & Open Source')),
      ]));
  }
}
