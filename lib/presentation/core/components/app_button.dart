import 'package:flutter/material.dart';
import '../app_theme.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;
  final bool expanded;

  const AppButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.loading = false,
    this.icon,
    this.expanded = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final btn = ElevatedButton.icon(
      icon: icon != null ? Icon(icon, color: Colors.white) : const SizedBox.shrink(),
      label: loading
          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : Text(text),
      onPressed: loading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
    return expanded ? SizedBox(width: double.infinity, child: btn) : btn;
  }
} 