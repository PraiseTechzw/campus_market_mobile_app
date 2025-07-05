import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../application/admin_provider.dart';
import '../../application/user_providers.dart';
import '../core/app_theme.dart';
import '../core/components/app_toast.dart';
import 'screens/verification_screen.dart';
import 'screens/user_management_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/flagged_content_screen.dart';
import 'screens/system_settings_screen.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentIndex = _tabController.index;
      });
    });
    
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminProvider.notifier).loadPendingVerifications();
      ref.read(adminProvider.notifier).loadAnalytics();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userEntity = ref.watch(userEntityProvider).asData?.value;
    final adminState = ref.watch(adminProvider);

    // Check admin access
    if (userEntity == null || userEntity.role != 'admin') {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Access Denied'),
          backgroundColor: AppTheme.primaryColor,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.block, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'You do not have permission to view this page.',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(adminProvider.notifier).loadPendingVerifications();
              ref.read(adminProvider.notifier).loadAnalytics();
              AppToast.show(context, 'Data refreshed', AppToastType.success);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            color: AppTheme.primaryColor,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: [
                _buildTab('Verification', Icons.verified_user, adminState.pendingUsers.length),
                _buildTab('Users', Icons.people, adminState.allUsers.length),
                _buildTab('Reports', Icons.report, adminState.reports.where((r) => r['status'] == 'pending').length),
                _buildTab('Analytics', Icons.analytics, null),
                _buildTab('Flagged', Icons.flag, adminState.flaggedProducts.length + adminState.flaggedRooms.length),
                _buildTab('Settings', Icons.settings, null),
              ],
            ),
          ),
          
          // Error Display
          if (adminState.error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.red.shade100,
              child: Row(
                children: [
                  Icon(Icons.error, color: Colors.red.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      adminState.error!,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => ref.read(adminProvider.notifier).clearError(),
                  ),
                ],
              ),
            ),

          // Loading Indicator
          if (adminState.isLoading)
            const LinearProgressIndicator(),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                VerificationScreen(),
                UserManagementScreen(),
                ReportsScreen(),
                AnalyticsScreen(),
                FlaggedContentScreen(),
                SystemSettingsScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String title, IconData icon, int? badge) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(title),
          if (badge != null && badge > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badge.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
} 