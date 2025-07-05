import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class NotificationsSection extends StatelessWidget {
  final bool remindersEnabled;
  final bool messagesEnabled;
  final bool productsEnabled;
  final bool ratingsEnabled;
  final bool eventsEnabled;
  final ValueChanged<bool>? onRemindersChanged;
  final ValueChanged<bool>? onMessagesChanged;
  final ValueChanged<bool>? onProductsChanged;
  final ValueChanged<bool>? onRatingsChanged;
  final ValueChanged<bool>? onEventsChanged;
  const NotificationsSection({
    required this.remindersEnabled,
    required this.messagesEnabled,
    required this.productsEnabled,
    required this.ratingsEnabled,
    required this.eventsEnabled,
    this.onRemindersChanged,
    this.onMessagesChanged,
    this.onProductsChanged,
    this.onRatingsChanged,
    this.onEventsChanged,
    super.key,
  });

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
              'Notifications',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          SwitchListTile(
            secondary: Icon(Icons.alarm, color: AppTheme.primaryColor),
            title: const Text('Reminders'),
            value: remindersEnabled,
            onChanged: onRemindersChanged,
          ),
          SwitchListTile(
            secondary: Icon(Icons.message, color: AppTheme.primaryColor),
            title: const Text('New Messages'),
            value: messagesEnabled,
            onChanged: onMessagesChanged,
          ),
          SwitchListTile(
            secondary: Icon(Icons.new_releases, color: AppTheme.primaryColor),
            title: const Text('New Products in Area'),
            value: productsEnabled,
            onChanged: onProductsChanged,
          ),
          SwitchListTile(
            secondary: Icon(Icons.star, color: AppTheme.primaryColor),
            title: const Text('Ratings & Reviews'),
            value: ratingsEnabled,
            onChanged: onRatingsChanged,
          ),
          SwitchListTile(
            secondary: Icon(Icons.campaign, color: AppTheme.primaryColor),
            title: const Text('Admin & Events'),
            value: eventsEnabled,
            onChanged: onEventsChanged,
          ),
        ],
      ),
    );
  }
} 