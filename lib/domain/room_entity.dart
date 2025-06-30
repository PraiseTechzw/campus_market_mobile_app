import 'package:cloud_firestore/cloud_firestore.dart';

class RoomEntity {
  final String id;
  final String location;
  final String description;
  final List<String> images;
  final double price;
  final String type; // single, 2-share, 3-share
  final List<DateTime> availability;
  final String userId;
  final DateTime createdAt;

  RoomEntity({
    required this.id,
    required this.location,
    required this.description,
    required this.images,
    required this.price,
    required this.type,
    required this.availability,
    required this.userId,
    required this.createdAt,
  });

  factory RoomEntity.fromMap(Map<String, dynamic> map, String id) {
    final createdAtRaw = map['createdAt'];
    DateTime createdAt;
    if (createdAtRaw is Timestamp) {
      createdAt = createdAtRaw.toDate();
    } else if (createdAtRaw is DateTime) {
      createdAt = createdAtRaw;
    } else {
      createdAt = DateTime.now();
    }
    final availabilityRaw = map['availability'] ?? [];
    final availability = (availabilityRaw as List)
        .map((e) => e is Timestamp ? e.toDate() : DateTime.tryParse(e.toString()) ?? DateTime.now())
        .toList();
    return RoomEntity(
      id: id,
      location: map['location'] ?? '',
      description: map['description'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      price: (map['price'] ?? 0).toDouble(),
      type: map['type'] ?? 'single',
      availability: availability,
      userId: map['userId'] ?? '',
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'location': location,
      'description': description,
      'images': images,
      'price': price,
      'type': type,
      'availability': availability,
      'userId': userId,
      'createdAt': createdAt,
    };
  }
} 