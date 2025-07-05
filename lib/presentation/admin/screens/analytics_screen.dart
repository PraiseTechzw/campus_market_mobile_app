import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../application/admin_provider.dart';
import '../../core/app_theme.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminProvider.notifier).loadAnalytics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);
    final analytics = adminState.analytics;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.analytics, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Text(
                'Platform Analytics',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Analytics Grid
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Overview Cards
                  _buildOverviewSection(analytics),
                  const SizedBox(height: 24),
                  
                  // User Statistics
                  _buildUserStatisticsSection(analytics),
                  const SizedBox(height: 24),
                  
                  // Content Statistics
                  _buildContentStatisticsSection(analytics),
                  const SizedBox(height: 24),
                  
                  // System Health
                  _buildSystemHealthSection(analytics),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewSection(Map<String, dynamic> analytics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Platform Overview',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _buildMetricCard(
              'Total Users',
              analytics['totalUsers']?.toString() ?? '0',
              Icons.people,
              Colors.blue,
            ),
            _buildMetricCard(
              'Verified Users',
              analytics['verifiedUsers']?.toString() ?? '0',
              Icons.verified_user,
              Colors.green,
            ),
            _buildMetricCard(
              'Total Products',
              analytics['totalProducts']?.toString() ?? '0',
              Icons.shopping_bag,
              Colors.orange,
            ),
            _buildMetricCard(
              'Total Rooms',
              analytics['totalRooms']?.toString() ?? '0',
              Icons.home,
              Colors.purple,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUserStatisticsSection(Map<String, dynamic> analytics) {
    final totalUsers = analytics['totalUsers'] ?? 0;
    final verifiedUsers = analytics['verifiedUsers'] ?? 0;
    final pendingUsers = analytics['pendingUsers'] ?? 0;
    final verificationRate = analytics['verificationRate'] ?? '0';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'User Statistics',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildStatRow('Total Users', totalUsers.toString(), Icons.people),
                const Divider(),
                _buildStatRow('Verified Users', verifiedUsers.toString(), Icons.verified_user),
                const Divider(),
                _buildStatRow('Pending Verification', pendingUsers.toString(), Icons.pending),
                const Divider(),
                _buildStatRow('Verification Rate', '$verificationRate%', Icons.trending_up),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContentStatisticsSection(Map<String, dynamic> analytics) {
    final totalProducts = analytics['totalProducts'] ?? 0;
    final totalRooms = analytics['totalRooms'] ?? 0;
    final flaggedProducts = analytics['flaggedProducts'] ?? 0;
    final flaggedRooms = analytics['flaggedRooms'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Content Statistics',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(Icons.shopping_bag, size: 32, color: Colors.orange),
                      const SizedBox(height: 8),
                      Text(
                        'Products',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        totalProducts.toString(),
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      if (flaggedProducts > 0) ...[
                        const SizedBox(height: 4),
                        Text(
                          '$flaggedProducts flagged',
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(Icons.home, size: 32, color: Colors.purple),
                      const SizedBox(height: 8),
                      Text(
                        'Rooms',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        totalRooms.toString(),
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      if (flaggedRooms > 0) ...[
                        const SizedBox(height: 4),
                        Text(
                          '$flaggedRooms flagged',
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSystemHealthSection(Map<String, dynamic> analytics) {
    final totalReports = analytics['totalReports'] ?? 0;
    final pendingReports = analytics['pendingReports'] ?? 0;
    final resolvedReports = totalReports - pendingReports;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'System Health',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildHealthIndicator(
                  'Reports',
                  totalReports.toString(),
                  pendingReports.toString(),
                  resolvedReports.toString(),
                ),
                const SizedBox(height: 16),
                _buildProgressBar(
                  'Report Resolution Rate',
                  totalReports > 0 ? resolvedReports / totalReports : 0,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildHealthIndicator(String title, String total, String pending, String resolved) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildHealthItem('Total', total, Colors.grey),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildHealthItem('Pending', pending, Colors.orange),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildHealthItem('Resolved', resolved, Colors.green),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHealthItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String label, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(
            progress > 0.7 ? Colors.green : progress > 0.4 ? Colors.orange : Colors.red,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${(progress * 100).toStringAsFixed(1)}%',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
} 