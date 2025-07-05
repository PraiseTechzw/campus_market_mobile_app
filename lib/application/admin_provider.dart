import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/user_entity.dart';
import '../domain/product_entity.dart';
import '../domain/room_entity.dart';

// Admin state provider
class AdminState {
  final bool isLoading;
  final String? error;
  final List<UserEntity> pendingUsers;
  final List<UserEntity> allUsers;
  final List<Map<String, dynamic>> reports;
  final Map<String, dynamic> analytics;
  final List<ProductEntity> flaggedProducts;
  final List<RoomEntity> flaggedRooms;

  AdminState({
    this.isLoading = false,
    this.error,
    this.pendingUsers = const [],
    this.allUsers = const [],
    this.reports = const [],
    this.analytics = const {},
    this.flaggedProducts = const [],
    this.flaggedRooms = const [],
  });

  AdminState copyWith({
    bool? isLoading,
    String? error,
    List<UserEntity>? pendingUsers,
    List<UserEntity>? allUsers,
    List<Map<String, dynamic>>? reports,
    Map<String, dynamic>? analytics,
    List<ProductEntity>? flaggedProducts,
    List<RoomEntity>? flaggedRooms,
  }) {
    return AdminState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      pendingUsers: pendingUsers ?? this.pendingUsers,
      allUsers: allUsers ?? this.allUsers,
      reports: reports ?? this.reports,
      analytics: analytics ?? this.analytics,
      flaggedProducts: flaggedProducts ?? this.flaggedProducts,
      flaggedRooms: flaggedRooms ?? this.flaggedRooms,
    );
  }
}

class AdminNotifier extends StateNotifier<AdminState> {
  AdminNotifier() : super(AdminState());

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Load pending verifications
  Future<void> loadPendingVerifications() async {
    state = state.copyWith(isLoading: true);
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('verificationStatus', isEqualTo: 'pending')
          .get();

      final users = snapshot.docs.map((doc) {
        final data = doc.data();
        return UserEntity(
          uid: doc.id,
          name: data['name'] ?? '',
          email: data['email'] ?? '',
          role: data['role'] ?? 'student',
          verified: data['verified'] ?? false,
          phone: data['phone'],
          school: data['school'],
          campus: data['campus'],
          studentId: data['studentId'],
          studentIdPhotoUrl: data['studentIdPhotoUrl'],
          profilePhotoUrl: data['profilePhotoUrl'],
          verificationStatus: data['verificationStatus'] ?? 'pending',
        );
      }).toList();

      state = state.copyWith(pendingUsers: users, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  // Update user verification status
  Future<void> updateVerificationStatus(String userId, String status) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'verificationStatus': status,
        'verified': status == 'approved',
        'verifiedAt': status == 'approved' ? FieldValue.serverTimestamp() : null,
      });

      // Reload pending verifications
      await loadPendingVerifications();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Load all users
  Future<void> loadAllUsers() async {
    state = state.copyWith(isLoading: true);
    try {
      final snapshot = await _firestore.collection('users').get();

      final users = snapshot.docs.map((doc) {
        final data = doc.data();
        return UserEntity(
          uid: doc.id,
          name: data['name'] ?? '',
          email: data['email'] ?? '',
          role: data['role'] ?? 'student',
          verified: data['verified'] ?? false,
          phone: data['phone'],
          school: data['school'],
          campus: data['campus'],
          studentId: data['studentId'],
          studentIdPhotoUrl: data['studentIdPhotoUrl'],
          profilePhotoUrl: data['profilePhotoUrl'],
          verificationStatus: data['verificationStatus'] ?? 'pending',
        );
      }).toList();

      state = state.copyWith(allUsers: users, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  // Block/Unblock user
  Future<void> toggleUserBlock(String userId, bool isBlocked) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isBlocked': isBlocked,
        'blockedAt': isBlocked ? FieldValue.serverTimestamp() : null,
      });

      await loadAllUsers();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Load reports
  Future<void> loadReports() async {
    state = state.copyWith(isLoading: true);
    try {
      final snapshot = await _firestore.collection('reports').orderBy('createdAt', descending: true).get();

      final reports = snapshot.docs.map((doc) {
        final data = doc.data();
    return {
          'id': doc.id,
          ...data,
          'createdAt': data['createdAt']?.toDate(),
        };
      }).toList();

      state = state.copyWith(reports: reports, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  // Resolve report
  Future<void> resolveReport(String reportId, String action) async {
    try {
      await _firestore.collection('reports').doc(reportId).update({
        'status': 'resolved',
        'resolvedAt': FieldValue.serverTimestamp(),
        'adminAction': action,
      });

      await loadReports();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Load analytics
  Future<void> loadAnalytics() async {
    state = state.copyWith(isLoading: true);
    try {
      final usersSnapshot = await _firestore.collection('users').get();
      final productsSnapshot = await _firestore.collection('products').get();
      final roomsSnapshot = await _firestore.collection('rooms').get();
      final reportsSnapshot = await _firestore.collection('reports').get();

      final totalUsers = usersSnapshot.docs.length;
      final verifiedUsers = usersSnapshot.docs.where((doc) => doc.data()['verified'] == true).length;
      final pendingUsers = usersSnapshot.docs.where((doc) => doc.data()['verificationStatus'] == 'pending').length;
      final totalProducts = productsSnapshot.docs.length;
      final totalRooms = roomsSnapshot.docs.length;
      final totalReports = reportsSnapshot.docs.length;
      final pendingReports = reportsSnapshot.docs.where((doc) => doc.data()['status'] == 'pending').length;

      final analytics = {
        'totalUsers': totalUsers,
        'verifiedUsers': verifiedUsers,
        'pendingUsers': pendingUsers,
        'totalProducts': totalProducts,
        'totalRooms': totalRooms,
        'totalReports': totalReports,
        'pendingReports': pendingReports,
        'verificationRate': totalUsers > 0 ? (verifiedUsers / totalUsers * 100).toStringAsFixed(1) : '0',
      };

      state = state.copyWith(analytics: analytics, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  // Load flagged content
  Future<void> loadFlaggedContent() async {
    state = state.copyWith(isLoading: true);
    try {
      final productsSnapshot = await _firestore
          .collection('products')
          .where('isFlagged', isEqualTo: true)
          .get();

      final roomsSnapshot = await _firestore
          .collection('rooms')
          .where('isFlagged', isEqualTo: true)
          .get();

      final flaggedProducts = productsSnapshot.docs.map((doc) {
        final data = doc.data();
        return ProductEntity(
          id: doc.id,
          name: data['name'] ?? '',
          description: data['description'] ?? '',
          price: (data['price'] ?? 0).toDouble(),
          category: data['category'] ?? '',
          condition: data['condition'] ?? '',
          imageUrl: data['imageUrl'] ?? '',
          imageUrls: List<String>.from(data['imageUrls'] ?? []),
          sellerId: data['sellerId'] ?? '',
          school: data['school'] ?? '',
          campus: data['campus'] ?? '',
          city: data['city'] ?? '',
          createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
        );
      }).toList();

      final flaggedRooms = roomsSnapshot.docs.map((doc) {
        final data = doc.data();
        return RoomEntity(
          id: doc.id,
          school: data['school'] ?? '',
          campus: data['campus'] ?? '',
          city: data['city'] ?? '',
          location: data['location'] ?? '',
          description: data['description'] ?? '',
          images: List<String>.from(data['images'] ?? []),
          price: (data['price'] ?? 0).toDouble(),
          type: data['type'] ?? '',
          amenities: List<String>.from(data['amenities'] ?? []),
          tags: List<String>.from(data['tags'] ?? []),
          availability: [],
          userId: data['userId'] ?? '',
          createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
          verificationStatus: data['verificationStatus'] ?? 'pending',
          isBooked: data['isBooked'] ?? false,
        );
      }).toList();

      state = state.copyWith(
        flaggedProducts: flaggedProducts,
        flaggedRooms: flaggedRooms,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  // Remove flag from content
  Future<void> removeFlag(String contentId, String contentType) async {
    try {
      final collection = contentType == 'product' ? 'products' : 'rooms';
      await _firestore.collection(collection).doc(contentId).update({
        'isFlagged': false,
        'flagReason': null,
        'flagRemovedAt': FieldValue.serverTimestamp(),
      });

      await loadFlaggedContent();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Delete content
  Future<void> deleteContent(String contentId, String contentType) async {
    try {
      final collection = contentType == 'product' ? 'products' : 'rooms';
      await _firestore.collection(collection).doc(contentId).delete();

      await loadFlaggedContent();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

final adminProvider = StateNotifierProvider<AdminNotifier, AdminState>((ref) {
  return AdminNotifier();
}); 