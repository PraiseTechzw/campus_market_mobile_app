import 'package:flutter/material.dart';

class FilterModalScreen extends StatefulWidget {
  final List<String> categories;
  final Map<String, dynamic> initialFilters;
  final void Function(Map<String, dynamic> filters) onApply;
  final VoidCallback onClear;

  const FilterModalScreen({
    Key? key,
    required this.categories,
    required this.initialFilters,
    required this.onApply,
    required this.onClear,
  }) : super(key: key);

  @override
  State<FilterModalScreen> createState() => _FilterModalScreenState();
}

class _FilterModalScreenState extends State<FilterModalScreen> {
  late String selectedCategory;
  late String selectedCondition;
  late String selectedSort;
  RangeValues priceRange = const RangeValues(0, 100000);

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.initialFilters['category'] ?? 'All';
    selectedCondition = widget.initialFilters['condition'] ?? 'All';
    selectedSort = widget.initialFilters['sort'] ?? 'Newest';
    priceRange = widget.initialFilters['priceRange'] ?? const RangeValues(0, 100000);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('Category', style: Theme.of(context).textTheme.titleMedium),
            ),
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: widget.categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = widget.categories[index];
                  return ChoiceChip(
                    label: Text(cat),
                    selected: selectedCategory == cat,
                    onSelected: (_) => setState(() => selectedCategory = cat),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('Price Range (₦${priceRange.start.toInt()} - ₦${priceRange.end.toInt()})', style: Theme.of(context).textTheme.titleMedium),
            ),
            RangeSlider(
              min: 0,
              max: 100000,
              divisions: 100,
              values: priceRange,
              onChanged: (values) => setState(() => priceRange = values),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('Condition', style: Theme.of(context).textTheme.titleMedium),
            ),
            Row(
              children: [
                const SizedBox(width: 16),
                ChoiceChip(
                  label: const Text('All'),
                  selected: selectedCondition == 'All',
                  onSelected: (_) => setState(() => selectedCondition = 'All'),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('New'),
                  selected: selectedCondition == 'New',
                  onSelected: (_) => setState(() => selectedCondition = 'New'),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Used'),
                  selected: selectedCondition == 'Used',
                  onSelected: (_) => setState(() => selectedCondition = 'Used'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('Sort By', style: Theme.of(context).textTheme.titleMedium),
            ),
            Row(
              children: [
                const SizedBox(width: 16),
                ChoiceChip(
                  label: const Text('Newest'),
                  selected: selectedSort == 'Newest',
                  onSelected: (_) => setState(() => selectedSort = 'Newest'),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Price ↑'),
                  selected: selectedSort == 'PriceAsc',
                  onSelected: (_) => setState(() => selectedSort = 'PriceAsc'),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Price ↓'),
                  selected: selectedSort == 'PriceDesc',
                  onSelected: (_) => setState(() => selectedSort = 'PriceDesc'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      widget.onClear();
                      Navigator.pop(context);
                    },
                    child: const Text('Clear'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onApply({
                        'category': selectedCategory,
                        'priceRange': priceRange,
                        'condition': selectedCondition,
                        'sort': selectedSort,
                      });
                      Navigator.pop(context);
                    },
                    child: const Text('Apply'),
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
} 