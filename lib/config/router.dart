import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/shell/app_shell.dart';
import '../screens/library/library_screen.dart';
import '../screens/highlights/highlights_screen.dart';
import '../screens/chaimager/chaimager_screen.dart';
import '../screens/dictionary/vocabulary_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/reader/reader_screen.dart';
import '../screens/scanner/scanner_screen.dart';

final _rootKey = GlobalKey<NavigatorState>();
final _shellKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(
        path: '/reader/:bookId',
        parentNavigatorKey: _rootKey,
        builder: (_, state) => ReaderScreen(bookId: state.pathParameters['bookId']!),
      ),
      GoRoute(
        path: '/scanner',
        parentNavigatorKey: _rootKey,
        builder: (_, __) => const ScannerScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellKey,
        builder: (_, __, child) => AppShell(child: child),
        routes: [
          GoRoute(path: '/library', builder: (_, __) => const LibraryScreen()),
          GoRoute(path: '/highlights', builder: (_, __) => const HighlightsScreen()),
          GoRoute(path: '/chaimager', builder: (_, __) => const ChaimagerScreen()),
          GoRoute(path: '/vocabulary', builder: (_, __) => const VocabularyScreen()),
          GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
        ],
      ),
    ],
  );
});
