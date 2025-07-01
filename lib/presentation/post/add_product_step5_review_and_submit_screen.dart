import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../application/add_product_provider.dart';
import 'package:go_router/go_router.dart';
import 'listing_access_guard.dart';
import '../../infrastructure/product_repository.dart';
import '../../domain/product_entity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class AddProductStep5ReviewAndSubmitScreen extends HookConsumerWidget {
  const AddProductStep5ReviewAndSubmitScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(addProductProvider);
    final repo = ref.read(productRepositoryProvider);
    final primaryColor = const Color(0xFF32CD32);
    final isLoading = useState(false);
    Future<void> submit() async {
      isLoading.value = true;
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) throw Exception('Not logged in');
        final product = ProductEntity(
          id: '',
          name: state.title,
          description: state.description,
          price: state.price,
          category: state.category,
          condition: state.condition,
          imageUrl: state.imageUrls.isNotEmpty ? state.imageUrls.first : '',
          sellerId: user.uid,
          school: '', // TODO: fetch from user profile if needed
          campus: '', // TODO: fetch from user profile if needed
          city: '', // TODO: fetch from user profile if needed
          createdAt: DateTime.now(),
        );
        await repo.addProduct(product);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Listing submitted!')),
          );
          context.go('/');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit: $e')),
        );
      } finally {
        isLoading.value = false;
      }
    }
    return ListingAccessGuard(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Review & Submit'),
          backgroundColor: primaryColor,
          leading: BackButton(onPressed: () {
            context.goNamed('addProductStep4');
          }),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress indicator
              Row(
                children: [
                  Text('Step 5 of 5', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: 1.0,
                      color: primaryColor,
                      backgroundColor: primaryColor.withOpacity(0.15),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.category, color: primaryColor),
                          const SizedBox(width: 8),
                          Text('${state.type} - ${state.category}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.title, color: primaryColor),
                          const SizedBox(width: 8),
                          Text(state.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.description, color: primaryColor),
                          const SizedBox(width: 8),
                          Expanded(child: Text(state.description)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.attach_money, color: primaryColor),
                          const SizedBox(width: 8),
                          Text('USD ${state.price.toStringAsFixed(2)}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.check_circle, color: primaryColor),
                          const SizedBox(width: 8),
                          Text('Condition: ${state.condition}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (state.customFields.isNotEmpty)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline, color: primaryColor),
                            const SizedBox(width: 8),
                            Expanded(child: Text('Custom: ${state.customFields}')),
                          ],
                        ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.image, color: primaryColor),
                          const SizedBox(width: 8),
                          Text('Images: ${state.imageUrls.length} selected'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              if (isLoading.value) const Center(child: CircularProgressIndicator()),
              if (!isLoading.value)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          context.goNamed('addProductStep4');
                        },
                        child: const Text('Back'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: submit,
                        child: const Text('Submit', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
} 