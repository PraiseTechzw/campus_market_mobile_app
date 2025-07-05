import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class AccommodationStub extends StatelessWidget {
  const AccommodationStub({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.home_work, size: 80, color: AppTheme.primaryColor),
          const SizedBox(height: 16),
          Text('Accommodation', style: Theme.of(context).textTheme.headlineSmall),
        ],
      ),
    );
  }
} 