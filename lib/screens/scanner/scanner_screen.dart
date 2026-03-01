import 'package:flutter/material.dart';
class ScannerScreen extends StatelessWidget {
  const ScannerScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Scan sach')),
    body: const Center(child: Text('Camera OCR Scanner — Phase 2')));
}
