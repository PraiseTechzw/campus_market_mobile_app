import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../infrastructure/auth_service.dart';
import '../domain/user_entity.dart';

final profileProvider = StateNotifierProvider<ProfileNotifier, AsyncValue<UserEntity?>>((ref) {
  return ProfileNotifier(ref);
});

class ProfileNotifier extends StateNotifier<AsyncValue<UserEntity?>> {
  final Ref ref;
  ProfileNotifier(this.ref) : super(const AsyncValue.loading()) {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final userStream = ref.read(authServiceProvider).userEntityStream();
    userStream.listen((user) {
      state = AsyncValue.data(user);
    });
  }

  // Upload student ID for verification (stub, to be implemented)
  Future<void> uploadStudentId(String filePath) async {
    // TODO: Upload to Firebase Storage and update user doc
  }

  // Update profile (stub, to be implemented)
  Future<void> updateProfile(Map<String, dynamic> data) async {
    // TODO: Update user doc in Firestore
  }
} 