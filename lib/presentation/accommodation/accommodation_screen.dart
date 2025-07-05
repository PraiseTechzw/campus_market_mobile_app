import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../core/app_theme.dart';
import '../core/components/app_button.dart';
import '../core/components/app_card.dart';
import '../../application/room_providers.dart';
import '../../domain/room_entity.dart';
import 'room_detail_screen.dart';
import 'accommodation_filter_modal.dart';

class AccommodationScreen extends StatefulWidget {
  const AccommodationScreen({super.key});

  @override
  State<AccommodationScreen> createState() => _AccommodationScreenState();
}

class _AccommodationScreenState extends State<AccommodationScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AccommodationFilterModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accommodation'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterModal,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search for rooms, locations...',
                      hintStyle: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 16,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppTheme.primaryColor,
                        size: 24,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: Colors.grey[600],
                                size: 20,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppTheme.primaryColor,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          // Room Listings
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final filter = ref.watch(accommodationFilterProvider);
                final roomsAsync = ref.watch(filteredRoomsProvider);

                Future<void> _refresh() async {
                  await ref.refresh(filteredRoomsProvider.future);
                }

                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: roomsAsync.when(
                    data: (rooms) {
                      // Client-side search, filter, and sort
                      var filteredRooms = rooms;
                      if (_searchQuery.isNotEmpty) {
                        final q = _searchQuery.toLowerCase();
                        filteredRooms = filteredRooms.where((room) =>
                          room.location.toLowerCase().contains(q) ||
                          room.description.toLowerCase().contains(q)
                        ).toList();
                      }
                      if (filter.school != null && filter.school!.isNotEmpty) {
                        filteredRooms = filteredRooms.where((room) => room.school == filter.school).toList();
                      }
                      if (filter.campus != null && filter.campus!.isNotEmpty) {
                        filteredRooms = filteredRooms.where((room) => room.campus == filter.campus).toList();
                      }
                      if (filter.city != null && filter.city!.isNotEmpty) {
                        filteredRooms = filteredRooms.where((room) => room.city == filter.city).toList();
                      }
                      if (filter.type != null && filter.type!.isNotEmpty) {
                        filteredRooms = filteredRooms.where((room) => room.type == filter.type).toList();
                      }
                      if (filter.amenities != null && filter.amenities!.isNotEmpty) {
                        filteredRooms = filteredRooms.where((room) =>
                          filter.amenities!.every((a) => room.amenities.contains(a))
                        ).toList();
                      }
                      if (filter.minPrice != null) {
                        filteredRooms = filteredRooms.where((room) => room.price >= filter.minPrice!).toList();
                      }
                      if (filter.maxPrice != null) {
                        filteredRooms = filteredRooms.where((room) => room.price <= filter.maxPrice!).toList();
                      }
                      // Sort
                      if (filter.sortBy == 'price') {
                        filteredRooms.sort((a, b) => filter.descending ? b.price.compareTo(a.price) : a.price.compareTo(b.price));
                      } else if (filter.sortBy == 'createdAt') {
                        filteredRooms.sort((a, b) => filter.descending ? b.createdAt.compareTo(a.createdAt) : a.createdAt.compareTo(b.createdAt));
                      }

                      if (filteredRooms.isEmpty) {
                        return ListView(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.4,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.home_work_outlined,
                                      size: 80,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      _searchQuery.isNotEmpty
                                          ? 'No rooms found for "$_searchQuery"'
                                          : 'No rooms available',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _searchQuery.isNotEmpty
                                          ? 'Try adjusting your search terms'
                                          : 'Check back later for new listings',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredRooms.length,
                        itemBuilder: (context, index) {
                          final room = filteredRooms[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: RoomCard(room: room),
                          );
                        },
                      );
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    error: (error, stack) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 80,
                            color: Colors.red[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading rooms',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.red[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          AppButton(
                            onPressed: () => ref.refresh(filteredRoomsProvider),
                            text: 'Retry',
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class RoomCard extends StatelessWidget {
  final RoomEntity room;

  const RoomCard({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RoomDetailScreen(room: room),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          if (room.images.isNotEmpty)
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(room.images.first),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          const SizedBox(height: 12),
          // Title and Price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${room.type} Room',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '\$${room.price.toStringAsFixed(0)}/month',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Location
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${room.campus}, ${room.city}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Description
          Text(
            room.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          // Amenities
          if (room.amenities.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: room.amenities.take(3).map((amenity) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    amenity,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          if (room.amenities.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '+${room.amenities.length - 3} more',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ),
          const SizedBox(height: 12),
          // Availability
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                'Available: ${room.availability.isNotEmpty ? room.availability.first.toString().split(' ')[0] : 'Contact owner'}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 