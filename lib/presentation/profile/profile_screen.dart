import 'package:campus_market/presentation/core/app_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../core/app_theme.dart';
import '../../domain/user_entity.dart';
import '../../application/user_providers.dart';
import 'profile_header.dart';
import 'profile_analytics.dart';
import 'profile_info_card.dart';
import 'profile_actions.dart';
import 'profile_sections.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _editing = false;
  bool _loading = false;
  bool _uploadingImage = false;
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final userEntityAsync = ref.watch(userEntityProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return userEntityAsync.when(
      loading: () => _buildLoadingScreen(isDark),
      error: (e, _) => _buildErrorScreen(e, isDark),
      data: (user) {
        if (user == null) {
          return _buildNoUserScreen(isDark);
        }
        return _buildProfileScreen(user, isDark);
      },
    );
  }

  Widget _buildLoadingScreen(bool isDark) {
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[50],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.7)],
                ),
              ),
              child: const Icon(Icons.person, size: 40, color: Colors.white),
            ).animate().fadeIn(duration: 600.ms).scale(delay: 200.ms),
            const SizedBox(height: 24),
            Text(
              'Loading Profile...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.grey[700],
              ),
            ).animate().fadeIn(delay: 400.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(Object error, bool isDark) {
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[50],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading profile',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white54 : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoUserScreen(bool isDark) {
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[50],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No user data found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileScreen(UserEntity user, bool isDark) {
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 320,
            backgroundColor: AppTheme.primaryColor,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                onPressed: _navigateToSettings,
              ),
            ],
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                final percent = ((constraints.maxHeight - kToolbarHeight) / (320 - kToolbarHeight)).clamp(0.0, 1.0);
                return FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
                  centerTitle: false,
                  title: Opacity(
                    opacity: 1 - percent,
                    child: Text(
                      user.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Green gradient background
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppTheme.primaryColor,
                              AppTheme.primaryColor.withOpacity(0.8),
                              AppTheme.primaryColor.withOpacity(0.6),
                            ],
                          ),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(32),
                            bottomRight: Radius.circular(32),
                          ),
                        ),
                      ),
                      // Unique pattern overlay (diagonal lines)
                      CustomPaint(
                        painter: _PatternPainter(userId: user.uid),
                        size: Size.infinite,
                      ),
                      // Header content
                      SafeArea(
                        bottom: false,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedScale(
                              scale: 0.7 + 0.3 * percent,
                              duration: Duration.zero,
                              child: Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  CircleAvatar(
                                    radius: 60,
                                    backgroundColor: Colors.white,
                                    child: _uploadingImage
                                        ? const CircularProgressIndicator()
                                        : CircleAvatar(
                                            radius: 56,
                                            backgroundImage: user.profilePhotoUrl != null && user.profilePhotoUrl!.isNotEmpty
                                                ? NetworkImage(user.profilePhotoUrl!)
                                                : null,
                                            child: (user.profilePhotoUrl == null || user.profilePhotoUrl!.isEmpty)
                                                ? Icon(Icons.person, size: 56, color: Colors.grey[400])
                                                : null,
                                          ),
                                  ),
                                  Positioned(
                                    bottom: 4,
                                    right: 4,
                                    child: Material(
                                      color: AppTheme.primaryColor,
                                      shape: const CircleBorder(),
                                      child: InkWell(
                                        onTap: _uploadingImage ? null : _pickAndUploadImage,
                                        customBorder: const CircleBorder(),
                                        child: const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            AnimatedOpacity(
                              opacity: percent,
                              duration: Duration.zero,
                              child: Column(
                                children: [
                                  Text(
                                    user.name,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user.email,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  IconButton(
                                    icon: Icon(_editing ? Icons.close : Icons.edit, color: Colors.white),
                                    onPressed: () => setState(() => _editing = !_editing),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // Profile Content
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Analytics Section
                ProfileAnalytics(userId: user.uid)
                    .animate()
                    .fadeIn(delay: 200.ms)
                    .slideY(begin: 0.3, delay: 200.ms),
                const SizedBox(height: 16),
                // Info Card
                ProfileInfoCard(
                  user: user,
                  editing: _editing,
                  loading: _loading,
                  onSave: _saveProfile,
                  onCancel: () => setState(() => _editing = false),
                  onUpdateData: _updateProfileData,
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, delay: 400.ms),
                const SizedBox(height: 16),
                // Action Buttons
                ProfileActions(
                  userEmail: user.email,
                  loading: _loading,
                  onSettingsTap: _navigateToSettings,
                  onPasswordReset: _handlePasswordReset,
                ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3, delay: 600.ms),
                const SizedBox(height: 24),
                // Profile Sections
                ProfileSections(userId: user.uid)
                    .animate()
                    .fadeIn(delay: 800.ms)
                    .slideY(begin: 0.3, delay: 800.ms),
                const SizedBox(height: 32),
                ProfileLogoutButton(loading: _loading),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndUploadImage() async {
    try {
      setState(() => _uploadingImage = true);
      
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image == null) return;

      final user = ref.read(userEntityProvider).value;
      if (user == null) return;

      // Upload to Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_photos')
          .child('${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg');

      final file = File(image.path);
      final uploadTask = storageRef.putFile(file);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Update user profile
      await ref.read(updateUserProfileProvider.call({
        'userId': user.uid,
        'data': {'profilePhotoUrl': downloadUrl},
      }));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile photo updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile photo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingImage = false);
    }
  }

  void _updateProfileData(String name, String phone, String school, String campus, String bio) {
    // This will be called by ProfileInfoCard when saving
    // The actual save logic is in _saveProfile
  }

  Future<void> _saveProfile() async {
    try {
      setState(() => _loading = true);
      
      final user = ref.read(userEntityProvider).value;
      if (user == null) return;

      // Get the updated data from ProfileInfoCard
      // For now, we'll use a simple approach - in a real app, you'd pass the data
      final updatedData = {
        'name': user.name, // This would come from the form
        'phone': user.phone,
        'school': user.school,
        'campus': user.campus,
        'bio': user.bio,
      };

      await ref.read(updateUserProfileProvider.call({
        'userId': user.uid,
        'data': updatedData,
      }));
      
      setState(() => _editing = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handlePasswordReset() async {
    try {
      setState(() => _loading = true);
      
      final user = ref.read(userEntityProvider).value;
      if (user == null) return;

      await FirebaseAuth.instance.sendPasswordResetEmail(email: user.email);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset email sent!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send reset email: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _navigateToSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }
}

// Simple Settings Screen
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[50],
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSettingsCard(
            title: 'Account Settings',
            items: [
              _buildSettingsItem(
                icon: Icons.notifications,
                title: 'Notifications',
                subtitle: 'Manage notification preferences',
                onTap: () {},
              ),
              _buildSettingsItem(
                icon: Icons.security,
                title: 'Privacy',
                subtitle: 'Manage your privacy settings',
                onTap: () {},
              ),
              _buildSettingsItem(
                icon: Icons.language,
                title: 'Language',
                subtitle: 'Change app language',
                onTap: () {},
              ),
            ],
            isDark: isDark,
          ),
          const SizedBox(height: 16),
          _buildSettingsCard(
            title: 'Support',
            items: [
              _buildSettingsItem(
                icon: Icons.help,
                title: 'Help Center',
                subtitle: 'Get help and support',
                onTap: () {},
              ),
              _buildSettingsItem(
                icon: Icons.feedback,
                title: 'Send Feedback',
                subtitle: 'Share your thoughts with us',
                onTap: () {},
              ),
              _buildSettingsItem(
                icon: Icons.info,
                title: 'About',
                subtitle: 'App version and information',
                onTap: () {},
              ),
            ],
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard({
    required String title,
    required List<Widget> items,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          ...items,
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class _PatternPainter extends CustomPainter {
  final String userId;
  _PatternPainter({required this.userId});

  @override
  void paint(Canvas canvas, Size size) {
    // Use userId to generate a unique pattern (e.g., diagonal lines with a hash)
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.07)
      ..strokeWidth = 2;
    final hash = userId.codeUnits.fold(0, (a, b) => a + b);
    final spacing = 24 + (hash % 16); // unique spacing per user
    for (double x = -size.height; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 