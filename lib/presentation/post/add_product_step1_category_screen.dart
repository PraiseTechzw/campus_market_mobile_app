import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../application/add_product_provider.dart';
import 'listing_access_guard.dart';

class AddProductStep1CategoryScreen extends HookConsumerWidget {
  const AddProductStep1CategoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(addProductProvider);
    final notifier = ref.read(addProductProvider.notifier);
    final primaryColor = const Color(0xFF32CD32);
    final categories = [
      'Phones', 'Books', 'Electronics', 'Clothing', 'Hairdressing', 'Tutoring', 'Other'
    ];
    final categoryIcons = {
      'Phones': Icons.phone_android,
      'Books': Icons.menu_book,
      'Electronics': Icons.devices_other,
      'Clothing': Icons.checkroom,
      'Hairdressing': Icons.content_cut,
      'Tutoring': Icons.school,
      'Other': Icons.category,
    };
    final types = ['Product', 'Service'];
    return ListingAccessGuard(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Choose Type & Category'),
          backgroundColor: primaryColor,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('What are you posting?', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: types.map((type) => Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ChoiceChip(
                    label: Text(type),
                    selected: state.type == type,
                    selectedColor: primaryColor,
                    onSelected: (_) => notifier.updateType(type),
                    labelStyle: TextStyle(
                      color: state.type == type ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    backgroundColor: Colors.grey[900],
                    side: BorderSide(color: state.type == type ? primaryColor : Colors.grey[700]!),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 24),
              const Text('Select Category', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 3.5,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: categories.map((cat) {
                    final selected = state.category == cat;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        color: selected ? primaryColor.withOpacity(0.15) : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: selected ? primaryColor : Colors.grey[700]!),
                        boxShadow: selected
                            ? [BoxShadow(color: primaryColor.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2))]
                            : [],
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => notifier.updateCategory(cat),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(categoryIcons[cat], color: selected ? primaryColor : Colors.grey[500]),
                            const SizedBox(width: 12),
                            Text(
                              cat,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: selected ? primaryColor : Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: state.type.isNotEmpty && state.category.isNotEmpty ? primaryColor : Colors.grey[800],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: state.type.isNotEmpty && state.category.isNotEmpty
                      ? () {
                          context.pushNamed('addProductStep2');
                        }
                      : null,
                  child: const Text('Next', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 