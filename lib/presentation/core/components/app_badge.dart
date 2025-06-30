import 'package:flutter/material.dart';
import '../app_theme.dart';

class AppBadge extends StatelessWidget {
  final String text;
  final Color? color;
  final IconData? icon;

  const AppBadge({
    Key? key,
    required this.text,
    this.color,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color ?? AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }
} 