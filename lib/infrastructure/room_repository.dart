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
    return RoomEntity.fromMap(doc.data()!, doc.id);
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
} 