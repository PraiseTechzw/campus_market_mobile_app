import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';

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