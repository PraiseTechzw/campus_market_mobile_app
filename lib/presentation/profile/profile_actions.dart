import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/app_theme.dart';

class ProfileActions extends StatelessWidget {
  final String userEmail;
  final bool loading;
  final VoidCallback onSettingsTap;
  final VoidCallback onPasswordReset;

  const ProfileActions({
    super.key,
    required this.userEmail,
    required this.loading,
    required this.onSettingsTap,
    required this.onPasswordReset,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.settings, color: AppTheme.primaryColor),
              title: const Text('Settings'),
              onTap: onSettingsTap,
              trailing: const Icon(Icons.chevron_right),
            ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(Icons.lock_outline, color: Colors.blue),
              title: const Text('Change Password'),
              onTap: loading ? null : onPasswordReset,
              trailing: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileLogoutButton extends StatelessWidget {
  final bool loading;
  const ProfileLogoutButton({super.key, required this.loading});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.logout, color: Colors.white),
        label: const Text('Log Out', style: TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: loading ? null : () async {
          try {
            await FirebaseAuth.instance.signOut();
            if (context.mounted) {
              Navigator.of(context).pushNamedAndRemoveUntil('/', (r) => false);
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to log out: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }
} 