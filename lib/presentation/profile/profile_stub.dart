import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class ProfileStub extends StatelessWidget {
  const ProfileStub({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person, size: 80, color: AppTheme.primaryColor),
          const SizedBox(height: 16),
          Text('Profile', style: Theme.of(context).textTheme.headlineSmall),
        ],
      ),
    );
  }
} 