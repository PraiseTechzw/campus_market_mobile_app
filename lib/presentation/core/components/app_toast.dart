import 'package:flutter/material.dart';
import '../app_theme.dart';

class AppToast {
  static void show(BuildContext context, String message, {Color? color, IconData? icon, Duration duration = const Duration(seconds: 3)}) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          if (icon != null) Icon(icon, color: Colors.white),
          if (icon != null) const SizedBox(width: 8),
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: color ?? AppTheme.primaryColor,
      duration: duration,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
} 