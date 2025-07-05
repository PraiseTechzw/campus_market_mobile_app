import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Campus Market', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Version 1.0.0'),
            SizedBox(height: 8),
            Text('Developed by Appixia Softwares'),
            SizedBox(height: 8),
            Text('© 2025 Appixia Softwares'),
            SizedBox(height: 8),
            Text('Contact: info@campusmarket.co.zw'),
            SizedBox(height: 16),
            Text('Campus Market is a platform for students to buy, sell, and connect on campus.'),
          ],
        ),
      ),
    );
  }
} 