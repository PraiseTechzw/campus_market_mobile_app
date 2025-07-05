import 'package:flutter/material.dart';
import '../../domain/user_entity.dart';
import '../core/app_theme.dart';
import '../core/components/app_button.dart';

class ProfileInfoCard extends StatefulWidget {
  final UserEntity user;
  final bool editing;
  final bool loading;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final Function(String, String, String, String, String) onUpdateData;

  const ProfileInfoCard({
    super.key,
    required this.user,
    required this.editing,
    required this.loading,
    required this.onSave,
    required this.onCancel,
    required this.onUpdateData,
  });

  @override
  State<ProfileInfoCard> createState() => _ProfileInfoCardState();
}

class _ProfileInfoCardState extends State<ProfileInfoCard> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _schoolController;
  late TextEditingController _campusController;
  late TextEditingController _bioController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _phoneController = TextEditingController(text: widget.user.phone ?? '');
    _schoolController = TextEditingController(text: widget.user.school ?? '');
    _campusController = TextEditingController(text: widget.user.campus ?? '');
    _bioController = TextEditingController(text: widget.user.bio ?? '');
  }

  @override
  void didUpdateWidget(ProfileInfoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.editing != oldWidget.editing && widget.editing) {
      _nameController.text = widget.user.name;
      _phoneController.text = widget.user.phone ?? '';
      _schoolController.text = widget.user.school ?? '';
      _campusController.text = widget.user.campus ?? '';
      _bioController.text = widget.user.bio ?? '';
    }
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

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      widget.onUpdateData(
        _nameController.text.trim(),
        _phoneController.text.trim(),
        _schoolController.text.trim(),
        _campusController.text.trim(),
        _bioController.text.trim(),
      );
      widget.onSave();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: AppTheme.primaryColor, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Personal Information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (widget.editing) ...[
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      icon: Icons.person,
                      validator: (value) => value?.isEmpty == true ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      icon: Icons.phone,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _schoolController,
                      label: 'School',
                      icon: Icons.school,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _campusController,
                      label: 'Campus',
                      icon: Icons.location_on,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _bioController,
                      label: 'Bio',
                      icon: Icons.description,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            text: 'Cancel',
                            onPressed: widget.loading ? null : widget.onCancel,
                            expanded: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppButton(
                            text: widget.loading ? 'Saving...' : 'Save',
                            onPressed: widget.loading ? null : _handleSave,
                            expanded: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ] else ...[
              _buildInfoRow(Icons.phone, 'Phone', widget.user.phone ?? 'Not provided'),
              _buildInfoRow(Icons.school, 'School', widget.user.school ?? 'Not provided'),
              _buildInfoRow(Icons.location_on, 'Campus', widget.user.campus ?? 'Not provided'),
              if (widget.user.bio?.isNotEmpty == true) ...[
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Icon(Icons.description, color: AppTheme.primaryColor, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Bio',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              widget.user.bio!,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 