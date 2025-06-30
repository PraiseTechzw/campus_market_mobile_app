import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../domain/product_entity.dart';
import '../domain/room_entity.dart';
import '../infrastructure/product_repository.dart';
import '../infrastructure/room_repository.dart';

final postAdProvider = Provider<PostAdProvider>((ref) => PostAdProvider(ref));

class PostAdProvider {
  final Ref ref;
  PostAdProvider(this.ref);

  // Post a product
  Future<void> postProduct(ProductEntity product) async {
    await ref.read(productRepositoryProvider).addProduct(product);
  }

  // Post a room
  Future<void> postRoom(RoomEntity room) async {
    await ref.read(roomRepositoryProvider).addRoom(room);
  }
} 