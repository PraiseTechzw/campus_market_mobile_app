import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';

class AddProductState {
  final String type; // product or service
  final String category;
  final String title;
  final String description;
  final double price;
  final String condition;
  final Map<String, dynamic> customFields;
  final List<String> imageUrls;
  final int step;
  final bool isValid;
  final String? meetupLocation;

  AddProductState({
    this.type = '',
    this.category = '',
    this.title = '',
    this.description = '',
    this.price = 0.0,
    this.condition = '',
    this.customFields = const {},
    this.imageUrls = const [],
    this.step = 0,
    this.isValid = false,
    this.meetupLocation,
  });

  AddProductState copyWith({
    String? type,
    String? category,
    String? title,
    String? description,
    double? price,
    String? condition,
    Map<String, dynamic>? customFields,
    List<String>? imageUrls,
    int? step,
    bool? isValid,
    String? meetupLocation,
  }) {
    return AddProductState(
      type: type ?? this.type,
      category: category ?? this.category,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      condition: condition ?? this.condition,
      customFields: customFields ?? this.customFields,
      imageUrls: imageUrls ?? this.imageUrls,
      step: step ?? this.step,
      isValid: isValid ?? this.isValid,
      meetupLocation: meetupLocation ?? this.meetupLocation,
    );
  }
}

class AddProductNotifier extends StateNotifier<AddProductState> {
  AddProductNotifier() : super(AddProductState());

  void updateType(String type) => state = state.copyWith(type: type);
  void updateCategory(String category) => state = state.copyWith(category: category);
  void updateTitle(String title) => state = state.copyWith(title: title);
  void updateDescription(String description) => state = state.copyWith(description: description);
  void updatePrice(double price) => state = state.copyWith(price: price);
  void updateCondition(String condition) => state = state.copyWith(condition: condition);
  void updateCustomFields(Map<String, dynamic> fields) => state = state.copyWith(customFields: fields);
  void updateImages(List<String> urls) => state = state.copyWith(imageUrls: urls);
  void updateStep(int step) => state = state.copyWith(step: step);
  void updateIsValid(bool isValid) => state = state.copyWith(isValid: isValid);
  void updateMeetupLocation(String meetupLocation) => state = state.copyWith(meetupLocation: meetupLocation);
  void reset() => state = AddProductState();
}

final addProductProvider = StateNotifierProvider<AddProductNotifier, AddProductState>((ref) => AddProductNotifier()); 