import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';
import '../../config/themes.dart';

class ReaderSettingsSheet extends ConsumerWidget {
  const ReaderSettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ts = ref.watch(themeProvider);
    final notifier = ref.read(themeProvider.notifier);
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(width: 40, height: 4,
            decoration: BoxDecoration(
              color: scheme.outline.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),

          // ═══ READER THEME PICKER ═══
          Text('Theme đọc sách', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ReaderThemeType.values.map((type) {
              final data = _themeDataFor(type);
              final selected = ts.readerTheme == type;
              return GestureDetector(
                onTap: () => notifier.setReaderTheme(type),
                child: Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    color: data.background,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? scheme.primary : scheme.outline.withOpacity(0.3),
                      width: selected ? 3 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text('Aa', style: TextStyle(
                      color: data.text, fontWeight: FontWeight.w600)),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // ═══ FONT SIZE ═══
          Row(
            children: [
              const Text('A', style: TextStyle(fontSize: 14)),
              Expanded(
                child: Slider(
                  value: ts.fontSize,
                  min: 12, max: 36,
                  divisions: 24,
                  label: ts.fontSize.toInt().toString(),
                  onChanged: (v) => notifier.setFontSize(v),
                ),
              ),
              const Text('A', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),

          // ═══ LINE HEIGHT ═══
          Row(
            children: [
              const Icon(Icons.density_small, size: 18),
              Expanded(
                child: Slider(
                  value: ts.lineHeight,
                  min: 1.0, max: 3.0,
                  divisions: 20,
                  label: ts.lineHeight.toStringAsFixed(1),
                  onChanged: (v) => notifier.setLineHeight(v),
                ),
              ),
              const Icon(Icons.density_large, size: 18),
            ],
          ),

          // ═══ FONT FAMILY ═══
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['Merriweather', 'NotoSerif', 'Roboto', 'Georgia'].map((f) {
              final selected = ts.fontFamily == f;
              return ChoiceChip(
                label: Text(f, style: TextStyle(fontFamily: f, fontSize: 13)),
                selected: selected,
                onSelected: (_) => notifier.setFontFamily(f),
              );
            }).toList(),
          ),

          // ═══ APP THEME MODE ═══
          const SizedBox(height: 20),
          Text('App Theme', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode), label: Text('Light')),
              ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.auto_mode), label: Text('Auto')),
              ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode), label: Text('Dark')),
            ],
            selected: {ts.themeMode},
            onSelectionChanged: (s) => notifier.setThemeMode(s.first),
          ),
        ],
      ),
    );
  }

  ReaderThemeData _themeDataFor(ReaderThemeType type) {
    switch (type) {
      case ReaderThemeType.light:  return ReaderThemeData.light;
      case ReaderThemeType.dark:   return ReaderThemeData.dark;
      case ReaderThemeType.sepia:  return ReaderThemeData.sepia;
      case ReaderThemeType.green:  return ReaderThemeData.green;
    }
  }
}
