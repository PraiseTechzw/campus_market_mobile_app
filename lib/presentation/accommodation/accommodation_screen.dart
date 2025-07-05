import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class AccommodationScreen extends StatelessWidget {
  const AccommodationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accommodation'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: const Center(
        child: Text('Accommodation listings will appear here.'),
      ),
    );
  }
} 