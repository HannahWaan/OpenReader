import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('OpenReader', style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => context.go('/library'),
              icon: const Icon(Icons.login),
              label: const Text('Bắt đầu đọc sách'),
            ),
          ],
        ),
      ),
    ),
  );
}
