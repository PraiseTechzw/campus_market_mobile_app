import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  bool? profileVisible;
  bool? dataSharing;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchSettings();
  }

  Future<void> _fetchSettings() async {
    setState(() { loading = true; error = null; });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Not logged in');
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final data = doc.data();
      setState(() {
        profileVisible = data?['profileVisible'] ?? true;
        dataSharing = data?['dataSharing'] ?? false;
        loading = false;
      });
    } catch (e) {
      setState(() { error = e.toString(); loading = false; });
    }
  }

  Future<void> _updateSetting(String key, bool value) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({key: value});
    setState(() { if (key == 'profileVisible') profileVisible = value; else dataSharing = value; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Settings')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text('Error: $error'))
              : ListView(
                  children: [
                    SwitchListTile(
                      title: const Text('Profile Visible'),
                      value: profileVisible ?? true,
                      onChanged: (v) => _updateSetting('profileVisible', v),
                    ),
                    SwitchListTile(
                      title: const Text('Allow Data Sharing'),
                      value: dataSharing ?? false,
                      onChanged: (v) => _updateSetting('dataSharing', v),
                    ),
                  ],
                ),
    );
  }
} 