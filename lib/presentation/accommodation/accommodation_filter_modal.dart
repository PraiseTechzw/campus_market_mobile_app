import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../core/app_theme.dart';
import '../core/components/app_button.dart';
import '../../application/room_providers.dart';

class AccommodationFilterModal extends StatefulWidget {
  const AccommodationFilterModal({super.key});

  @override
  State<AccommodationFilterModal> createState() => _AccommodationFilterModalState();
}

class _AccommodationFilterModalState extends State<AccommodationFilterModal> {
  RangeValues _priceRange = const RangeValues(0, 2000);
  String _selectedType = 'All';
  String _selectedSortBy = 'createdAt';
  bool _sortDescending = true;
  final Set<String> _selectedAmenities = {};
  String _selectedSchool = 'All';
  String _selectedCampus = 'All';
  String _selectedCity = 'All';

  final List<String> _roomTypes = ['All', 'single', '2-share', '3-share'];
  final List<String> _amenities = [
    'WiFi',
    'Kitchen',
    'Bathroom',
    'Furnished',
    'Air Conditioning',
    'Heating',
    'Laundry',
    'Parking',
    'Gym',
    'Study Room',
    'Balcony',
    'Security',
  ];
  final List<String> _sortOptions = [
    'createdAt',
    'price',
    'location',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filters',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _priceRange = const RangeValues(0, 2000);
                      _selectedType = 'All';
                      _selectedSortBy = 'createdAt';
                      _sortDescending = true;
                      _selectedAmenities.clear();
                      _selectedSchool = 'All';
                      _selectedCampus = 'All';
                      _selectedCity = 'All';
                    });
                  },
                  child: const Text('Clear All'),
                ),
              ],
            ),
          ),
          // Filter Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price Range
                  Text(
                    'Price Range',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  RangeSlider(
                    values: _priceRange,
                    min: 0,
                    max: 2000,
                    divisions: 40,
                    labels: RangeLabels(
                      '\$${_priceRange.start.round()}',
                      '\$${_priceRange.end.round()}',
                    ),
                    onChanged: (values) {
                      setState(() {
                        _priceRange = values;
                      });
                    },
                    activeColor: AppTheme.primaryColor,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('\$${_priceRange.start.round()}'),
                      Text('\$${_priceRange.end.round()}'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Room Type
                  Text(
                    'Room Type',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: _roomTypes.map((type) {
                      return FilterChip(
                        label: Text(type),
                        selected: _selectedType == type,
                        onSelected: (selected) {
                          setState(() {
                            _selectedType = selected ? type : 'All';
                          });
                        },
                        selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                        checkmarkColor: AppTheme.primaryColor,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  // Location Filters
                  Text(
                    'Location',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // School Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedSchool,
                    decoration: const InputDecoration(
                      labelText: 'School',
                      border: OutlineInputBorder(),
                    ),
                    items: ['All', 'University of Example', 'College of Technology', 'Business School']
                        .map((school) => DropdownMenuItem(
                              value: school,
                              child: Text(school),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedSchool = value ?? 'All';
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  // Campus Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedCampus,
                    decoration: const InputDecoration(
                      labelText: 'Campus',
                      border: OutlineInputBorder(),
                    ),
                    items: ['All', 'Main Campus', 'North Campus', 'South Campus', 'Downtown Campus']
                        .map((campus) => DropdownMenuItem(
                              value: campus,
                              child: Text(campus),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCampus = value ?? 'All';
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  // City Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedCity,
                    decoration: const InputDecoration(
                      labelText: 'City',
                      border: OutlineInputBorder(),
                    ),
                    items: ['All', 'New York', 'Los Angeles', 'Chicago', 'Houston', 'Phoenix']
                        .map((city) => DropdownMenuItem(
                              value: city,
                              child: Text(city),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCity = value ?? 'All';
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  // Amenities
                  Text(
                    'Amenities',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _amenities.map((amenity) {
                      return FilterChip(
                        label: Text(amenity),
                        selected: _selectedAmenities.contains(amenity),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedAmenities.add(amenity);
                            } else {
                              _selectedAmenities.remove(amenity);
                            }
                          });
                        },
                        selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                        checkmarkColor: AppTheme.primaryColor,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  // Sort Options
                  Text(
                    'Sort By',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedSortBy,
                    decoration: const InputDecoration(
                      labelText: 'Sort By',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(value: 'createdAt', child: Text('Date Posted')),
                      DropdownMenuItem(value: 'price', child: Text('Price')),
                      DropdownMenuItem(value: 'location', child: Text('Location')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedSortBy = value ?? 'createdAt';
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  // Sort Direction
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<bool>(
                          title: const Text('Newest First'),
                          value: true,
                          groupValue: _sortDescending,
                          onChanged: (value) {
                            setState(() {
                              _sortDescending = value ?? true;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<bool>(
                          title: const Text('Oldest First'),
                          value: false,
                          groupValue: _sortDescending,
                          onChanged: (value) {
                            setState(() {
                              _sortDescending = value ?? false;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          // Apply Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: Consumer(
              builder: (context, ref, child) {
                return SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    onPressed: () {
                      // Update the filter provider
                      ref.read(accommodationFilterProvider.notifier).updateFilters(
                        school: _selectedSchool == 'All' ? null : _selectedSchool,
                        campus: _selectedCampus == 'All' ? null : _selectedCampus,
                        city: _selectedCity == 'All' ? null : _selectedCity,
                        type: _selectedType == 'All' ? null : _selectedType,
                        amenities: _selectedAmenities.isEmpty ? null : _selectedAmenities.toList(),
                        minPrice: _priceRange.start,
                        maxPrice: _priceRange.end,
                        sortBy: _selectedSortBy,
                        descending: _sortDescending,
                      );
                      Navigator.pop(context);
                    },
                    text: 'Apply Filters',
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 