import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class PrivacySection extends StatelessWidget {
  final VoidCallback? onPrivacySettings;
  final VoidCallback? onBlockedUsers;
  const PrivacySection({this.onPrivacySettings, this.onBlockedUsers, super.key});

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
              'Privacy',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: Icon(Icons.privacy_tip, color: AppTheme.primaryColor),
            title: const Text('Privacy Settings'),
            trailing: const Icon(Icons.chevron_right),
            onTap: onPrivacySettings,
          ),
          ListTile(
            leading: Icon(Icons.block, color: AppTheme.primaryColor),
            title: const Text('Blocked Users'),
            trailing: const Icon(Icons.chevron_right),
            onTap: onBlockedUsers,
          ),
        ],
      ),
    );
  }
} 