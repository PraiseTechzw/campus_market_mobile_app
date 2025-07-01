import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../application/add_product_provider.dart';

class AddProductStep1CategoryScreen extends HookConsumerWidget {
  const AddProductStep1CategoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(addProductProvider);
    final notifier = ref.read(addProductProvider.notifier);
    final categories = [
      'Phones', 'Books', 'Electronics', 'Clothing', 'Hairdressing', 'Tutoring', 'Other'
    ];
    final types = ['Product', 'Service'];
    return Scaffold(
      appBar: AppBar(title: const Text('Choose Type & Category')),
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
                  onSelected: (_) => notifier.updateType(type),
                ),
              )).toList(),
            ),
            const SizedBox(height: 24),
            const Text('Select Category', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 3.5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: categories.map((cat) => GestureDetector(
                  onTap: () => notifier.updateCategory(cat),
                  child: Card(
                    color: state.category == cat ? Colors.green[100] : null,
                    child: Center(child: Text(cat)),
                  ),
                )).toList(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: state.type.isNotEmpty && state.category.isNotEmpty
                    ? () {
                        context.pushNamed('addProductStep2');
                      }
                    : null,
                child: const Text('Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 