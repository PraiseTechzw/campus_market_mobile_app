import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../core/app_theme.dart';
import '../core/components/app_text_input.dart';
import '../core/components/app_button.dart';

class ProfileCompletionScreen extends StatefulWidget {
  final String email;
  final String name;
  const ProfileCompletionScreen({Key? key, required this.email, required this.name}) : super(key: key);

  @override
  State<ProfileCompletionScreen> createState() => _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends State<ProfileCompletionScreen> {
  int _currentStep = 0;
  final _phoneController = TextEditingController();
  final _schoolController = TextEditingController();
  final _campusController = TextEditingController();
  final _studentIdController = TextEditingController();
  XFile? _studentIdPhoto;
  final _locationController = TextEditingController();
  final _dobController = TextEditingController();
  String? _gender;
  XFile? _profilePhoto;
  final _bioController = TextEditingController();
  bool _loading = false;
  String? _error;

  final _picker = ImagePicker();

  List<Step> get _steps => [
    Step(
      title: const Text('Basic Info'),
      content: Column(
        children: [
          AppTextInput(label: 'Full Name', controller: TextEditingController(text: widget.name)),
          const SizedBox(height: 16),
          AppTextInput(label: 'Email', controller: TextEditingController(text: widget.email)),
          const SizedBox(height: 16),
          AppTextInput(label: 'Phone Number', controller: _phoneController, keyboardType: TextInputType.phone, icon: Icons.phone),
        ],
      ),
      isActive: _currentStep >= 0,
    ),
    Step(
      title: const Text('School & Campus'),
      content: Column(
        children: [
          AppTextInput(label: 'School/University', controller: _schoolController, icon: Icons.school),
          const SizedBox(height: 16),
          AppTextInput(label: 'Campus', controller: _campusController, icon: Icons.location_city),
        ],
      ),
      isActive: _currentStep >= 1,
    ),
    Step(
      title: const Text('Student Verification'),
      content: Column(
        children: [
          AppTextInput(label: 'Student ID Number', controller: _studentIdController, icon: Icons.badge),
          const SizedBox(height: 16),
          Row(
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload Student ID Photo'),
                onPressed: () async {
                  final picked = await _picker.pickImage(source: ImageSource.gallery);
                  if (picked != null) setState(() => _studentIdPhoto = picked);
                },
              ),
              const SizedBox(width: 12),
              if (_studentIdPhoto != null) const Icon(Icons.check_circle, color: Colors.green),
            ],
          ),
        ],
      ),
      isActive: _currentStep >= 2,
    ),
    Step(
      title: const Text('Location'),
      content: AppTextInput(label: 'Location (City, State)', controller: _locationController, icon: Icons.location_on),
      isActive: _currentStep >= 3,
    ),
    Step(
      title: const Text('Profile & Bio'),
      content: Column(
        children: [
          Row(
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.photo_camera),
                label: const Text('Upload Profile Photo'),
                onPressed: () async {
                  final picked = await _picker.pickImage(source: ImageSource.gallery);
                  if (picked != null) setState(() => _profilePhoto = picked);
                },
              ),
              const SizedBox(width: 12),
              if (_profilePhoto != null) const Icon(Icons.check_circle, color: Colors.green),
            ],
          ),
          const SizedBox(height: 16),
          AppTextInput(label: 'Date of Birth', controller: _dobController, icon: Icons.cake),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _gender,
            items: const [
              DropdownMenuItem(value: 'male', child: Text('Male')),
              DropdownMenuItem(value: 'female', child: Text('Female')),
              DropdownMenuItem(value: 'other', child: Text('Other')),
            ],
            onChanged: (v) => setState(() => _gender = v),
            decoration: const InputDecoration(labelText: 'Gender'),
          ),
          const SizedBox(height: 16),
          AppTextInput(label: 'Bio (optional)', controller: _bioController, icon: Icons.info_outline),
        ],
      ),
      isActive: _currentStep >= 4,
    ),
  ];

  void _continue() {
    if (_currentStep < _steps.length - 1) {
      setState(() => _currentStep++);
    } else {
      // Submit profile completion
      // TODO: Implement submission logic
    }
  }

  void _cancel() {
    if (_currentStep > 0) setState(() => _currentStep--);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Your Profile')),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: _continue,
        onStepCancel: _cancel,
        steps: _steps,
        controlsBuilder: (BuildContext context, ControlsDetails details) {
          return Row(
            children: [
              AppButton(
                text: _currentStep == _steps.length - 1 ? 'Finish' : 'Next',
                onPressed: details.onStepContinue,
              ),
              if (_currentStep > 0)
                TextButton(
                  onPressed: details.onStepCancel,
                  child: const Text('Back'),
                ),
            ],
          );
        },
      ),
    );
  }
} 