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

// Provider for filtered rooms
final filteredRoomsProvider = StreamProvider<List<RoomEntity>>((ref) {
  final filter = ref.watch(accommodationFilterProvider);
  return ref.watch(roomRepositoryProvider).fetchFilteredRooms(
    school: filter.school,
    campus: filter.campus,
    city: filter.city,
    type: filter.type,
    amenities: filter.amenities,
    minPrice: filter.minPrice,
    maxPrice: filter.maxPrice,
    sortBy: filter.sortBy,
    descending: filter.descending,
  );
});

// Provider for room search
final searchRoomsProvider = StreamProvider.family<List<RoomEntity>, String>((ref, query) {
  return ref.watch(roomRepositoryProvider).searchRooms(query);
}); 