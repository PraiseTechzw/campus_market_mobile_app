import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.primaryColor.withOpacity(0.8),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Icon(Icons.settings, color: Colors.white, size: 32),
                      const SizedBox(width: 12),
                      const Text(
                        'Settings',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Manage your account, privacy, and app preferences.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _SettingsSection(
                    title: 'Account',
                    items: [
                      _SettingsItem(
                        icon: Icons.person,
                        title: 'Edit Profile',
                        onTap: () {},
                      ),
                      _SettingsItem(
                        icon: Icons.lock_outline,
                        title: 'Change Password',
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SettingsSection(
                    title: 'Notifications',
                    items: [
                      _SettingsItem(
                        icon: Icons.notifications,
                        title: 'Push Notifications',
                        onTap: () {},
                      ),
                      _SettingsItem(
                        icon: Icons.email,
                        title: 'Email Preferences',
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SettingsSection(
                    title: 'Privacy',
                    items: [
                      _SettingsItem(
                        icon: Icons.privacy_tip,
                        title: 'Privacy Settings',
                        onTap: () {},
                      ),
                      _SettingsItem(
                        icon: Icons.block,
                        title: 'Blocked Users',
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SettingsSection(
                    title: 'Support',
                    items: [
                      _SettingsItem(
                        icon: Icons.help_outline,
                        title: 'Help Center',
                        onTap: () {},
                      ),
                      _SettingsItem(
                        icon: Icons.feedback,
                        title: 'Send Feedback',
                        onTap: () {},
                      ),
                      _SettingsItem(
                        icon: Icons.info_outline,
                        title: 'About',
                        onTap: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<_SettingsItem> items;
  const _SettingsSection({required this.title, required this.items});

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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          ...items,
        ],
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const _SettingsItem({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
} 