import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class AccountSection extends StatelessWidget {
  final VoidCallback? onEditProfile;
  final VoidCallback? onChangePassword;
  final VoidCallback? onDeleteAccount;
  const AccountSection({this.onEditProfile, this.onChangePassword, this.onDeleteAccount, super.key});

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
              'Account',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: Icon(Icons.person, color: AppTheme.primaryColor),
            title: const Text('Edit Profile'),
            trailing: const Icon(Icons.chevron_right),
            onTap: onEditProfile,
          ),
          ListTile(
            leading: Icon(Icons.lock_outline, color: AppTheme.primaryColor),
            title: const Text('Change Password'),
            trailing: const Icon(Icons.chevron_right),
            onTap: onChangePassword,
          ),
          ListTile(
            leading: Icon(Icons.delete_outline, color: Colors.redAccent),
            title: const Text('Delete Account'),
            trailing: const Icon(Icons.chevron_right),
            onTap: onDeleteAccount,
          ),
        ],
      ),
    );
  }
} 