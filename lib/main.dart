import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/router.dart';
import 'providers/theme_provider.dart';
import 'config/themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const ProviderScope(child: OpenReaderApp()));
}

class OpenReaderApp extends ConsumerWidget {
  const OpenReaderApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'OpenReader',
      debugShowCheckedModeBanner: false,
      theme: AppThemes.light(),
      darkTheme: AppThemes.dark(),
      themeMode: themeState.themeMode,
      routerConfig: router,
    );
  }
}
