import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../core/app_theme.dart';
import '../../core/components/app_toast.dart';

class SystemSettingsScreen extends ConsumerStatefulWidget {
  const SystemSettingsScreen({super.key});

  @override
  ConsumerState<SystemSettingsScreen> createState() => _SystemSettingsScreenState();
}

class _SystemSettingsScreenState extends ConsumerState<SystemSettingsScreen> {
  bool _maintenanceMode = false;
  bool _autoVerifyUsers = false;
  bool _requireStudentId = true;
  bool _enableNotifications = true;
  bool _enableEmailNotifications = true;
  bool _enablePushNotifications = true;
  int _maxImagesPerListing = 5;
  int _maxPriceLimit = 1000000;
  String _defaultCurrency = 'NGN';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.settings, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Text(
                'System Settings',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Settings Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildPlatformSettings(),
                  const SizedBox(height: 24),
                  _buildVerificationSettings(),
                  const SizedBox(height: 24),
                  _buildNotificationSettings(),
                  const SizedBox(height: 24),
                  _buildListingSettings(),
                  const SizedBox(height: 24),
                  _buildSecuritySettings(),
                  const SizedBox(height: 24),
                  _buildMaintenanceSettings(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformSettings() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.business, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Platform Settings',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSettingItem(
              'Default Currency',
              'Set the default currency for all transactions',
              _defaultCurrency,
              (value) => setState(() => _defaultCurrency = value),
              options: ['NGN', 'USD', 'EUR', 'GBP'],
            ),
            const SizedBox(height: 16),
            _buildSettingItem(
              'Maximum Price Limit',
              'Set the maximum allowed price for listings',
              '₦${_maxPriceLimit.toString()}',
              (value) => setState(() => _maxPriceLimit = int.tryParse(value) ?? 1000000),
              isEditable: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationSettings() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.verified_user, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Verification Settings',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSwitchItem(
              'Auto-verify Users',
              'Automatically verify users without manual review',
              _autoVerifyUsers,
              (value) => setState(() => _autoVerifyUsers = value),
            ),
            const SizedBox(height: 16),
            _buildSwitchItem(
              'Require Student ID',
              'Require student ID for user registration',
              _requireStudentId,
              (value) => setState(() => _requireStudentId = value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.notifications, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Notification Settings',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSwitchItem(
              'Enable Notifications',
              'Enable all platform notifications',
              _enableNotifications,
              (value) => setState(() => _enableNotifications = value),
            ),
            const SizedBox(height: 16),
            _buildSwitchItem(
              'Email Notifications',
              'Send notifications via email',
              _enableEmailNotifications,
              (value) => setState(() => _enableEmailNotifications = value),
            ),
            const SizedBox(height: 16),
            _buildSwitchItem(
              'Push Notifications',
              'Send push notifications to mobile devices',
              _enablePushNotifications,
              (value) => setState(() => _enablePushNotifications = value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListingSettings() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.list, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Listing Settings',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSettingItem(
              'Max Images Per Listing',
              'Maximum number of images allowed per listing',
              _maxImagesPerListing.toString(),
              (value) => setState(() => _maxImagesPerListing = int.tryParse(value) ?? 5),
              isEditable: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecuritySettings() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.security, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Security Settings',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildActionButton(
              'Reset All Passwords',
              'Force all users to reset their passwords',
              Icons.lock_reset,
              Colors.orange,
              () => _resetAllPasswords(),
            ),
            const SizedBox(height: 16),
            _buildActionButton(
              'Clear All Sessions',
              'Log out all users from all devices',
              Icons.logout,
              Colors.red,
              () => _clearAllSessions(),
            ),
            const SizedBox(height: 16),
            _buildActionButton(
              'Export User Data',
              'Export all user data for backup',
              Icons.download,
              Colors.blue,
              () => _exportUserData(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaintenanceSettings() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.build, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Maintenance Settings',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSwitchItem(
              'Maintenance Mode',
              'Put the platform in maintenance mode',
              _maintenanceMode,
              (value) => setState(() => _maintenanceMode = value),
            ),
            const SizedBox(height: 16),
            _buildActionButton(
              'Clear Cache',
              'Clear all cached data',
              Icons.cleaning_services,
              Colors.green,
              () => _clearCache(),
            ),
            const SizedBox(height: 16),
            _buildActionButton(
              'Database Backup',
              'Create a backup of the database',
              Icons.backup,
              Colors.purple,
              () => _createBackup(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(String title, String description, String value, Function(String) onChanged, {bool isEditable = false, List<String>? options}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 8),
        if (options != null)
          DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: options.map((option) => DropdownMenuItem(value: option, child: Text(option))).toList(),
            onChanged: (newValue) => onChanged(newValue ?? value),
          )
        else if (isEditable)
          TextField(
            controller: TextEditingController(text: value),
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onChanged: onChanged,
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(value),
          ),
      ],
    );
  }

  Widget _buildSwitchItem(String title, String description, bool value, Function(bool) onChanged) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.primaryColor,
        ),
      ],
    );
  }

  Widget _buildActionButton(String title, String description, IconData icon, Color color, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }

  void _resetAllPasswords() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset All Passwords'),
        content: const Text('This will force all users to reset their passwords on next login. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement password reset
              AppToast.show(context, 'Password reset initiated', color: Colors.green, icon: Icons.check);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Reset', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _clearAllSessions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Sessions'),
        content: const Text('This will log out all users from all devices. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement session clearing
              AppToast.show(context, 'All sessions cleared', color: Colors.green, icon: Icons.check);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _exportUserData() {
    // TODO: Implement data export
    AppToast.show(context, 'Data export started', color: Colors.blue, icon: Icons.download);
  }

  void _clearCache() {
    // TODO: Implement cache clearing
    AppToast.show(context, 'Cache cleared', color: Colors.green, icon: Icons.check);
  }

  void _createBackup() {
    // TODO: Implement backup creation
    AppToast.show(context, 'Backup created successfully', color: Colors.green, icon: Icons.check);
  }
} 