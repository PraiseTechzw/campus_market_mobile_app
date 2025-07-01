import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../application/add_product_provider.dart';
import 'package:go_router/go_router.dart';

class AddProductStep2DetailsScreen extends HookConsumerWidget {
  const AddProductStep2DetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(addProductProvider);
    final notifier = ref.read(addProductProvider.notifier);
    final titleController = TextEditingController(text: state.title);
    final descController = TextEditingController(text: state.description);
    final priceController = TextEditingController(text: state.price == 0.0 ? '' : state.price.toString());
    final conditions = ['New', 'Used'];
    final isValid = state.title.isNotEmpty && state.description.isNotEmpty && state.price > 0 && state.condition.isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        leading: BackButton(onPressed: () {
          context.goNamed('addProductStep1');
        }),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              onChanged: notifier.updateTitle,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
              onChanged: notifier.updateDescription,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Price (USD)'),
              keyboardType: TextInputType.number,
              onChanged: (v) => notifier.updatePrice(double.tryParse(v) ?? 0.0),
            ),
            const SizedBox(height: 12),
            Row(
              children: conditions.map((cond) => Padding(
                padding: const EdgeInsets.only(right: 12),
                child: ChoiceChip(
                  label: Text(cond),
                  selected: state.condition == cond,
                  onSelected: (_) => notifier.updateCondition(cond),
                ),
              )).toList(),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isValid ? () {
                  context.pushNamed('addProductStep3');
                } : null,
                child: const Text('Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 