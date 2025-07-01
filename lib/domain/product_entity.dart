import 'package:cloud_firestore/cloud_firestore.dart';

class ProductEntity {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String condition; // New/Used
  final String imageUrl;
  final String sellerId;
  final String school;
  final String campus;
  final String city;
  final DateTime createdAt;

  ProductEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.condition,
    required this.imageUrl,
    required this.sellerId,
    required this.school,
    required this.campus,
    required this.city,
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
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      category: map['category'] ?? '',
      condition: map['condition'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      sellerId: map['sellerId'] ?? '',
      school: map['school'] ?? '',
      campus: map['campus'] ?? '',
      city: map['city'] ?? '',
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'condition': condition,
      'imageUrl': imageUrl,
      'sellerId': sellerId,
      'school': school,
      'campus': campus,
      'city': city,
      'createdAt': createdAt,
    };
  }
} 