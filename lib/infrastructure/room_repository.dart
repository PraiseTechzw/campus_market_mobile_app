import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../domain/room_entity.dart';

final roomRepositoryProvider = Provider<RoomRepository>((ref) => RoomRepository());

class RoomRepository {
  final _rooms = FirebaseFirestore.instance.collection('rooms');

  // Fetch all rooms
  Stream<List<RoomEntity>> fetchRooms() {
    return _rooms.orderBy('createdAt', descending: true).snapshots().map(
      (snap) => snap.docs.map((doc) => RoomEntity.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList(),
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
    Query query = _rooms
      .where('verificationStatus', isEqualTo: 'verified')
      .where('isBooked', isEqualTo: false);
    if (school != null && school.isNotEmpty) {
      query = query.where('school', isEqualTo: school);
    }
    if (campus != null && campus.isNotEmpty) {
      query = query.where('campus', isEqualTo: campus);
    }
    if (city != null && city.isNotEmpty) {
      query = query.where('city', isEqualTo: city);
    }
    if (type != null && type.isNotEmpty) {
      query = query.where('type', isEqualTo: type);
    }
    if (minPrice != null) {
      query = query.where('price', isGreaterThanOrEqualTo: minPrice);
    }
    if (maxPrice != null) {
      query = query.where('price', isLessThanOrEqualTo: maxPrice);
    }
    // Firestore does not support array-contains-any for multiple amenities, so filter client-side
    return query.orderBy(sortBy, descending: descending).snapshots().map(
      (snap) {
        var rooms = snap.docs.map((doc) => RoomEntity.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
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
        .map((doc) => RoomEntity.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .where((room) =>
          room.location.toLowerCase().contains(keyword.toLowerCase()) ||
          room.description.toLowerCase().contains(keyword.toLowerCase())
        )
        .toList()
      );
  }
} 