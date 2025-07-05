import 'package:campus_market/main.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/app_theme.dart';
import 'account_section.dart';
import 'notifications_section.dart';
import 'privacy_section.dart';
import 'support_section.dart';
import 'theme_section.dart';
import 'privacy_settings_screen.dart';
import 'blocked_users_screen.dart';
import 'help_center_screen.dart';
import 'feedback_screen.dart';
import 'about_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, AppThemeMode>((ref) => ThemeModeNotifier());

class ThemeModeNotifier extends StateNotifier<AppThemeMode> {
  ThemeModeNotifier() : super(AppThemeMode.system) {
    _load();
  }
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString('themeMode');
    if (value == 'light') state = AppThemeMode.light;
    else if (value == 'dark') state = AppThemeMode.dark;
    else state = AppThemeMode.system;
  }
  Future<void> setTheme(AppThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    if (mode == AppThemeMode.light) prefs.setString('themeMode', 'light');
    else if (mode == AppThemeMode.dark) prefs.setString('themeMode', 'dark');
    else prefs.setString('themeMode', 'system');
  }
}

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool pushEnabled = true;
  bool emailEnabled = true;
  bool remindersEnabled = true;
  bool messagesEnabled = true;
  bool productsEnabled = true;
  bool ratingsEnabled = true;
  bool eventsEnabled = true;

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
  }

  void _editProfile() {
    Navigator.of(context).pushNamed('/profile');
  }

  void _changePassword() {
    Navigator.of(context).pushNamed('/forgot-password');
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text('Are you sure you want to delete your account? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed == true) {
      // TODO: Implement actual delete logic with authService
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account deleted (not really, demo only).')));
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _privacySettings() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PrivacySettingsScreen()));
  }

  void _blockedUsers() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BlockedUsersScreen()));
  }

  void _helpCenter() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HelpCenterScreen()));
  }

  void _sendFeedback() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FeedbackScreen()));
  }

  void _about() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AboutScreen()));
  }

  Future<void> _updateNotificationSetting(String key, bool value) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({key: value});
    setState(() {
      switch (key) {
        case 'remindersEnabled': remindersEnabled = value; break;
        case 'messagesEnabled': messagesEnabled = value; break;
        case 'productsEnabled': productsEnabled = value; break;
        case 'ratingsEnabled': ratingsEnabled = value; break;
        case 'eventsEnabled': eventsEnabled = value; break;
      }
    });
    // Schedule/cancel reminders if needed
    if (key == 'remindersEnabled') {
      if (value) {
        // Schedule daily reminder at 9:00 AM
        await flutterLocalNotificationsPlugin.zonedSchedule(
          0,
          'Campus Market Reminder',
          'Check out new products and messages!',
          _nextInstanceOfTime(9, 0),
          const NotificationDetails(
            android: AndroidNotificationDetails('high_importance_channel', 'High Importance Notifications'),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      } else {
        await flutterLocalNotificationsPlugin.cancel(0);
      }
    }
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeMode = ref.watch(themeModeProvider);
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
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
                  ThemeSection(
                    selectedMode: themeMode,
                    onChanged: (mode) => ref.read(themeModeProvider.notifier).setTheme(mode),
                  ),
                  const SizedBox(height: 16),
                  AccountSection(
                    onEditProfile: _editProfile,
                    onChangePassword: _changePassword,
                    onDeleteAccount: _deleteAccount,
                  ),
                  const SizedBox(height: 16),
                  NotificationsSection(
                    remindersEnabled: remindersEnabled,
                    messagesEnabled: messagesEnabled,
                    productsEnabled: productsEnabled,
                    ratingsEnabled: ratingsEnabled,
                    eventsEnabled: eventsEnabled,
                    onRemindersChanged: (v) => _updateNotificationSetting('remindersEnabled', v),
                    onMessagesChanged: (v) => _updateNotificationSetting('messagesEnabled', v),
                    onProductsChanged: (v) => _updateNotificationSetting('productsEnabled', v),
                    onRatingsChanged: (v) => _updateNotificationSetting('ratingsEnabled', v),
                    onEventsChanged: (v) => _updateNotificationSetting('eventsEnabled', v),
                  ),
                  const SizedBox(height: 16),
                  PrivacySection(
                    onPrivacySettings: _privacySettings,
                    onBlockedUsers: _blockedUsers,
                  ),
                  const SizedBox(height: 16),
                  SupportSection(
                    onHelpCenter: _helpCenter,
                    onSendFeedback: _sendFeedback,
                    onAbout: _about,
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