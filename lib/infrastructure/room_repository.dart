import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../domain/room_entity.dart';

final roomRepositoryProvider = Provider<RoomRepository>((ref) => RoomRepository());

class RoomRepository {
  final _rooms = FirebaseFirestore.instance.collection('rooms');

  // Fetch all rooms
  Stream<List<RoomEntity>> fetchRooms() {
    return _rooms.orderBy('createdAt', descending: true).snapshots().map(
      (snap) => snap.docs.map((doc) => RoomEntity.fromMap(doc.data(), doc.id)).toList(),
    );
  }

  // Fetch room by ID
  Future<RoomEntity?> fetchRoomById(String id) async {
    final doc = await _rooms.doc(id).get();
    if (!doc.exists) return null;
    return RoomEntity.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  // Add new room
  Future<void> addRoom(RoomEntity room) async {
    await _rooms.add(room.toMap());
  }

  // Update room
  Future<void> updateRoom(String id, Map<String, dynamic> data) async {
    await _rooms.doc(id).update(data);
  }

  // Delete room
  Future<void> deleteRoom(String id) async {
    await _rooms.doc(id).delete();
  }

  // Fetch rooms with filters
  Stream<List<RoomEntity>> fetchFilteredRooms({
    String? school,
    String? campus,
    String? city,
    String? type,
    List<String>? amenities,
    double? minPrice,
    double? maxPrice,
    String sortBy = 'createdAt',
    bool descending = true,
  }) {
    // Remove all Firestore query filters, fetch all rooms
    return _rooms.orderBy(sortBy, descending: descending).snapshots().map(
      (snap) {
        var rooms = snap.docs.map((doc) => RoomEntity.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
        // Optionally, apply client-side filtering here if needed
        if (school != null && school.isNotEmpty) {
          rooms = rooms.where((room) => room.school == school).toList();
        }
        if (campus != null && campus.isNotEmpty) {
          rooms = rooms.where((room) => room.campus == campus).toList();
        }
        if (city != null && city.isNotEmpty) {
          rooms = rooms.where((room) => room.city == city).toList();
        }
        if (type != null && type.isNotEmpty) {
          rooms = rooms.where((room) => room.type == type).toList();
        }
        if (minPrice != null) {
          rooms = rooms.where((room) => room.price >= minPrice).toList();
        }
        if (maxPrice != null) {
          rooms = rooms.where((room) => room.price <= maxPrice).toList();
        }
        if (amenities != null && amenities.isNotEmpty) {
          rooms = rooms.where((room) => amenities.every((a) => room.amenities.contains(a))).toList();
        }
        return rooms;
      },
    );
  }

  // Keyword search (location/description)
  Stream<List<RoomEntity>> searchRooms(String keyword) {
    return _rooms
      .where('verificationStatus', isEqualTo: 'verified')
      .where('isBooked', isEqualTo: false)
      .snapshots()
      .map((snap) => snap.docs
        .map((doc) => RoomEntity.fromMap(doc.data(), doc.id))
        .where((room) =>
          room.location.toLowerCase().contains(keyword.toLowerCase()) ||
          room.description.toLowerCase().contains(keyword.toLowerCase())
        )
        .toList()
      );
  }

  // Book a room
  Future<void> bookRoom(String roomId, String userId) async {
    await _rooms.doc(roomId).update({
      'isBooked': true,
      'bookedBy': userId,
    });
  }
} 