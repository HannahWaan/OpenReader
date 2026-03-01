import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppThemes {
  static ThemeData light() => ThemeData(
    brightness: Brightness.light, useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF2E7D32), onPrimary: Colors.white,
      primaryContainer: Color(0xFFC8E6C9), secondary: Color(0xFF66BB6A),
      surface: Color(0xFFFCFCFC), onSurface: Color(0xFF1C1B1F),
      surfaceContainerHighest: Color(0xFFF2F2F2), outline: Color(0xFFCAC4D0)),
    scaffoldBackgroundColor: const Color(0xFFF8F8F8),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white, foregroundColor: const Color(0xFF1C1B1F),
      elevation: 0, scrolledUnderElevation: 0.5, centerTitle: true,
      titleTextStyle: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: const Color(0xFF1C1B1F))),
    cardTheme: CardThemeData(color: Colors.white, elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE8E8E8)))),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white, selectedItemColor: Color(0xFF2E7D32),
      unselectedItemColor: Color(0xFF9E9E9E), type: BottomNavigationBarType.fixed, elevation: 0),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF2E7D32), foregroundColor: Colors.white),
  );

  static ThemeData dark() => ThemeData(
    brightness: Brightness.dark, useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF81C784), onPrimary: Color(0xFF003909),
      primaryContainer: Color(0xFF1B5E20), secondary: Color(0xFF4CAF50),
      surface: Color(0xFF141414), onSurface: Color(0xFFE6E1E5),
      surfaceContainerHighest: Color(0xFF1E1E1E), outline: Color(0xFF49454F)),
    scaffoldBackgroundColor: const Color(0xFF0C0C0C),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF141414), foregroundColor: const Color(0xFFE6E1E5),
      elevation: 0, scrolledUnderElevation: 0.5, centerTitle: true,
      titleTextStyle: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: const Color(0xFFE6E1E5))),
    cardTheme: CardThemeData(color: const Color(0xFF1E1E1E), elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF2C2C2C)))),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF141414), selectedItemColor: Color(0xFF81C784),
      unselectedItemColor: Color(0xFF666666), type: BottomNavigationBarType.fixed, elevation: 0),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF81C784), foregroundColor: Color(0xFF003909)),
  );
}

class ReaderThemeData {
  final Color background, text, secondaryText;
  final List<Color> highlightColors;
  const ReaderThemeData({required this.background, required this.text,
    required this.secondaryText, required this.highlightColors});
  static const light = ReaderThemeData(background: Color(0xFFFFFFFF), text: Color(0xFF1A1A1A),
    secondaryText: Color(0xFF666666), highlightColors: [Color(0xFFFFF176), Color(0xFF81C784), Color(0xFF64B5F6), Color(0xFFE57373), Color(0xFFCE93D8)]);
  static const dark = ReaderThemeData(background: Color(0xFF121212), text: Color(0xFFD4D4D4),
    secondaryText: Color(0xFF888888), highlightColors: [Color(0xFFFDD835), Color(0xFF66BB6A), Color(0xFF42A5F5), Color(0xFFEF5350), Color(0xFFAB47BC)]);
  static const sepia = ReaderThemeData(background: Color(0xFFF4ECD8), text: Color(0xFF5B4636),
    secondaryText: Color(0xFF8B7355), highlightColors: [Color(0xFFE6C47F), Color(0xFF8FBC8F), Color(0xFF87CEEB), Color(0xFFCD5C5C), Color(0xFF9370DB)]);
  static const green = ReaderThemeData(background: Color(0xFFD5E8D4), text: Color(0xFF2E4A2E),
    secondaryText: Color(0xFF5A785A), highlightColors: [Color(0xFFFFF176), Color(0xFFA5D6A7), Color(0xFF90CAF9), Color(0xFFEF9A9A), Color(0xFFCE93D8)]);
}
