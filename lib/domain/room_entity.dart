import 'package:cloud_firestore/cloud_firestore.dart';

class RoomEntity {
  final String id;
  final String school;
  final String campus;
  final String city;
  final String location;
  final String description;
  final List<String> images;
  final double price;
  final String type; // single, 2-share, 3-share
  final List<String> amenities;
  final List<String> tags;
  final List<DateTime> availability;
  final String userId;
  final DateTime createdAt;
  final String verificationStatus; // verified, pending, rejected
  final bool isBooked;

  RoomEntity({
    required this.id,
    required this.school,
    required this.campus,
    required this.city,
    required this.location,
    required this.description,
    required this.images,
    required this.price,
    required this.type,
    required this.amenities,
    required this.tags,
    required this.availability,
    required this.userId,
    required this.createdAt,
    required this.verificationStatus,
    required this.isBooked,
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
      school: map['school'] ?? '',
      campus: map['campus'] ?? '',
      city: map['city'] ?? '',
      location: map['location'] ?? '',
      description: map['description'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      price: (map['price'] ?? 0).toDouble(),
      type: map['type'] ?? 'single',
      amenities: List<String>.from(map['amenities'] ?? []),
      tags: List<String>.from(map['tags'] ?? []),
      availability: availability,
      userId: map['userId'] ?? '',
      createdAt: createdAt,
      verificationStatus: map['verificationStatus'] ?? 'pending',
      isBooked: map['isBooked'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'school': school,
      'campus': campus,
      'city': city,
      'location': location,
      'description': description,
      'images': images,
      'price': price,
      'type': type,
      'amenities': amenities,
      'tags': tags,
      'availability': availability,
      'userId': userId,
      'createdAt': createdAt,
      'verificationStatus': verificationStatus,
      'isBooked': isBooked,
    };
  }
} 