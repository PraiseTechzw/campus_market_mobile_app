import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../application/add_product_provider.dart';

class AddProductStep4ImagesScreen extends HookConsumerWidget {
  const AddProductStep4ImagesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(addProductProvider);
    final notifier = ref.read(addProductProvider.notifier);
    // For now, just show a placeholder for images
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Images'),
        leading: BackButton(onPressed: () {
          // TODO: Go back to previous step
        }),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add 1–5 images'),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: state.imageUrls.length + 1,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  if (index < state.imageUrls.length) {
                    final url = state.imageUrls[index];
                    return Stack(
                      children: [
                        Image.network(url, width: 100, height: 100, fit: BoxFit.cover),
                        Positioned(
                          top: 0, right: 0,
                          child: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              // TODO: Remove image
                            },
                          ),
                        ),
                      ],
                    );
                  } else {
                    return GestureDetector(
                      onTap: () {
                        // TODO: Pick image
                      },
                      child: Container(
                        width: 100, height: 100,
                        color: Colors.grey[300],
                        child: const Icon(Icons.add_a_photo),
                      ),
                    );
                  }
                },
              ),
            ),
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
                    onPressed: state.imageUrls.isNotEmpty ? () {
                      // TODO: Go to next step
                    } : null,
                    child: const Text('Next'),
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