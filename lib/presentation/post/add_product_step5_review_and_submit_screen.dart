import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../application/add_product_provider.dart';
import 'package:go_router/go_router.dart';
import 'listing_access_guard.dart';
import '../../infrastructure/product_repository.dart';
import '../../domain/product_entity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../presentation/core/app_router.dart';

class AddProductStep5ReviewAndSubmitScreen extends HookConsumerWidget {
  const AddProductStep5ReviewAndSubmitScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(addProductProvider);
    final repo = ref.read(productRepositoryProvider);
    final primaryColor = const Color(0xFF32CD32);
    final isLoading = useState(false);
    final userEntityAsync = ref.watch(userEntityProvider);
    final userEntity = userEntityAsync.asData?.value;
    if (userEntityAsync.isLoading || userEntity == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
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
          school: userEntity.school ?? '',
          campus: userEntity.campus ?? '',
          city: userEntity.location ?? '',
          createdAt: DateTime.now(),
        );
        await repo.addProduct(product);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Listing submitted!')),
          );
          context.go('/home');
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
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                                  // Product image
                                  if (state.imageUrls.isNotEmpty)
                                    Center(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          state.imageUrls.first,
                                          height: 140,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  if (state.imageUrls.isNotEmpty) const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Icon(Icons.category, color: primaryColor),
                                      const SizedBox(width: 8),
                                      Chip(
                                        label: Text(state.category, style: const TextStyle(fontWeight: FontWeight.bold)),
                                        backgroundColor: primaryColor.withOpacity(0.1),
                                        labelStyle: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(width: 8),
                                      Chip(
                                        label: Text(state.condition),
                                        backgroundColor: Colors.grey[200],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Icon(Icons.title, color: primaryColor),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          state.title,
                                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.attach_money, color: primaryColor),
                                      const SizedBox(width: 8),
                                      Text('USD ${state.price.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Divider(height: 24),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(Icons.description, color: primaryColor),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          state.description,
                                          style: const TextStyle(fontSize: 15),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  if (state.customFields.isNotEmpty)
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.info_outline, color: primaryColor),
                                            const SizedBox(width: 8),
                                            const Text('Custom Fields', style: TextStyle(fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        ...state.customFields.entries.map((e) => Padding(
                                          padding: const EdgeInsets.only(bottom: 4),
                                          child: Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: primaryColor.withOpacity(0.08),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  e.key.replaceFirst('custom_', '').capitalize(),
                                                  style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  e.value,
                                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )),
                                      ],
                                    ),
                                  const SizedBox(height: 12),
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
                          const SizedBox(height: 24),
                          if (isLoading.value) const Center(child: CircularProgressIndicator()),
                        ],
                      ),
                    ),
                  ),
                  if (!isLoading.value)
                    Padding(
                      padding: EdgeInsets.only(
                        left: 16, right: 16, bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                      ),
                      child: Row(
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
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

extension StringCasingExtension on String {
  String capitalize() => isEmpty ? '' : this[0].toUpperCase() + substring(1);
} 