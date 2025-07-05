import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  void _contactSupport(BuildContext context) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'info@campusmarket.co.zw',
      query: 'subject=Support Request from Campus Market App',
    );
    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open email client.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help Center')),
      body: ListView(
        children: const [
          ListTile(
            title: Text('How do I reset my password?'),
            subtitle: Text('Go to Settings > Account > Change Password.'),
          ),
          ListTile(
            title: Text('How do I contact support?'),
            subtitle: Text('Tap the button below to email support.'),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () => _contactSupport(context),
          child: const Text('Contact Support'),
        ),
      ),
    );
  }
} 