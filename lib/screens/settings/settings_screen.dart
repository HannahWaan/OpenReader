import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ts = ref.watch(themeProvider);
    final notifier = ref.read(themeProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: ListView(
        children: [
          // ─── THEME ───
          const _SectionHeader('Giao diện'),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('App Theme'),
            trailing: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode, size: 18)),
                ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.auto_mode, size: 18)),
                ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode, size: 18)),
              ],
              selected: {ts.themeMode},
              onSelectionChanged: (s) => notifier.setThemeMode(s.first),
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),

          // ─── SYNC ───
          const _SectionHeader('Cloud Sync'),
          ListTile(
            leading: const Icon(Icons.cloud_outlined),
            title: const Text('Supabase Sync'),
            subtitle: const Text('Đăng nhập để sync giữa các thiết bị'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Supabase auth flow
            },
          ),

          // ─── ABOUT ───
          const _SectionHeader('Thông tin'),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('OpenReader v1.0.0'),
            subtitle: Text('Built with Flutter — 100% Free & Open Source'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
    child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(
      color: Theme.of(context).colorScheme.primary)),
  );
}
