import 'package:hooks_riverpod/hooks_riverpod.dart';

final adminProvider = Provider<AdminProvider>((ref) => AdminProvider());

class AdminProvider {
  // Fetch dashboard stats (stub)
  Future<Map<String, int>> fetchStats() async {
    // TODO: Implement Firestore queries for stats
    return {
      'users': 0,
      'products': 0,
      'rooms': 0,
    };
  }

  // Fetch users (stub)
  Future<List<Map<String, dynamic>>> fetchUsers() async {
    // TODO: Implement Firestore query for users
    return [];
  }

  // Approve listing (stub)
  Future<void> approveListing(String id, String type) async {
    // TODO: Update Firestore doc for approval
  }

  // Suspend user (stub)
  Future<void> suspendUser(String userId) async {
    // TODO: Update Firestore doc for suspension
  }
} 