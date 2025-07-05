import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class SupportSection extends StatelessWidget {
  final VoidCallback? onHelpCenter;
  final VoidCallback? onSendFeedback;
  final VoidCallback? onAbout;
  const SupportSection({this.onHelpCenter, this.onSendFeedback, this.onAbout, super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Support',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: Icon(Icons.help_outline, color: AppTheme.primaryColor),
            title: const Text('Help Center'),
            trailing: const Icon(Icons.chevron_right),
            onTap: onHelpCenter,
          ),
          ListTile(
            leading: Icon(Icons.feedback, color: AppTheme.primaryColor),
            title: const Text('Send Feedback'),
            trailing: const Icon(Icons.chevron_right),
            onTap: onSendFeedback,
          ),
          ListTile(
            leading: Icon(Icons.info_outline, color: AppTheme.primaryColor),
            title: const Text('About'),
            trailing: const Icon(Icons.chevron_right),
            onTap: onAbout,
          ),
        ],
      ),
    );
  }
} 