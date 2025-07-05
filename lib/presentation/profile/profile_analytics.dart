import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../domain/product_entity.dart';
import '../../application/product_providers.dart';
import '../core/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileAnalytics extends ConsumerWidget {
  final String userId;

  const ProfileAnalytics({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(userProductsProvider(userId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return productsAsync.when(
      loading: () => _buildAnalyticsSkeleton(isDark),
      error: (e, _) => _buildErrorCard('Failed to load analytics: $e', isDark),
      data: (products) {
        final analytics = _calculateAnalytics(products);
        return _buildAnalyticsCards(analytics, isDark);
      },
    );
  }

  Map<String, dynamic> _calculateAnalytics(List<ProductEntity> products) {
    final totalListings = products.length;
    final soldProducts = products.where((p) => p.status == 'Sold').length;
    final availableProducts = products.where((p) => p.status == 'Available').length;
    final reservedProducts = products.where((p) => p.status == 'Reserved').length;
    
    final totalEarnings = products
        .where((p) => p.status == 'Sold')
        .fold<double>(0, (sum, product) => sum + product.price);
    
    final totalReviews = products.fold<int>(0, (sum, product) => sum + product.reviewCount);
    final averageRating = products.isNotEmpty 
        ? products.fold<double>(0, (sum, product) => sum + product.rating) / products.length
        : 0.0;

    return {
      'totalListings': totalListings,
      'soldProducts': soldProducts,
      'availableProducts': availableProducts,
      'reservedProducts': reservedProducts,
      'totalEarnings': totalEarnings,
      'totalReviews': totalReviews,
      'averageRating': averageRating,
    };
  }

  Widget _buildAnalyticsCards(Map<String, dynamic> analytics, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.analytics, color: AppTheme.primaryColor, size: 24),
              const SizedBox(width: 12),
              Text(
                'Seller Analytics',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildAnalyticsCard(
                title: 'Total Listings',
                value: analytics['totalListings'].toString(),
                icon: Icons.inventory,
                color: AppTheme.primaryColor,
                isDark: isDark,
              ),
              const SizedBox(width: 12),
              _buildAnalyticsCard(
                title: 'Sold',
                value: analytics['soldProducts'].toString(),
                icon: Icons.check_circle,
                color: Colors.green,
                isDark: isDark,
              ),
              const SizedBox(width: 12),
              _buildAnalyticsCard(
                title: 'Available',
                value: analytics['availableProducts'].toString(),
                icon: Icons.shopping_bag,
                color: Colors.blue,
                isDark: isDark,
              ),
              const SizedBox(width: 12),
              _buildAnalyticsCard(
                title: 'Earnings',
                value: '\$${analytics['totalEarnings'].toStringAsFixed(0)}',
                icon: Icons.attach_money,
                color: Colors.orange,
                isDark: isDark,
              ),
              const SizedBox(width: 12),
              _buildAnalyticsCard(
                title: 'Reviews',
                value: analytics['totalReviews'].toString(),
                icon: Icons.star,
                color: Colors.purple,
                isDark: isDark,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (analytics['totalListings'] > 0) _buildRatingCard(analytics, isDark),
      ],
    );
  }

  Widget _buildAnalyticsCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white70 : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRatingCard(Map<String, dynamic> analytics, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.withOpacity(0.1),
            Colors.purple.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.star, color: Colors.purple, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Average Rating',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      analytics['averageRating'].toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.star, color: Colors.amber, size: 20),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${analytics['totalReviews']} reviews',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.purple,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsSkeleton(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.analytics, color: AppTheme.primaryColor, size: 24),
              const SizedBox(width: 12),
              Text(
                'Seller Analytics',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: List.generate(5, (index) => Padding(
              padding: EdgeInsets.only(right: index < 4 ? 12 : 0),
              child: Container(
                width: 120,
                height: 100,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            )),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorCard(String message, bool isDark) {
    // Print to debug console
    debugPrint('Firestore analytics error: $message');

    // Try to extract a Firestore index link
    final linkRegExp = RegExp(r'(https://console\.firebase\.google\.com[^\s]+)');
    final match = linkRegExp.firstMatch(message);
    final link = match != null ? match.group(0) : null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          if (link != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: GestureDetector(
                onTap: () async {
                  if (await canLaunch(link)) {
                    await launch(link);
                  }
                },
                child: Text(
                  'Click here to create the required Firestore index',
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
} 