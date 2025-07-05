import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../domain/product_entity.dart';
import '../../domain/room_entity.dart';
import '../../application/product_providers.dart';
import '../../application/room_providers.dart';
import '../marketplace/product_detail_screen.dart';
import '../accommodation/room_detail_screen.dart';
import '../core/app_theme.dart';

class ProfileSections extends ConsumerWidget {
  final String userId;

  const ProfileSections({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        _ProfileSection(
          title: 'My Listings',
          icon: Icons.inventory,
          child: _UserListingsSection(userId: userId),
          isDark: isDark,
        ),
        const SizedBox(height: 16),
        _ProfileSection(
          title: 'My Accommodation',
          icon: Icons.home_work,
          child: _UserRoomsSection(userId: userId),
          isDark: isDark,
        ),
        const SizedBox(height: 16),
        _ProfileSection(
          title: 'My Bookings',
          icon: Icons.bookmark,
          child: _UserBookingsSection(userId: userId),
          isDark: isDark,
        ),
      ],
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final bool isDark;

  const _ProfileSection({
    required this.title,
    required this.icon,
    required this.child,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.primaryColor, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _UserListingsSection extends ConsumerWidget {
  final String userId;

  const _UserListingsSection({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(userProductsProvider(userId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return productsAsync.when(
      loading: () => _buildSkeletonLoader(isDark),
      error: (e, _) => _buildErrorWidget('Failed to load listings: $e', isDark),
      data: (products) {
        if (products.isEmpty) {
          return _buildEmptyState(
            icon: Icons.inventory_outlined,
            message: 'No products listed yet',
            isDark: isDark,
          );
        }
        return Column(
          children: products.map((product) => _buildProductTile(product, context, isDark)).toList(),
        );
      },
    );
  }

  Widget _buildProductTile(ProductEntity product, BuildContext context, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: (product.imageUrl != null && product.imageUrl.isNotEmpty)
                ? DecorationImage(
                    image: NetworkImage(product.imageUrl),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: (product.imageUrl == null || product.imageUrl.isEmpty)
              ? Icon(Icons.image, color: Colors.grey[400])
              : null,
        ),
        title: Text(
          product.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '\$${product.price.toStringAsFixed(2)}',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getStatusColor(product.status).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                product.status,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: _getStatusColor(product.status),
                ),
              ),
            ),
          ],
        ),
        trailing: Icon(Icons.chevron_right, color: AppTheme.primaryColor),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(product: product),
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'sold':
        return Colors.green;
      case 'reserved':
        return Colors.orange;
      case 'available':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}

class _UserRoomsSection extends ConsumerWidget {
  final String userId;

  const _UserRoomsSection({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsync = ref.watch(roomListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return roomsAsync.when(
      loading: () => _buildSkeletonLoader(isDark),
      error: (e, _) => _buildErrorWidget('Failed to load accommodation: $e', isDark),
      data: (rooms) {
        final myRooms = rooms.where((r) => r.userId == userId).toList();
        if (myRooms.isEmpty) {
          return _buildEmptyState(
            icon: Icons.home_work_outlined,
            message: 'No accommodation listed yet',
            isDark: isDark,
          );
        }
        return Column(
          children: myRooms.map((room) => _buildRoomTile(room, context, isDark)).toList(),
        );
      },
    );
  }

  Widget _buildRoomTile(RoomEntity room, BuildContext context, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: room.images.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(room.images.first),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: room.images.isEmpty
              ? Icon(Icons.home_work, color: Colors.grey[400])
              : null,
        ),
        title: Text(
          '${room.type} Room',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '\$${room.price.toStringAsFixed(0)}/month',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${room.campus}, ${room.city}',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white70 : Colors.grey[600],
              ),
            ),
          ],
        ),
        trailing: Icon(Icons.chevron_right, color: AppTheme.primaryColor),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => RoomDetailScreen(room: room),
            ),
          );
        },
      ),
    );
  }
}

class _UserBookingsSection extends ConsumerWidget {
  final String userId;

  const _UserBookingsSection({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsync = ref.watch(roomListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return roomsAsync.when(
      loading: () => _buildSkeletonLoader(isDark),
      error: (e, _) => _buildErrorWidget('Failed to load bookings: $e', isDark),
      data: (rooms) {
        final myBookings = rooms.where((r) => r.bookedBy == userId).toList();
        if (myBookings.isEmpty) {
          return _buildEmptyState(
            icon: Icons.bookmark_outline,
            message: 'No bookings yet',
            isDark: isDark,
          );
        }
        return Column(
          children: myBookings.map((room) => _buildBookingTile(room, context, isDark)).toList(),
        );
      },
    );
  }

  Widget _buildBookingTile(RoomEntity room, BuildContext context, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: room.images.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(room.images.first),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: room.images.isEmpty
              ? Icon(Icons.home_work, color: Colors.grey[400])
              : null,
        ),
        title: Text(
          '${room.type} Room',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Booked',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '\$${room.price.toStringAsFixed(0)}/month',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Text(
              '${room.campus}, ${room.city}',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white70 : Colors.grey[600],
              ),
            ),
          ],
        ),
        trailing: Icon(Icons.chevron_right, color: AppTheme.primaryColor),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => RoomDetailScreen(room: room),
            ),
          );
        },
      ),
    );
  }
}

Widget _buildSkeletonLoader(bool isDark) {
  return Column(
    children: List.generate(3, (index) => Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: 60,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
    )),
  );
}

Widget _buildErrorWidget(String message, bool isDark) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.red.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.red.withOpacity(0.3)),
    ),
    child: Row(
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
  );
}

Widget _buildEmptyState({
  required IconData icon,
  required String message,
  required bool isDark,
}) {
  return Container(
    padding: const EdgeInsets.all(24),
    child: Column(
      children: [
        Icon(
          icon,
          size: 48,
          color: Colors.grey[400],
        ),
        const SizedBox(height: 12),
        Text(
          message,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
} 