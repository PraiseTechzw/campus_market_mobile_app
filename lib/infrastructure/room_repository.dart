import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../domain/room_entity.dart';

final roomRepositoryProvider = Provider<RoomRepository>((ref) => RoomRepository());

class RoomRepository {
  final _rooms = FirebaseFirestore.instance.collection('rooms');

  // Fetch all rooms
  Stream<List<RoomEntity>> fetchRooms() {
    return _rooms.orderBy('createdAt', descending: true).snapshots().map(
      (snap) {
        final rooms = snap.docs.map((doc) => RoomEntity.fromMap(doc.data(), doc.id)).toList();
        print('DEBUG: fetchRooms fetched [32m${rooms.length}[0m rooms from Firestore');
        return rooms;
      },
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
    Query query = _rooms;
    // Only use equality filters in Firestore query
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
    // Do NOT add price range or orderBy(price) to Firestore query
    query = query.orderBy('createdAt', descending: descending);
    return query.snapshots().map(
      (snap) {
        var rooms = snap.docs.map((doc) => RoomEntity.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
        // Client-side price filtering
        if (minPrice != null) {
          rooms = rooms.where((room) => room.price >= minPrice).toList();
        }
        if (maxPrice != null) {
          rooms = rooms.where((room) => room.price <= maxPrice).toList();
        }
        // Client-side sorting
        if (sortBy == 'price') {
          rooms.sort((a, b) => descending ? b.price.compareTo(a.price) : a.price.compareTo(b.price));
        } else if (sortBy == 'createdAt') {
          rooms.sort((a, b) => descending ? b.createdAt.compareTo(a.createdAt) : a.createdAt.compareTo(b.createdAt));
        }
        // Amenities filter (client-side)
        if (amenities != null && amenities.isNotEmpty) {
          rooms = rooms.where((room) =>
            amenities.every((amenity) => room.amenities.contains(amenity))
          ).toList();
        }
        print('DEBUG: fetchFilteredRooms fetched ${rooms.length} rooms from Firestore with filters');
        return rooms;
      },
    );
  }

  // Keyword search (location/description)
  Stream<List<RoomEntity>> searchRooms(String keyword) {
    return _rooms
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