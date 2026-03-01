import 'dart:io';
import 'package:flutter/material.dart';
import '../../config/themes.dart';

class ScanReaderView extends StatelessWidget {
  final String filePath;
  final ReaderThemeData theme;
  final double fontSize;
  final double lineHeight;
  final String fontFamily;

  const ScanReaderView({
    super.key,
    required this.filePath,
    required this.theme,
    required this.fontSize,
    required this.lineHeight,
    required this.fontFamily,
  });

  @override
  Widget build(BuildContext context) {
    final file = File(filePath);
    if (!file.existsSync()) {
      return Center(child: Text('Khong tim thay file',
        style: TextStyle(color: theme.text)));
    }

    final content = file.readAsStringSync();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: SelectableText(
        content,
        style: TextStyle(
          fontFamily: fontFamily,
          fontSize: fontSize,
          height: lineHeight,
          color: theme.text,
        ),
      ),
    );
  }
}
