import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor.withOpacity(0.05),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/marketplace.png',
              height: 120,
              fit: BoxFit.contain,
            )
                .animate()
                .fadeIn(duration: 800.ms)
                .scale(begin: const Offset(0.8, 0.8), end: Offset(1, 1), duration: 800.ms, curve: Curves.easeOut),
            const SizedBox(height: 32),
            Text(
              'Campus Market',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
            )
                .animate()
                .fadeIn(duration: 700.ms, delay: 200.ms)
                .shimmer(duration: 1200.ms, color: AppTheme.primaryColor.withOpacity(0.3)),
            const SizedBox(height: 16),
            // No loading spinner, just a beautiful animated splash
          ],
        ),
      ),
    );
  }
} 