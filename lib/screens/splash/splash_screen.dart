import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _fadeIn = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _controller.forward();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) context.go('/library');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: Center(
        child: FadeTransition(
          opacity: _fadeIn,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_stories, size: 80, color: theme.colorScheme.onPrimary),
              const SizedBox(height: 16),
              Text('OpenReader', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimary, letterSpacing: 1.5)),
              const SizedBox(height: 8),
              Text('Read anything. Anywhere.', style: TextStyle(fontSize: 14, color: theme.colorScheme.onPrimary.withValues(alpha: 0.7))),
            ],
          ),
        ),
      ),
    );
  }
}
