import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';
import '../../config/themes.dart';

class ReaderSettingsSheet extends ConsumerWidget {
  const ReaderSettingsSheet({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ts = ref.watch(themeProvider);
    final n = ref.read(themeProvider.notifier);
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(color: scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4, decoration: BoxDecoration(
          color: scheme.outline.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 20),
        Text('Reader Theme', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ReaderThemeType.values.map((type) {
            final data = [ReaderThemeData.light, ReaderThemeData.dark, ReaderThemeData.sepia, ReaderThemeData.green][type.index];
            final sel = ts.readerTheme == type;
            return GestureDetector(onTap: () => n.setReaderTheme(type),
              child: Container(width: 56, height: 56, decoration: BoxDecoration(
                color: data.background, shape: BoxShape.circle,
                border: Border.all(color: sel ? scheme.primary : scheme.outline.withValues(alpha: 0.3), width: sel ? 3 : 1)),
                child: Center(child: Text('Aa', style: TextStyle(color: data.text, fontWeight: FontWeight.w600)))));
          }).toList()),
        const SizedBox(height: 24),
        Row(children: [const Text('A', style: TextStyle(fontSize: 14)),
          Expanded(child: Slider(value: ts.fontSize, min: 12, max: 36, divisions: 24,
            label: ts.fontSize.toInt().toString(), onChanged: (v) => n.setFontSize(v))),
          const Text('A', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))]),
        Row(children: [const Icon(Icons.density_small, size: 18),
          Expanded(child: Slider(value: ts.lineHeight, min: 1.0, max: 3.0, divisions: 20,
            label: ts.lineHeight.toStringAsFixed(1), onChanged: (v) => n.setLineHeight(v))),
          const Icon(Icons.density_large, size: 18)]),
        const SizedBox(height: 20),
        Text('App Theme', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        SegmentedButton<ThemeMode>(
          segments: const [
            ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode, size: 18), label: Text('Light')),
            ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.auto_mode, size: 18), label: Text('Auto')),
            ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode, size: 18), label: Text('Dark'))],
          selected: {ts.themeMode}, onSelectionChanged: (s) => n.setThemeMode(s.first)),
      ]));
  }
}
