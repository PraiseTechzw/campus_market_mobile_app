import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../core/app_theme.dart';
import '../../domain/user_entity.dart';
import '../core/components/app_button.dart';
import '../../application/user_providers.dart';
import '../../application/room_providers.dart';
import '../../application/product_providers.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _editing = false;
  bool _loading = false;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _schoolController;
  late TextEditingController _campusController;
  late TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _schoolController = TextEditingController();
    _campusController = TextEditingController();
    _bioController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _schoolController.dispose();
    _campusController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _startEditing(UserEntity user) {
    setState(() => _editing = true);
    _nameController.text = user.name;
    _phoneController.text = user.phone ?? '';
    _schoolController.text = user.school ?? '';
    _campusController.text = user.campus ?? '';
    _bioController.text = user.bio ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final userEntityAsync = ref.watch(userEntityProvider);
    return userEntityAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (user) {
        if (user == null) {
          return const Center(child: Text('No user data found.'));
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
            backgroundColor: AppTheme.primaryColor,
            actions: [
              IconButton(
                icon: Icon(_editing ? Icons.close : Icons.edit),
                onPressed: () {
                  if (_editing) {
                    setState(() => _editing = false);
                  } else {
                    _startEditing(user);
                  }
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile picture
                CircleAvatar(
                  radius: 48,
                  backgroundImage: user.profilePhotoUrl != null && user.profilePhotoUrl!.isNotEmpty
                      ? NetworkImage(user.profilePhotoUrl!)
                      : null,
                  child: (user.profilePhotoUrl == null || user.profilePhotoUrl!.isEmpty)
                      ? Icon(Icons.person, size: 48, color: Colors.grey[400])
                      : null,
                ),
                const SizedBox(height: 12),
                if (!_editing) ...[
                  Text(user.name, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 4),
                  Text(user.email, style: Theme.of(context).textTheme.bodyMedium),
                  if ((user.phone ?? '').isNotEmpty)
                    Text(user.phone!, style: Theme.of(context).textTheme.bodyMedium),
                  if ((user.school ?? '').isNotEmpty)
                    Text(user.school!, style: Theme.of(context).textTheme.bodyMedium),
                  if ((user.campus ?? '').isNotEmpty)
                    Text(user.campus!, style: Theme.of(context).textTheme.bodyMedium),
                  if ((user.bio ?? '').isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(user.bio!, style: Theme.of(context).textTheme.bodyMedium),
                    ),
                  const SizedBox(height: 16),
                ],
                if (_editing) ...[
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(labelText: 'Name'),
                          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(labelText: 'Phone'),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _schoolController,
                          decoration: const InputDecoration(labelText: 'School'),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _campusController,
                          decoration: const InputDecoration(labelText: 'Campus'),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _bioController,
                          decoration: const InputDecoration(labelText: 'Bio'),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 16),
                        AppButton(
                          text: _loading ? 'Saving...' : 'Save',
                          loading: _loading,
                          onPressed: _loading
                              ? null
                              : () async {
                                  if (_formKey.currentState!.validate()) {
                                    setState(() => _loading = true);
                                    final data = {
                                      'name': _nameController.text.trim(),
                                      'phone': _phoneController.text.trim(),
                                      'school': _schoolController.text.trim(),
                                      'campus': _campusController.text.trim(),
                                      'bio': _bioController.text.trim(),
                                    };
                                    try {
                                      await ref.read(updateUserProfileProvider({
                                        'userId': user.uid,
                                        'data': data,
                                      }).future);
                                      setState(() => _editing = false);
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Failed to update profile: $e')),
                                        );
                                      }
                                    } finally {
                                      if (mounted) setState(() => _loading = false);
                                    }
                                  }
                                },
                        ),
                        const SizedBox(height: 8),
                        AppButton(
                          text: 'Cancel',
                          onPressed: _loading ? null : () => setState(() => _editing = false),
                          expanded: false,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                // Account actions
                AppButton(
                  text: 'Change Password',
                  onPressed: _loading
                      ? null
                      : () async {
                          setState(() => _loading = true);
                          try {
                            await FirebaseAuth.instance.sendPasswordResetEmail(email: user.email);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Password reset email sent.')),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to send reset email: $e')),
                              );
                            }
                          } finally {
                            if (mounted) setState(() => _loading = false);
                          }
                        },
                  expanded: false,
                ),
                const SizedBox(height: 8),
                AppButton(
                  text: 'Log Out',
                  onPressed: _loading
                      ? null
                      : () async {
                          setState(() => _loading = true);
                          try {
                            await FirebaseAuth.instance.signOut();
                            if (context.mounted) {
                              Navigator.of(context).pushNamedAndRemoveUntil('/', (r) => false);
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to log out: $e')),
                              );
                            }
                          } finally {
                            if (mounted) setState(() => _loading = false);
                          }
                        },
                  expanded: false,
                ),
                const SizedBox(height: 24),
                // Listings
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('My Listings', style: Theme.of(context).textTheme.titleLarge),
                ),
                const SizedBox(height: 8),
                _UserListingsSection(userId: user.uid),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('My Accommodation', style: Theme.of(context).textTheme.titleLarge),
                ),
                const SizedBox(height: 8),
                _UserRoomsSection(userId: user.uid),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('My Bookings', style: Theme.of(context).textTheme.titleLarge),
                ),
                const SizedBox(height: 8),
                _UserBookingsSection(userId: user.uid),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _UserListingsSection extends ConsumerWidget {
  final String userId;
  const _UserListingsSection({required this.userId});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(userProductsProvider(userId));
    return productsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Error: $e'),
      data: (products) {
        if (products.isEmpty) return const Text('No products listed.');
        return Column(
          children: products.map((p) => ListTile(
            leading: p.images.isNotEmpty ? Image.network(p.images.first, width: 40, height: 40, fit: BoxFit.cover) : null,
            title: Text(p.name),
            subtitle: Text('\$${p.price.toStringAsFixed(2)}'),
            trailing: Icon(Icons.chevron_right),
            onTap: () {}, // TODO: Navigate to product detail
          )).toList(),
        );
      },
    );
  }
}

class _UserRoomsSection extends ConsumerWidget {
  final String userId;
  const _UserRoomsSection({required this.userId});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsync = ref.watch(roomListProvider);
    return roomsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Error: $e'),
      data: (rooms) {
        final myRooms = rooms.where((r) => r.userId == userId).toList();
        if (myRooms.isEmpty) return const Text('No accommodation listed.');
        return Column(
          children: myRooms.map((r) => ListTile(
            leading: r.images.isNotEmpty ? Image.network(r.images.first, width: 40, height: 40, fit: BoxFit.cover) : null,
            title: Text('${r.type} Room'),
            subtitle: Text('\$${r.price.toStringAsFixed(2)}'),
            trailing: Icon(Icons.chevron_right),
            onTap: () {}, // TODO: Navigate to room detail
          )).toList(),
        );
      },
    );
  }
}

class _UserBookingsSection extends ConsumerWidget {
  final String userId;
  const _UserBookingsSection({required this.userId});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsync = ref.watch(roomListProvider);
    return roomsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Error: $e'),
      data: (rooms) {
        final myBookings = rooms.where((r) => r.bookedBy == userId).toList();
        if (myBookings.isEmpty) return const Text('No bookings yet.');
        return Column(
          children: myBookings.map((r) => ListTile(
            leading: r.images.isNotEmpty ? Image.network(r.images.first, width: 40, height: 40, fit: BoxFit.cover) : null,
            title: Text('${r.type} Room'),
            subtitle: Text('Booked'),
            trailing: Icon(Icons.chevron_right),
            onTap: () {}, // TODO: Navigate to room detail
          )).toList(),
        );
      },
    );
  }
} 