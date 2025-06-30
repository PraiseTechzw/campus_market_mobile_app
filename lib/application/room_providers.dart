import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../infrastructure/room_repository.dart';
import '../domain/room_entity.dart';

// Provider for room list stream
final roomListProvider = StreamProvider<List<RoomEntity>>((ref) {
  return ref.watch(roomRepositoryProvider).fetchRooms();
});

// Provider for single room by ID
final roomDetailProvider = FutureProvider.family<RoomEntity?, String>((ref, id) {
  return ref.watch(roomRepositoryProvider).fetchRoomById(id);
});

// Provider for adding a room
final addRoomProvider = FutureProvider.family<void, RoomEntity>((ref, room) async {
  await ref.watch(roomRepositoryProvider).addRoom(room);
}); 