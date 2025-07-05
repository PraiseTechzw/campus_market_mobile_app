import 'package:flutter/material.dart';
import '../../domain/user_entity.dart';
import '../core/app_theme.dart';

class ProfileHeader extends StatelessWidget {
  final UserEntity user;
  final bool uploadingImage;
  final VoidCallback onEditPhoto;
  final VoidCallback onEditProfile;
  final bool editing;

  const ProfileHeader({
    super.key,
    required this.user,
    required this.uploadingImage,
    required this.onEditPhoto,
    required this.onEditProfile,
    required this.editing,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white,
                  child: uploadingImage
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
                      onTap: uploadingImage ? null : onEditPhoto,
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
            const SizedBox(height: 16),
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
              icon: Icon(editing ? Icons.close : Icons.edit, color: Colors.white),
              onPressed: onEditProfile,
            ),
          ],
        ),
      ),
    );
  }
} 