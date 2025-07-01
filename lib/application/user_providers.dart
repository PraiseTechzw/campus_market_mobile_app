import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final sellerNameProvider = FutureProvider.family<String, String>((ref, sellerId) async {
  final doc = await FirebaseFirestore.instance.collection('users').doc(sellerId).get();
  final data = doc.data();
  if (doc.exists && data != null && data['name'] != null) {
    return data['name'] as String;
  }
  return 'Unknown';
}); 