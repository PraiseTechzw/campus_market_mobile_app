import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../infrastructure/auth_service.dart';
import '../core/app_router.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userEntity = ref.watch(userEntityProvider).asData?.value;
    if (userEntity == null || userEntity.role != 'admin') {
      return Scaffold(
        appBar: AppBar(title: const Text('Access Denied')),
        body: const Center(child: Text('You do not have permission to view this page.')),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.admin_panel_settings, size: 80, color: AppTheme.primaryColor),
            const SizedBox(height: 24),
            Text(
              'Welcome, Admin!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            const Text('Dashboard, stats, and management tools coming soon.'),
          ],
        ),
      ),
    );
  }
} 