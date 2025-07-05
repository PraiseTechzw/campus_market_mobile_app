import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../core/app_theme.dart';
import '../core/components/app_text_input.dart';
import '../core/components/app_button.dart';
import 'dart:io';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../application/profile_provider.dart';

class ProfileCompletionScreen extends ConsumerStatefulWidget {
  final String email;
  final String name;
  const ProfileCompletionScreen({super.key, required this.email, required this.name});

  @override
  ConsumerState<ProfileCompletionScreen> createState() => _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends ConsumerState<ProfileCompletionScreen> {
  int _currentStep = 0;
  CountryCode _selectedCountryCode = CountryCode(code: 'ZW', dialCode: '+263', name: 'Zimbabwe');
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
  
  bool _isSaving = false;

  final _picker = ImagePicker();

  // Hardcoded Zimbabwean universities and campuses
  final Map<String, List<String>> zimbabweSchools = {
  // **State Universities**
  'University of Zimbabwe': [
    'Main Campus (Mount Pleasant, Harare)',
    'College of Health Sciences (Parirenyatwa Hospital, Harare)',
    'Satellite facilities in Bulawayo, Kariba, Teviotdale'
  ],
  'National University of Science and Technology': [
    'Main Campus (Ascot, Bulawayo)',
    'Faculty of Medicine (Mpilo Hospital, Bulawayo)',
    'Harare postgraduate facility'
  ],
  'Midlands State University': [
    'Main Campus (Gweru)',
    'TelOne Campus (Gweru)',
    'Batanai Campus (Gweru)',
    'Harare Campus',
    'Mutare Campus',
    'Zvishavane Campus'
  ],
  'Chinhoyi University of Technology': ['Main Campus (Chinhoyi)'],
  'Bindura University of Science Education': ['Main Campus (Bindura)'],
  'Harare Institute of Technology': ['Main Campus (Harare)'],
  'Lupane State University': ['Main Campus (Lupane)'],
  'Gwanda State University': ['Main Campus (Gwanda)'],
  'Manicaland State University of Applied Sciences': ['Main Campus (Mutare)'],
  'Marondera University of Agricultural Sciences & Technology': ['Main Campus (Marondera)'],
  'Pan African University of Minerals Processing & Technology': ['Main Campus'],
  'Zimbabwe National Defence University': ['Main Campus'],
  'Zimbabwe Open University': ['Main Campus (Harare) + distance learning centres nationwide'],

  // **Private Universities**
  'Africa University': ['Main Campus (Mutare)'],
  'Arrupe Jesuit University': ['Main Campus (Mount Pleasant, Harare)'],
  'Catholic University in Zimbabwe': ['Main Campus (Hatfield, Harare)'],
  'Reformed Church University': ['Main Campus (Lupane?)'], // exact location less clear
  'Solusi University': ['Main Campus (Bulawayo)'],
  "Women's University in Africa": ['Main Campus (Marondera)'],
  'Zimbabwe Ezekiel Guti University': ['Main Campus (Harare)'],

  // **Polytechnic Colleges**
  'Harare Polytechnic': ['Main Campus (Harare)'],
  'Bulawayo Polytechnic': ['Main Campus (Bulawayo)'],
  'Gweru Polytechnic': ['Main Campus (Gweru)'],
  'Mutare Polytechnic': ['Main Campus (Mutare)'],
  'Kwekwe Polytechnic': ['Main Campus (Kwekwe)'],
  'Joshua Mqabuko Nkomo Polytechnic': ['Main Campus (Gweru)'],
  'Masvingo Polytechnic': ['Main Campus (Masvingo)'],
  'Kushinga Phikelela Polytechnic': ['Main Campus (Zvishavane?)'],

  // **Teachers' Colleges**
  'Bondolfi Teachers\' College': ['Main Campus (Rusape?)'],
  'Belvedere Technical Teachers\' College': ['Main Campus (Harare)'],
  'Morgenster Teachers\' College': ['Main Campus (Harare)'],
  'Marymount Teachers\' College': ['Main Campus (Harare)'],
  'Mkoba Teachers\' College': ['Main Campus (Gweru)'],
  'Hillside Teachers\' College': ['Main Campus (Bulawayo)'],
  'Madziwa Teachers\' College': ['Main Campus (Madziwa)'],
  'Masvingo Teachers\' College': ['Main Campus (Masvingo)'],
  'Morgan Zintec Teachers\' College': ['Main Campus (Harare)'],
  'Mutare Teachers\' College': ['Main Campus (Mutare)'],
  'Nyadire Teachers\' College': ['Main Campus (Nyadire)'],
  'Seke Teachers\' College': ['Main Campus (Chitungwiza)'],
  'United College of Education': ['Main Campus (Chegutu?)'],

  // **Industrial Training Centres**
  'Westgate Industrial Training College': ['Main Campus (Harare)'],
  'Mupfure Industrial Training College': ['Main Campus (Mupfure)'],
  'Msasa Industrial Training College': ['Main Campus (Msasa)'],
  'Danhiko Project (ITC)': ['Main Campus'],
  'St Peters Kubatana': ['Main Campus (Harare?)'],
};


  List<String> get _schoolList {
    if (_selectedCountryCode.code == 'ZW') {
      final schools = zimbabweSchools.keys.toList();
      schools.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      return schools;
    }
    // Add more countries here if needed
    return [];
  }

  List<String> get _campusList {
    if (_selectedCountryCode.code == 'ZW') {
      return zimbabweSchools[_schoolController.text] ?? [];
    }
    // Add more countries here if needed
    return [];
  }

  List<Step> get _steps => [
    Step(
      title: const Text('Basic Info'),
      content: Builder(
        builder: (context) {
          final maxHeight = MediaQuery.of(context).size.height * 0.6;
          return ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextInput(label: 'Full Name', controller: TextEditingController(text: widget.name)),
                  const SizedBox(height: 16),
                  AppTextInput(label: 'Email', controller: TextEditingController(text: widget.email)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      CountryCodePicker(
                        onChanged: (code) {
                          setState(() {
                            _selectedCountryCode = code;
                            _schoolController.clear();
                            _campusController.clear();
                          });
                        },
                        initialSelection: 'ZW',
                        favorite: const ['+263', 'ZW'],
                        showCountryOnly: false,
                        showOnlyCountryWhenClosed: false,
                        alignLeft: false,
                        textStyle: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: AppTextInput(
                          label: 'Phone Number',
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          icon: Icons.phone,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Enter phone number';
                            if (_selectedCountryCode.code == 'ZW' && !RegExp(r'^(7|1)\d{8}').hasMatch(v)) {
                              return 'Enter a valid Zimbabwean phone number';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Include your country code. Zimbabwe is default.', style: TextStyle(color: AppTheme.primaryColor , fontSize: 12)),
                ],
              ),
            ),
          );
        },
      ),
      isActive: _currentStep >= 0,
    ),
    Step(
      title: const Text('School & Campus'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('School/University', style: TextStyle(fontWeight: FontWeight.w600)),
          LayoutBuilder(
            builder: (context, constraints) {
              return ConstrainedBox(
                constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                child: DropdownButtonFormField<String>(
                  value: _schoolController.text.isNotEmpty ? _schoolController.text : null,
                  items: _schoolList.map((school) => DropdownMenuItem(
                    value: school,
                    child: Text(school),
                  )).toList(),
                  onChanged: (val) {
                    setState(() {
                      _schoolController.text = val ?? '';
                      _campusController.clear();
                    });
                  },
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'School/University',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Select your school/university' : null,
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Text('Campus', style: TextStyle(fontWeight: FontWeight.w600)),
          DropdownButtonFormField<String>(
            value: _campusController.text.isNotEmpty ? _campusController.text : null,
            items: _campusList.map((campus) => DropdownMenuItem(
              
              value: campus,
              child: Text(campus),
            )).toList(),
            onChanged: (val) {
              setState(() {
                _campusController.text = val ?? '';
                _locationController.text = val ?? '';
              });
            },
            isExpanded: true,
            decoration: InputDecoration(
              labelText: 'Campus',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (v) => v == null || v.isEmpty ? 'Select your campus' : null,
          ),
          const SizedBox(height: 8),
          Text('Schools and campuses update based on your country and school selection.', style: TextStyle(color: AppTheme.primaryColor, fontSize: 12)),
        ],
      ),
      isActive: _currentStep >= 1,
    ),
    Step(
      title: const Text('Student Verification'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextInput(
            label: 'Student ID Number',
            controller: _studentIdController,
            icon: Icons.badge,
            validator: (v) => v == null || v.isEmpty ? 'Enter your student ID number' : null,
          ),
          const SizedBox(height: 16),
          Text(
            'Upload a clear photo of your valid student ID card.\n\nInstructions:\n• The ID must be your own and not expired.\n• All text and your photo must be clearly visible.\n• Take the photo in good lighting, avoid glare and blur.\n• You can take a new photo or upload from your gallery.',
            style: TextStyle(color: AppTheme.primaryColor, fontSize: 14),
          ),
          const SizedBox(height: 12),
          if (_studentIdPhoto != null)
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(_studentIdPhoto!.path),
                  width: 180,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          const SizedBox(height: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload/Take Student ID Photo'),
                onPressed: () async {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => SafeArea(
                      child: Wrap(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.camera_alt),
                            title: const Text('Take Photo'),
                            onTap: () async {
                              Navigator.pop(context);
                              final picked = await _picker.pickImage(source: ImageSource.camera, imageQuality: 90);
                              if (picked != null) setState(() => _studentIdPhoto = picked);
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.photo_library),
                            title: const Text('Choose from Gallery'),
                            onTap: () async {
                              Navigator.pop(context);
                              final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 90);
                              if (picked != null) setState(() => _studentIdPhoto = picked);
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.info_outline),
                            title: const Text('Photo Tips'),
                            onTap: () {
                              Navigator.pop(context);
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Tips for a Good Student ID Photo'),
                                  content: const Text(
                                    '• Place your ID on a flat surface in good light.\n'
                                    '• Make sure all corners are visible.\n'
                                    '• Avoid glare, shadows, and blur.\n'
                                    '• Check that your name, photo, and ID number are readable.'
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          if (_studentIdPhoto == null)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text('Please upload a clear photo of your student ID.', style: TextStyle(color: Colors.red)),
            ),
        ],
      ),
      isActive: _currentStep >= 2,
    ),
    Step(
      title: const Text('Location'),
      content: AppTextInput(label: 'Location (City, State)', controller: _locationController, icon: Icons.location_on, validator: (v) => v == null || v.isEmpty ? 'Enter location' : null),
      isActive: _currentStep >= 3,
    ),
    Step(
      title: const Text('Profile & Bio'),
      content: Builder(
        builder: (context) {
          final maxHeight = MediaQuery.of(context).size.height * 0.6;
          return ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add your profile photo, date of birth, gender, and a short bio.\n\nYou must be at least 18 years old to use this app.',
                    style: TextStyle(color: AppTheme.primaryColor, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: _profilePhoto != null ? FileImage(File(_profilePhoto!.path)) : null,
                          child: _profilePhoto == null
                              ? const Icon(Icons.person, size: 64, color: Colors.grey)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () async {
                              final picked = await _picker.pickImage(source: ImageSource.gallery);
                              if (picked != null) setState(() => _profilePhoto = picked);
                            },
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: AppTheme.primaryColor,
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () async {
                      final now = DateTime.now();
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime(now.year - 18, now.month, now.day),
                        firstDate: DateTime(1900),
                        lastDate: DateTime(now.year - 18, now.month, now.day),
                        helpText: 'Select your date of birth (18+ only)',
                      );
                      if (picked != null) {
                        _dobController.text = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                        setState(() {});
                      }
                    },
                    child: AbsorbPointer(
                      child: AppTextInput(
                        label: 'Date of Birth (18+)',
                        controller: _dobController,
                        icon: Icons.cake,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Select your date of birth';
                          final dob = DateTime.tryParse(v);
                          if (dob == null) return 'Invalid date';
                          final now = DateTime.now();
                          final age = now.year - dob.year - ((now.month < dob.month || (now.month == dob.month && now.day < dob.day)) ? 1 : 0);
                          if (age < 18) return 'You must be at least 18 years old';
                          return null;
                        },
                      ),
                    ),
                  ),
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
            ),
          );
        },
      ),
      isActive: _currentStep >= 4,
    ),
    Step(
      title: const Text('All Done!'),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.verified, color: AppTheme.primaryColor, size: 64),
          const SizedBox(height: 24),
          Text(
            'Profile Complete!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'You can now enjoy the full experience. If you want to sell or list accommodation, please wait for admin verification.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          if (!_profileComplete)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Please complete the following fields:',
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    ..._missingFields.map((f) => Text('• $f', style: const TextStyle(color: Colors.red))),
                  ],
                ),
              ),
            ),
          AppButton(
            text: 'Go to Home',
            expanded: false,
            onPressed: _profileComplete
                ? () => Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false)
                : null,
          ),
        ],
      ),
      isActive: _currentStep >= 5,
      state: _currentStep == 5 ? StepState.complete : StepState.indexed,
    ),
  ];

  void _continue() {
    if (_currentStep < _steps.length - 1) {
      setState(() => _currentStep++);
    } else {
      // Already at final step, do nothing (button handles navigation)
    }
  }

  void _cancel() {
    if (_currentStep > 0) setState(() => _currentStep--);
  }

  bool get _profileComplete {
    return _phoneController.text.isNotEmpty &&
      _schoolController.text.isNotEmpty &&
      _campusController.text.isNotEmpty &&
      _studentIdController.text.isNotEmpty &&
      _studentIdPhoto != null &&
      _locationController.text.isNotEmpty &&
      _dobController.text.isNotEmpty &&
      _gender != null &&
      _profilePhoto != null;
  }

  // Returns a list of missing required fields for user feedback
  List<String> get _missingFields {
    final missing = <String>[];
    if (_phoneController.text.isEmpty) missing.add('Phone Number');
    if (_schoolController.text.isEmpty) missing.add('School/University');
    if (_campusController.text.isEmpty) missing.add('Campus');
    if (_studentIdController.text.isEmpty) missing.add('Student ID');
    if (_studentIdPhoto == null) missing.add('Student ID Photo');
    if (_locationController.text.isEmpty) missing.add('Location');
    if (_dobController.text.isEmpty) missing.add('Date of Birth');
    if (_gender == null) missing.add('Gender');
    if (_profilePhoto == null) missing.add('Profile Photo');
    return missing;
  }

  Future<void> _saveProfile() async {
    if (!_profileComplete) return;
    setState(() => _isSaving = true);
    try {
      // Upload student ID photo
      String? studentIdPhotoUrl;
      if (_studentIdPhoto != null) {
        studentIdPhotoUrl = await ref.read(profileProvider.notifier).uploadStudentId(_studentIdPhoto!.path);
      }
      // Upload profile photo
      String? profilePhotoUrl;
      if (_profilePhoto != null) {
        final uid = await Future.value(ref.read(profileProvider.notifier));
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) throw Exception('Not logged in');
        final refStorage = FirebaseStorage.instance.ref('profile_photos/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg');
        final upload = await refStorage.putFile(File(_profilePhoto!.path));
        profilePhotoUrl = await upload.ref.getDownloadURL();
      }
      // Update profile in Firestore
      await ref.read(profileProvider.notifier).updateProfile({
        'name': widget.name,
        'email': widget.email,
        'phone': _phoneController.text.trim(),
        'school': _schoolController.text.trim(),
        'campus': _campusController.text.trim(),
        'studentId': _studentIdController.text.trim(),
        'studentIdPhotoUrl': studentIdPhotoUrl,
        'location': _locationController.text.trim(),
        'dateOfBirth': _dobController.text.trim(),
        'gender': _gender,
        'profilePhotoUrl': profilePhotoUrl,
        'bio': _bioController.text.trim(),
        'verificationStatus': 'pending',
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved successfully!')),
      );
      await Future.delayed(const Duration(milliseconds: 500));
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save profile: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.school, size: 36, color: AppTheme.primaryColor),
                    const SizedBox(width: 10),
                    Text(
                      'Complete Your Profile',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: (_currentStep + 1) / _steps.length,
                  backgroundColor: Colors.grey[200],
                  color: AppTheme.primaryColor,
                  minHeight: 6,
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: Stack(
                      children: [
                        Stepper(
                          key: ValueKey(_currentStep),
                          currentStep: _currentStep,
                          onStepContinue: _currentStep == _steps.length - 1
                              ? null // handled in controlsBuilder
                              : _continue,
                          onStepCancel: _cancel,
                          steps: _steps,
                          controlsBuilder: (BuildContext context, ControlsDetails details) {
                            final isLast = _currentStep == _steps.length - 1;
                            return Row(
                              children: [
                                AppButton(
                                  text: isLast
                                      ? (_isSaving
                                          ? 'Saving...'
                                          : 'Finish')
                                      : 'Next',
                                  expanded: false,
                                  onPressed: isLast
                                      ? (_profileComplete && !_isSaving ? _saveProfile : null)
                                      : details.onStepContinue,
                                ),
                                if (_isSaving && isLast)
                                  const Padding(
                                    padding: EdgeInsets.only(left: 12),
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blue),
                                    ),
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
                        if (_isSaving)
                          Positioned.fill(
                            child: Container(
                              color: Colors.black.withOpacity(0.1),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 