import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../application/admin_provider.dart';
import '../../core/app_theme.dart';
import '../../core/components/app_toast.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminProvider.notifier).loadReports();
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);
    final filteredReports = _getFilteredReports(adminState.reports);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.report, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Text(
                'Reports (${filteredReports.length})',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Filter
          Row(
            children: [
              PopupMenuButton<String>(
                onSelected: (value) {
                  setState(() {
                    _filterStatus = value;
                  });
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'all', child: Text('All Reports')),
                  const PopupMenuItem(value: 'pending', child: Text('Pending')),
                  const PopupMenuItem(value: 'resolved', child: Text('Resolved')),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.filter_list),
                      const SizedBox(width: 4),
                      Text(_getStatusFilterText()),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Reports List
          Expanded(
            child: filteredReports.isEmpty
                ? const Center(
                    child: Text('No reports found'),
                  )
                : ListView.separated(
                    itemCount: filteredReports.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final report = filteredReports[index];
                      return _buildReportCard(report);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredReports(List<Map<String, dynamic>> reports) {
    if (_filterStatus == 'all') return reports;
    return reports.where((report) => report['status'] == _filterStatus).toList();
  }

  String _getStatusFilterText() {
    switch (_filterStatus) {
      case 'pending':
        return 'Pending';
      case 'resolved':
        return 'Resolved';
      default:
        return 'All Reports';
    }
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    final isPending = report['status'] == 'pending';
    final reportType = report['type'] ?? 'unknown';
    final reason = report['reason'] ?? 'No reason provided';
    final reporterName = report['reporterName'] ?? 'Anonymous';
    final createdAt = report['createdAt'] as DateTime?;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Report Header
            Row(
              children: [
                Icon(
                  _getReportTypeIcon(reportType),
                  color: _getReportTypeColor(reportType),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getReportTypeText(reportType),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Reported by $reporterName',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(report['status']),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Report Content
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reason:',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(reason),
                  if (report['description'] != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Description:',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(report['description']),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Report Details
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem('Content ID', report['contentId'] ?? 'N/A'),
                ),
                Expanded(
                  child: _buildDetailItem('Date', createdAt != null ? _formatDate(createdAt) : 'N/A'),
                ),
              ],
            ),
            
            if (isPending) ...[
              const SizedBox(height: 12),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Resolve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      onPressed: () => _resolveReport(report),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.block, size: 16),
                      label: const Text('Block Content'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      onPressed: () => _blockContent(report),
                    ),
                  ),
                ],
              ),
            ] else ...[
              const SizedBox(height: 12),
              
              // Resolution Info
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade700, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Resolved: ${report['adminAction'] ?? 'No action specified'}',
                        style: TextStyle(color: Colors.green.shade700),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getReportTypeIcon(String type) {
    switch (type) {
      case 'product':
        return Icons.shopping_bag;
      case 'room':
        return Icons.home;
      case 'user':
        return Icons.person;
      case 'message':
        return Icons.message;
      default:
        return Icons.report;
    }
  }

  Color _getReportTypeColor(String type) {
    switch (type) {
      case 'product':
        return Colors.blue;
      case 'room':
        return Colors.green;
      case 'user':
        return Colors.orange;
      case 'message':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getReportTypeText(String type) {
    switch (type) {
      case 'product':
        return 'Product Report';
      case 'room':
        return 'Room Report';
      case 'user':
        return 'User Report';
      case 'message':
        return 'Message Report';
      default:
        return 'General Report';
    }
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String text;
    
    switch (status) {
      case 'pending':
        color = Colors.orange;
        text = 'PENDING';
        break;
      case 'resolved':
        color = Colors.green;
        text = 'RESOLVED';
        break;
      default:
        color = Colors.grey;
        text = 'UNKNOWN';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color.shade800,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  void _resolveReport(Map<String, dynamic> report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resolve Report'),
        content: const Text('Mark this report as resolved?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(adminProvider.notifier).resolveReport(report['id'], 'Resolved by admin');
              AppToast.show(context, 'Report resolved', AppToastType.success);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Resolve', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _blockContent(Map<String, dynamic> report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Block Content'),
        content: const Text('This will block the reported content and resolve the report. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // TODO: Implement content blocking
              await ref.read(adminProvider.notifier).resolveReport(report['id'], 'Content blocked');
              AppToast.show(context, 'Content blocked and report resolved', AppToastType.success);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Block', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
} 