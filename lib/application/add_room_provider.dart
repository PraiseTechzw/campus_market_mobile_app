import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';
import '../domain/room_entity.dart';
import '../infrastructure/room_repository.dart';

class AddRoomState {
  final String roomType;
  final String title;
  final String description;
  final double price;
  final List<String> amenities;
  final String city;
  final String school;
  final String campus;
  final List<String> imageUrls;
  final int step;
  final bool isValid;

  AddRoomState({
    this.roomType = '',
    this.title = '',
    this.description = '',
    this.price = 0.0,
    this.amenities = const [],
    this.city = '',
    this.school = '',
    this.campus = '',
    this.imageUrls = const [],
    this.step = 0,
    this.isValid = false,
  });

  AddRoomState copyWith({
    String? roomType,
    String? title,
    String? description,
    double? price,
    List<String>? amenities,
    String? city,
    String? school,
    String? campus,
    List<String>? imageUrls,
    int? step,
    bool? isValid,
  }) {
    return AddRoomState(
      roomType: roomType ?? this.roomType,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      amenities: amenities ?? this.amenities,
      city: city ?? this.city,
      school: school ?? this.school,
      campus: campus ?? this.campus,
      imageUrls: imageUrls ?? this.imageUrls,
      step: step ?? this.step,
      isValid: isValid ?? this.isValid,
    );
  }
}

class AddRoomNotifier extends StateNotifier<AddRoomState> {
  AddRoomNotifier() : super(AddRoomState());

  void updateRoomType(String type) => state = state.copyWith(roomType: type);
  void updateTitle(String title) => state = state.copyWith(title: title);
  void updateDescription(String description) => state = state.copyWith(description: description);
  void updatePrice(double price) => state = state.copyWith(price: price);
  void updateAmenities(List<String> amenities) => state = state.copyWith(amenities: amenities);
  void updateCity(String city) => state = state.copyWith(city: city);
  void updateSchool(String school) => state = state.copyWith(school: school);
  void updateCampus(String campus) => state = state.copyWith(campus: campus);
  void updateImages(List<String> urls) => state = state.copyWith(imageUrls: urls);
  void updateStep(int step) => state = state.copyWith(step: step);
  void updateIsValid(bool isValid) => state = state.copyWith(isValid: isValid);
  void reset() => state = AddRoomState();
}

final addRoomProvider = StateNotifierProvider<AddRoomNotifier, AddRoomState>((ref) => AddRoomNotifier());

class RoomFilter {
  final String? school;
  final String? campus;
  final String? city;
  final String? type;
  final List<String>? amenities;
  final double? minPrice;
  final double? maxPrice;
  final String sortBy;
  final bool descending;

  const RoomFilter({
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

  RoomFilter copyWith({
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
    return RoomFilter(
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

final roomFilterProvider = StateProvider<RoomFilter>((ref) => const RoomFilter());

final filteredRoomsProvider = StreamProvider<List<RoomEntity>>((ref) {
  final filter = ref.watch(roomFilterProvider);
  final repo = ref.watch(roomRepositoryProvider);
  return repo.fetchFilteredRooms(
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

final roomSearchProvider = StreamProvider.family<List<RoomEntity>, String>((ref, keyword) {
  final repo = ref.watch(roomRepositoryProvider);
  return repo.searchRooms(keyword);
}); 