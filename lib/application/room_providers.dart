import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../infrastructure/room_repository.dart';
import '../domain/room_entity.dart';

// Provider for room list stream
final roomListProvider = StreamProvider<List<RoomEntity>>((ref) {
  return ref.watch(roomRepositoryProvider).fetchRooms();
});

// Provider for single room by ID
final roomDetailProvider = FutureProvider.family<RoomEntity?, String>((ref, id) {
  return ref.watch(roomRepositoryProvider).fetchRoomById(id);
});

// Provider for adding a room
final addRoomProvider = FutureProvider.family<void, RoomEntity>((ref, room) async {
  await ref.watch(roomRepositoryProvider).addRoom(room);
});

// Provider for booking a room
final bookRoomProvider = FutureProvider.family<void, Map<String, String>>((ref, data) async {
  final repo = ref.watch(roomRepositoryProvider);
  final roomId = data['roomId']!;
  final userId = data['userId']!;
  await repo.bookRoom(roomId, userId);
});

// Provider for available filter options
final filterOptionsProvider = FutureProvider<Map<String, List<String>>>((ref) async {
  final rooms = await ref.watch(roomListProvider.future);
  
  final schools = rooms.map((room) => room.school).where((school) => school.isNotEmpty).toSet().toList()..sort();
  final campuses = rooms.map((room) => room.campus).where((campus) => campus.isNotEmpty).toSet().toList()..sort();
  final cities = rooms.map((room) => room.city).where((city) => city.isNotEmpty).toSet().toList()..sort();
  final types = rooms.map((room) => room.type).where((type) => type.isNotEmpty).toSet().toList()..sort();
  
  // Get all unique amenities from all rooms
  final allAmenities = <String>{};
  for (final room in rooms) {
    allAmenities.addAll(room.amenities);
  }
  final amenities = allAmenities.toList()..sort();
  
  return {
    'schools': schools,
    'campuses': campuses,
    'cities': cities,
    'types': types,
    'amenities': amenities,
  };
});

// Provider for price range
final priceRangeProvider = FutureProvider<Map<String, double>>((ref) async {
  final rooms = await ref.watch(roomListProvider.future);
  
  if (rooms.isEmpty) {
    return {'min': 0.0, 'max': 2000.0};
  }
  
  final prices = rooms.map((room) => room.price).toList();
  final minPrice = prices.reduce((a, b) => a < b ? a : b);
  final maxPrice = prices.reduce((a, b) => a > b ? a : b);
  
  return {
    'min': minPrice,
    'max': maxPrice,
  };
});

// Accommodation filter state
class AccommodationFilter {
  final String? school;
  final String? campus;
  final String? city;
  final String? type;
  final List<String>? amenities;
  final double? minPrice;
  final double? maxPrice;
  final String sortBy;
  final bool descending;

  AccommodationFilter({
    this.school,
    this.campus,
    this.city,
    this.type,
    this.amenities,
    this.minPrice,
    this.maxPrice,
    this.sortBy = 'createdAt',
    this.descending = true,
  });

  AccommodationFilter copyWith({
    String? school,
    String? campus,
    String? city,
    String? type,
    List<String>? amenities,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    bool? descending,
  }) {
    return AccommodationFilter(
      school: school ?? this.school,
      campus: campus ?? this.campus,
      city: city ?? this.city,
      type: type ?? this.type,
      amenities: amenities ?? this.amenities,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      sortBy: sortBy ?? this.sortBy,
      descending: descending ?? this.descending,
    );
  }
}

class AccommodationFilterNotifier extends StateNotifier<AccommodationFilter> {
  AccommodationFilterNotifier() : super(AccommodationFilter());

  void updateFilters({
    String? school,
    String? campus,
    String? city,
    String? type,
    List<String>? amenities,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    bool? descending,
  }) {
    state = state.copyWith(
      school: school,
      campus: campus,
      city: city,
      type: type,
      amenities: amenities,
      minPrice: minPrice,
      maxPrice: maxPrice,
      sortBy: sortBy,
      descending: descending,
    );
  }

  void clearFilters() {
    state = AccommodationFilter();
  }
}

final accommodationFilterProvider = StateNotifierProvider<AccommodationFilterNotifier, AccommodationFilter>((ref) {
  return AccommodationFilterNotifier();
});

// Provider for filtered rooms (now just fetches all rooms, filtering is client-side)
final filteredRoomsProvider = StreamProvider<List<RoomEntity>>((ref) {
  return ref.watch(roomRepositoryProvider).fetchRooms();
});

// Provider for room search (now just fetches all rooms, search is client-side)
final searchRoomsProvider = StreamProvider.family<List<RoomEntity>, String>((ref, query) {
  return ref.watch(roomRepositoryProvider).fetchRooms();
}); 