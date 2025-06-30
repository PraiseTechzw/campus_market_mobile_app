import 'package:cloud_firestore/cloud_firestore.dart';

class ProductEntity {
  final String id;
  final String title;
  final String description;
  final List<String> images;
  final double price;
  final String userId;
  final DateTime createdAt;

  ProductEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.images,
    required this.price,
    required this.userId,
    required this.createdAt,
  });

  factory ProductEntity.fromMap(Map<String, dynamic> map, String id) {
    final createdAtRaw = map['createdAt'];
    DateTime createdAt;
    if (createdAtRaw is Timestamp) {
      createdAt = createdAtRaw.toDate();
    } else if (createdAtRaw is DateTime) {
      createdAt = createdAtRaw;
    } else {
      createdAt = DateTime.now();
    }
    return ProductEntity(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      price: (map['price'] ?? 0).toDouble(),
      userId: map['userId'] ?? '',
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'images': images,
      'price': price,
      'userId': userId,
      'createdAt': createdAt,
    };
  }
} 