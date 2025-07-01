import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:campus_market/application/product_providers.dart';
import 'package:campus_market/application/profile_provider.dart';
import 'package:campus_market/domain/product_entity.dart';
import 'package:campus_market/domain/user_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MarketplaceScreen extends HookConsumerWidget {
  const MarketplaceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF32CD32);

    // Placeholder categories
    final categories = [
      'All', 'Books', 'Electronics', 'Fashion', 'Furniture', 'Others'
    ];
    final selectedCategory = useState('All');

    // Watch current user
    final userAsync = ref.watch(profileProvider);

    // Build filters for product provider
    Map<String, String?> filters = {};
    userAsync.whenData((user) {
      filters = {
        'school': user?.school,
        'campus': user?.campus,
        'city': user?.location,
        'category': selectedCategory.value,
      };
    });

    final productsAsync = ref.watch(filteredProductListProvider(filters));

    // Provider to fetch seller name by userId
    final sellerNameProvider = FutureProvider.family<String, String>((ref, sellerId) async {
      // Fetch user from Firestore
      final doc = await FirebaseFirestore.instance.collection('users').doc(sellerId).get();
      final data = doc.data();
      if (doc.exists && data != null && data['name'] != null) {
        return data['name'] as String;
      }
      return 'Unknown';
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        title: TextField(
          decoration: InputDecoration(
            hintText: 'Search products...',
            prefixIcon: Icon(Icons.search, color: isDark ? Colors.white70 : Colors.black54),
            border: InputBorder.none,
          ),
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          onSubmitted: (query) {
            // TODO: Navigate to SearchResultsScreen
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: primaryColor),
            onPressed: () {
              // TODO: Open FilterModalScreen
            },
          ),
        ],
        elevation: 0,
      ),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (user) {
          if (user == null) {
            return const Center(child: Text('User not found'));
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 48,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    final selected = selectedCategory.value == cat;
                    return ChoiceChip(
                      label: Text(cat),
                      selected: selected,
                      selectedColor: primaryColor.withOpacity(0.2),
                      onSelected: (_) => selectedCategory.value = cat,
                      labelStyle: TextStyle(
                        color: selected ? primaryColor : (isDark ? Colors.white : Colors.black),
                      ),
                      backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                      side: BorderSide(color: selected ? primaryColor : Colors.transparent),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: productsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                  data: (products) {
                    if (products.isEmpty) {
                      return const Center(child: Text('No products found.'));
                    }
                    return RefreshIndicator(
                      onRefresh: () async {
                        ref.refresh(filteredProductListProvider(filters));
                      },
                      child: ListView.builder(
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          final sellerNameAsync = ref.watch(sellerNameProvider(product.sellerId));
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: ListTile(
                              leading: product.imageUrl.isNotEmpty
                                  ? Image.network(product.imageUrl, width: 56, height: 56, fit: BoxFit.cover)
                                  : Container(width: 56, height: 56, color: Colors.grey[300]),
                              title: Text(product.name),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('₦${product.price.toStringAsFixed(2)}'),
                                  Text('Condition: ${product.condition}'),
                                  sellerNameAsync.when(
                                    data: (name) => Text('Seller: $name'),
                                    loading: () => const Text('Seller: ...'),
                                    error: (_, __) => const Text('Seller: Unknown'),
                                  ),
                                ],
                              ),
                              onTap: () {
                                // TODO: Navigate to ProductDetailScreen
                              },
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
} 