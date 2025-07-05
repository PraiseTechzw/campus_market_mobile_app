import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../infrastructure/auth_service.dart';

final sellerNameProvider = FutureProvider.family<String, String>((ref, sellerId) async {
  final doc = await FirebaseFirestore.instance.collection('users').doc(sellerId).get();
  final data = doc.data();
  if (doc.exists && data != null && data['name'] != null) {
    return data['name'] as String;
  }
  return 'Unknown';
});

final sellerDataProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, sellerId) async {
  final doc = await FirebaseFirestore.instance.collection('users').doc(sellerId).get();
  final data = doc.data();
  if (doc.exists && data != null) {
    return {
      'name': data['name'] ?? 'Unknown',
      'selfieUrl': data['selfieUrl'] ?? data['profilePhotoUrl'] ?? data['photoURL'],
      'school': data['school'] ?? '',
      'campus': data['campus'] ?? '',
      'verified': data['verified'] ?? false,
    };
  }
  return {
    'name': 'Unknown',
    'selfieUrl': null,
    'school': '',
    'campus': '',
    'verified': false,
  };
});

final updateUserProfileProvider = FutureProvider.family<void, Map<String, dynamic>>((ref, params) async {
  final auth = ref.watch(authServiceProvider);
  final userId = params['userId'] as String;
  final data = params['data'] as Map<String, dynamic>;
  await auth.updateUserProfile(userId, data);
}); 