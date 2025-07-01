import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../core/app_theme.dart';
import '../core/components/app_text_input.dart';
import '../core/components/app_button.dart';
import 'dart:io';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:phonecodes/phonecodes.dart';

class ProfileCompletionScreen extends StatefulWidget {
  final String email;
  final String name;
  const ProfileCompletionScreen({Key? key, required this.email, required this.name}) : super(key: key);

  @override
  State<ProfileCompletionScreen> createState() => _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends State<ProfileCompletionScreen> {
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
  bool _loading = false;
  String? _error;

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
      return zimbabweSchools.keys.toList();
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
      content: Column(
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
                    // Zimbabwe phone validation: 9 digits, starts with 7 or 1
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
          Text('Include your country code. Zimbabwe is default.', style: TextStyle(color: Colors.grey[700], fontSize: 12)),
        ],
      ),
      isActive: _currentStep >= 0,
    ),
    Step(
      title: const Text('School & Campus'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownSearch<String>(
            items: _schoolList,
            selectedItem: _schoolController.text.isNotEmpty ? _schoolController.text : null,
            dropdownSearchDecoration: InputDecoration(
              labelText: 'School/University',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: (val) {
              setState(() {
                _schoolController.text = val ?? '';
                _campusController.clear();
              });
            },
            validator: (v) => v == null || v.isEmpty ? 'Select your school/university' : null,
            popupProps: const PopupProps.menu(showSearchBox: true),
          ),
          const SizedBox(height: 16),
          DropdownSearch<String>(
            items: _campusList,
            selectedItem: _campusController.text.isNotEmpty ? _campusController.text : null,
            dropdownSearchDecoration: InputDecoration(
              labelText: 'Campus',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: (val) {
              setState(() {
                _campusController.text = val ?? '';
                // Update location field automatically
                _locationController.text = val ?? '';
              });
            },
            validator: (v) => v == null || v.isEmpty ? 'Select your campus' : null,
            popupProps: const PopupProps.menu(showSearchBox: true),
          ),
          const SizedBox(height: 8),
          Text('Schools and campuses update based on your country and school selection.', style: TextStyle(color: Colors.grey[700], fontSize: 12)),
        ],
      ),
      isActive: _currentStep >= 1,
    ),
    Step(
      title: const Text('Student Verification'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextInput(label: 'Student ID Number', controller: _studentIdController, icon: Icons.badge, validator: (v) => v == null || v.isEmpty ? 'Enter student ID' : null),
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
              if (_studentIdPhoto != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(_studentIdPhoto!.path),
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  ),
                ),
            ],
          ),
          if (_studentIdPhoto == null)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text('Please upload your student ID photo.', style: TextStyle(color: Colors.red)),
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
              if (_profilePhoto != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(_profilePhoto!.path),
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  ),
                ),
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
          AppButton(
            text: 'Go to Home',
            expanded: false,
            onPressed: _profileComplete
                ? () => Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false)
                : null,
          ),
          if (!_profileComplete)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text('Please complete all required fields before continuing.', style: TextStyle(color: Colors.red)),
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
      _locationController.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
       
        child: SafeArea(
          child: SingleChildScrollView(
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
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: Stepper(
                      key: ValueKey(_currentStep),
                      currentStep: _currentStep,
                      onStepContinue: _continue,
                      onStepCancel: _cancel,
                      steps: _steps,
                      controlsBuilder: (BuildContext context, ControlsDetails details) {
                        return Row(
                          children: [
                            AppButton(
                              text: _currentStep == _steps.length - 1 ? 'Finish' : 'Next',
                              expanded: false,
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 