import 'package:flutter/material.dart';
import '../core/app_theme.dart';

enum AppThemeMode { system, light, dark }

class ThemeSection extends StatelessWidget {
  final AppThemeMode selectedMode;
  final ValueChanged<AppThemeMode> onChanged;
  const ThemeSection({required this.selectedMode, required this.onChanged, super.key});

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
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Theme',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          RadioListTile<AppThemeMode>(
            value: AppThemeMode.system,
            groupValue: selectedMode,
            onChanged: (mode) { if (mode != null) onChanged(mode); },
            title: const Text('System Default'),
            secondary: Icon(Icons.brightness_auto, color: AppTheme.primaryColor),
          ),
          RadioListTile<AppThemeMode>(
            value: AppThemeMode.light,
            groupValue: selectedMode,
            onChanged: (mode) { if (mode != null) onChanged(mode); },
            title: const Text('Light'),
            secondary: Icon(Icons.light_mode, color: AppTheme.primaryColor),
          ),
          RadioListTile<AppThemeMode>(
            value: AppThemeMode.dark,
            groupValue: selectedMode,
            onChanged: (mode) { if (mode != null) onChanged(mode); },
            title: const Text('Dark'),
            secondary: Icon(Icons.dark_mode, color: AppTheme.primaryColor),
          ),
        ],
      ),
    );
  }
} 