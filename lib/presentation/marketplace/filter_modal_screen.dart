import 'package:campus_market/presentation/core/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FilterModalScreen extends StatefulWidget {
  final List<String> categories;
  final Map<String, dynamic> initialFilters;
  final void Function(Map<String, dynamic> filters) onApply;
  final VoidCallback onClear;

  const FilterModalScreen({
    super.key,
    required this.categories,
    required this.initialFilters,
    required this.onApply,
    required this.onClear,
  });

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
    // Category icons
    final categoryIcons = {
      'All': Icons.apps,
      'Electronics': Icons.devices_other,
      'Fashion': Icons.checkroom,
      'Books': Icons.menu_book,
      'Furniture': Icons.chair,
      'Sports': Icons.sports_soccer,
      'Beauty': Icons.face,
      'Others': Icons.more_horiz,
    };
    // Condition icons
    final conditionIcons = {
      'All': Icons.all_inclusive,
      'New': Icons.fiber_new,
      'Used': Icons.replay,
    };
    // Sort icons
    final sortIcons = {
      'Newest': Icons.fiber_new,
      'PriceAsc': FontAwesomeIcons.arrowUp,
      'PriceDesc': FontAwesomeIcons.arrowDown,
    };

    return Container(
      decoration:  BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
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
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Icon(Icons.tune, color: Colors.blue[600], size: 24),
                    const SizedBox(width: 8),
                    const Text(
                      'Filter & Sort',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Icon(Icons.apps, color: Colors.blueGrey),
                ],
              ),
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
                    label: Row(
                      children: [
                        Icon(categoryIcons[cat] ?? Icons.apps, size: 18),
                        const SizedBox(width: 4),
                        Text(cat),
                      ],
                    ),
                    selected: selectedCategory == cat,
                    onSelected: (_) => setState(() => selectedCategory = cat),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Text('Price Range', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Icon(Icons.attach_money, color: Colors.green),
                  const SizedBox(width: 8),
                  Text('(4${priceRange.start.toInt()} - 4${priceRange.end.toInt()})', style: const TextStyle(color: Colors.green)),
                ],
              ),
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
              child: Row(
                children: [
                  const Text('Condition', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Icon(Icons.verified, color: Colors.orange),
                ],
              ),
            ),
            Row(
              children: [
                const SizedBox(width: 16),
                ChoiceChip(
                  label: Row(
                    children: [
                      Icon(conditionIcons['All'], size: 16),
                      const SizedBox(width: 4),
                      const Text('All'),
                    ],
                  ),
                  selected: selectedCondition == 'All',
                  onSelected: (_) => setState(() => selectedCondition = 'All'),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: Row(
                    children: [
                      Icon(conditionIcons['New'], size: 16),
                      const SizedBox(width: 4),
                      const Text('New'),
                    ],
                  ),
                  selected: selectedCondition == 'New',
                  onSelected: (_) => setState(() => selectedCondition = 'New'),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: Row(
                    children: [
                      Icon(conditionIcons['Used'], size: 16),
                      const SizedBox(width: 4),
                      const Text('Used'),
                    ],
                  ),
                  selected: selectedCondition == 'Used',
                  onSelected: (_) => setState(() => selectedCondition = 'Used'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Text('Sort By', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Icon(Icons.sort, color: Colors.purple),
                ],
              ),
            ),
            Row(
              children: [
                const SizedBox(width: 16),
                ChoiceChip(
                  label: Row(
                    children: [
                      Icon(sortIcons['Newest'], size: 16),
                      const SizedBox(width: 4),
                      const Text('Newest'),
                    ],
                  ),
                  selected: selectedSort == 'Newest',
                  onSelected: (_) => setState(() => selectedSort = 'Newest'),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: Row(
                    children: [
                      Icon(sortIcons['PriceAsc'], size: 16),
                      const SizedBox(width: 4),
                      const Text('Price ↑'),
                    ],
                  ),
                  selected: selectedSort == 'PriceAsc',
                  onSelected: (_) => setState(() => selectedSort = 'PriceAsc'),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: Row(
                    children: [
                      Icon(sortIcons['PriceDesc'], size: 16),
                      const SizedBox(width: 4),
                      const Text('Price ↓'),
                    ],
                  ),
                  selected: selectedSort == 'PriceDesc',
                  onSelected: (_) => setState(() => selectedSort = 'PriceDesc'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        widget.onClear();
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.clear),
                      label: const Text('Clear All'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        widget.onApply({
                          'category': selectedCategory,
                          'priceRange': priceRange,
                          'condition': selectedCondition,
                          'sort': selectedSort,
                        });
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Apply Filters'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      ),
    );
  }
} 