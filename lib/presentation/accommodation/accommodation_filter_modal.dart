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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withOpacity(0.2),
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
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
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
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                  ),
                  child: const Text(
                    'Clear All',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
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
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
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
                    inactiveColor: colorScheme.onSurface.withOpacity(0.2),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${_priceRange.start.round()}',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '\$${_priceRange.end.round()}',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Room Type
                  Text(
                    'Room Type',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: _roomTypes.map((type) {
                      final selected = _selectedType == type;
                      return FilterChip(
                        label: Text(
                          type,
                          style: TextStyle(
                            color: selected ? colorScheme.onPrimary : AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        selected: selected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedType = selected ? type : 'All';
                          });
                        },
                        selectedColor: AppTheme.primaryColor,
                        backgroundColor: colorScheme.surfaceVariant,
                        checkmarkColor: colorScheme.onPrimary,
                        side: BorderSide(
                          color: selected ? AppTheme.primaryColor : colorScheme.outline,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  // Location Filters
                  Text(
                    'Location',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // School Dropdown
                  _buildDropdown(
                    context,
                    label: 'School',
                    value: _selectedSchool,
                    items: ['All', 'University of Example', 'College of Technology', 'Business School'],
                    onChanged: (value) {
                      setState(() {
                        _selectedSchool = value ?? 'All';
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  // Campus Dropdown
                  _buildDropdown(
                    context,
                    label: 'Campus',
                    value: _selectedCampus,
                    items: ['All', 'Main Campus', 'North Campus', 'South Campus', 'Downtown Campus'],
                    onChanged: (value) {
                      setState(() {
                        _selectedCampus = value ?? 'All';
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  // City Dropdown
                  _buildDropdown(
                    context,
                    label: 'City',
                    value: _selectedCity,
                    items: ['All', 'New York', 'Los Angeles', 'Chicago', 'Houston', 'Phoenix'],
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
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _amenities.map((amenity) {
                      final selected = _selectedAmenities.contains(amenity);
                      return FilterChip(
                        label: Text(
                          amenity,
                          style: TextStyle(
                            color: selected ? colorScheme.onPrimary : AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        selected: selected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedAmenities.add(amenity);
                            } else {
                              _selectedAmenities.remove(amenity);
                            }
                          });
                        },
                        selectedColor: AppTheme.primaryColor,
                        backgroundColor: colorScheme.surfaceVariant,
                        checkmarkColor: colorScheme.onPrimary,
                        side: BorderSide(
                          color: selected ? AppTheme.primaryColor : colorScheme.outline,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  // Sort Options
                  Text(
                    'Sort By',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDropdown(
                    context,
                    label: 'Sort By',
                    value: _selectedSortBy,
                    items: [
                      'createdAt',
                      'price',
                      'location',
                    ],
                    itemLabels: const {
                      'createdAt': 'Date Posted',
                      'price': 'Price',
                      'location': 'Location',
                    },
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
                          title: Text(
                            'Newest First',
                            style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500, color: colorScheme.onSurface),
                          ),
                          value: true,
                          groupValue: _sortDescending,
                          activeColor: AppTheme.primaryColor,
                          onChanged: (value) {
                            setState(() {
                              _sortDescending = value ?? true;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<bool>(
                          title: Text(
                            'Oldest First',
                            style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500, color: colorScheme.onSurface),
                          ),
                          value: false,
                          groupValue: _sortDescending,
                          activeColor: AppTheme.primaryColor,
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

  Widget _buildDropdown(
    BuildContext context, {
    required String label,
    required String value,
    required List<String> items,
    Map<String, String>? itemLabels,
    required void Function(String?) onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface.withOpacity(0.7),
          fontWeight: FontWeight.w500,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.outline,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.outline,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppTheme.primaryColor,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: colorScheme.surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      style: textTheme.bodyLarge?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      dropdownColor: colorScheme.surfaceVariant,
      icon: Icon(
        Icons.keyboard_arrow_down,
        color: AppTheme.primaryColor,
      ),
      items: items
          .map((item) => DropdownMenuItem(
                value: item,
                child: Text(itemLabels != null ? itemLabels[item] ?? item : item),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }
} 