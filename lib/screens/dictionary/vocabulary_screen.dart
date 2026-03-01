import 'package:flutter/material.dart';

class VocabularyScreen extends StatelessWidget {
  const VocabularyScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Vocabulary')),
    body: const Center(child: Text('Smart Dictionary & Vocab Builder — Phase 2')),
  );
}
