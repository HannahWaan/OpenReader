import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/themes.dart';

// ─── READER THEME ENUM ───
enum ReaderThemeType { light, dark, sepia, green }

// ─── THEME STATE ───
class ThemeState {
  final ThemeMode themeMode;
  final ReaderThemeType readerTheme;
  final double fontSize;
  final String fontFamily;
  final double lineHeight;
  final double marginH;

  const ThemeState({
    this.themeMode = ThemeMode.system,
    this.readerTheme = ReaderThemeType.light,
    this.fontSize = 18.0,
    this.fontFamily = 'Merriweather',
    this.lineHeight = 1.7,
    this.marginH = 24.0,
  });

  ReaderThemeData get readerThemeData {
    switch (readerTheme) {
      case ReaderThemeType.light:  return ReaderThemeData.light;
      case ReaderThemeType.dark:   return ReaderThemeData.dark;
      case ReaderThemeType.sepia:  return ReaderThemeData.sepia;
      case ReaderThemeType.green:  return ReaderThemeData.green;
    }
  }

  ThemeState copyWith({
    ThemeMode? themeMode,
    ReaderThemeType? readerTheme,
    double? fontSize,
    String? fontFamily,
    double? lineHeight,
    double? marginH,
  }) => ThemeState(
    themeMode: themeMode ?? this.themeMode,
    readerTheme: readerTheme ?? this.readerTheme,
    fontSize: fontSize ?? this.fontSize,
    fontFamily: fontFamily ?? this.fontFamily,
    lineHeight: lineHeight ?? this.lineHeight,
    marginH: marginH ?? this.marginH,
  );
}

// ─── THEME NOTIFIER ───
class ThemeNotifier extends StateNotifier<ThemeState> {
  ThemeNotifier() : super(const ThemeState()) { _load(); }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    state = ThemeState(
      themeMode: ThemeMode.values[p.getInt('themeMode') ?? 0],
      readerTheme: ReaderThemeType.values[p.getInt('readerTheme') ?? 0],
      fontSize: p.getDouble('fontSize') ?? 18.0,
      fontFamily: p.getString('fontFamily') ?? 'Merriweather',
      lineHeight: p.getDouble('lineHeight') ?? 1.7,
      marginH: p.getDouble('marginH') ?? 24.0,
    );
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setInt('themeMode', state.themeMode.index);
    await p.setInt('readerTheme', state.readerTheme.index);
    await p.setDouble('fontSize', state.fontSize);
    await p.setString('fontFamily', state.fontFamily);
    await p.setDouble('lineHeight', state.lineHeight);
    await p.setDouble('marginH', state.marginH);
  }

  void setThemeMode(ThemeMode m) { state = state.copyWith(themeMode: m); _save(); }
  void setReaderTheme(ReaderThemeType t) { state = state.copyWith(readerTheme: t); _save(); }
  void setFontSize(double s) { state = state.copyWith(fontSize: s.clamp(12, 36)); _save(); }
  void setFontFamily(String f) { state = state.copyWith(fontFamily: f); _save(); }
  void setLineHeight(double h) { state = state.copyWith(lineHeight: h.clamp(1.0, 3.0)); _save(); }
  void setMarginH(double m) { state = state.copyWith(marginH: m.clamp(8, 48)); _save(); }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>(
  (ref) => ThemeNotifier(),
);
