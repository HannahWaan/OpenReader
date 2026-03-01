import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});
  int _idx(BuildContext c) {
    final loc = GoRouterState.of(c).uri.path;
    if (loc.startsWith('/library')) return 0;
    if (loc.startsWith('/highlights')) return 1;
    if (loc.startsWith('/chaimager')) return 2;
    if (loc.startsWith('/vocabulary')) return 3;
    if (loc.startsWith('/settings')) return 4;
    return 0;
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    body: child,
    bottomNavigationBar: BottomNavigationBar(
      currentIndex: _idx(context),
      onTap: (i) => context.go(const ['/library','/highlights','/chaimager','/vocabulary','/settings'][i]),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.library_books_outlined), activeIcon: Icon(Icons.library_books), label: 'Library'),
        BottomNavigationBarItem(icon: Icon(Icons.highlight_outlined), activeIcon: Icon(Icons.highlight), label: 'Highlights'),
        BottomNavigationBarItem(icon: Icon(Icons.people_outline), activeIcon: Icon(Icons.people), label: 'Chaimager'),
        BottomNavigationBarItem(icon: Icon(Icons.translate_outlined), activeIcon: Icon(Icons.translate), label: 'Vocab'),
        BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), activeIcon: Icon(Icons.settings), label: 'Settings'),
      ]));
}
