import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../infrastructure/auth_service.dart';
import '../domain/user_entity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

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
  Future<String> uploadStudentId(String filePath) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('Not logged in');
    final ref = FirebaseStorage.instance.ref('student_ids/$uid/${DateTime.now().millisecondsSinceEpoch}.jpg');
    final upload = await ref.putFile(File(filePath));
    final url = await upload.ref.getDownloadURL();
    await FirebaseFirestore.instance.collection('users').doc(uid).update({'studentIdPhotoUrl': url});
    return url;
  }

  // Update profile (stub, to be implemented)
  Future<void> updateProfile(Map<String, dynamic> data) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('Not logged in');
    await FirebaseFirestore.instance.collection('users').doc(uid).update(data);
  }
} 