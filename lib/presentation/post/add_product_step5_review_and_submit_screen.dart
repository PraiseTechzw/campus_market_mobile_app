import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../application/add_product_provider.dart';

class AddProductStep5ReviewAndSubmitScreen extends HookConsumerWidget {
  const AddProductStep5ReviewAndSubmitScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(addProductProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review & Submit'),
        leading: BackButton(onPressed: () {
          // TODO: Go back to previous step
        }),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Review your listing:'),
            const SizedBox(height: 16),
            Text('Type: ${state.type}'),
            Text('Category: ${state.category}'),
            Text('Title: ${state.title}'),
            Text('Description: ${state.description}'),
            Text('Price: ${state.price}'),
            Text('Condition: ${state.condition}'),
            Text('Custom Fields: ${state.customFields}'),
            Text('Images: ${state.imageUrls.length} selected'),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // TODO: Go back
                    },
                    child: const Text('Back'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Submit listing
                    },
                    child: const Text('Submit'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 