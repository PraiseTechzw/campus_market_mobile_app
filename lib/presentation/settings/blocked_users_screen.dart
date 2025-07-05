import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({super.key});

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  List<String> blockedUsers = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchBlockedUsers();
  }

  Future<void> _fetchBlockedUsers() async {
    setState(() { loading = true; error = null; });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Not logged in');
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final data = doc.data();
      setState(() {
        blockedUsers = List<String>.from(data?['blockedUsers'] ?? []);
        loading = false;
      });
    } catch (e) {
      setState(() { error = e.toString(); loading = false; });
    }
  }

  Future<void> _unblockUser(String userId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    setState(() { blockedUsers.remove(userId); });
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'blockedUsers': blockedUsers,
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Unblocked $userId')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Blocked Users')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text('Error: $error'))
              : blockedUsers.isEmpty
                  ? const Center(child: Text('No blocked users.'))
                  : ListView.builder(
                      itemCount: blockedUsers.length,
                      itemBuilder: (context, i) => ListTile(
                        title: Text(blockedUsers[i]),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () => _unblockUser(blockedUsers[i]),
                        ),
                      ),
                    ),
    );
  }
} 