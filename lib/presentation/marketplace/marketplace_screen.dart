import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:campus_market/application/product_providers.dart';
import 'package:campus_market/application/profile_provider.dart';
import 'package:campus_market/domain/product_entity.dart';
import 'package:campus_market/domain/user_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'filter_modal_screen.dart';
import 'package:campus_market/application/user_providers.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class MarketplaceScreen extends HookConsumerWidget {
  const MarketplaceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print('DEBUG: MarketplaceScreen build called');
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF32CD32);

    // Category chips
    final categories = [
      'All', 'Electronics', 'Fashion', 'Books', 'Furniture', 'Others'
    ];
    final selectedCategory = useState('All');
    final filters = useState<Map<String, dynamic>>({
      'category': 'All',
      'priceRange': const RangeValues(0, 100000),
      'condition': 'All',
      'sort': 'Newest',
    });

    // Watch current user
    final userAsync = ref.watch(profileProvider);
    final filtersValue = filters.value;
    Map<String, String?>? providerFiltersNullable;
    if (userAsync is AsyncData<UserEntity?> && userAsync.value != null) {
      final user = userAsync.value!;
      providerFiltersNullable = {
        'category': filtersValue['category'],
        'condition': filtersValue['condition'],
      };
    }
    AsyncValue<List<ProductEntity>> productsAsync = const AsyncValue.loading();
    if (providerFiltersNullable != null) {
      final Map<String, String?> providerFilters = providerFiltersNullable;
      productsAsync = ref.watch(productListProvider);
    }
    print('DEBUG: productsAsync value: $productsAsync');

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
            if (query.trim().isNotEmpty) {
              context.push('/search', extra: query.trim());
            }
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: primaryColor),
            onPressed: () {},
          ),
        ],
        elevation: 0,
      ),
      body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          // Category chips
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
          // Product grid
              Expanded(
                child: productsAsync.when(
              loading: () {
                // Loading skeletons
                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: 6,
                  itemBuilder: (context, index) => Container(
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[900] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: SpinKitPulse(color: Colors.grey, size: 40),
                    ),
                  ),
                );
              },
              error: (e, stack) {
                print('DEBUG: productsAsync error: $e');
                print('DEBUG: productsAsync stack: $stack');
                return Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Products Error: $e', style: TextStyle(color: Colors.red)),
                        SizedBox(height: 8),
                        Text('Stack: $stack', style: TextStyle(fontSize: 10)),
                      ],
                    ),
                  ),
                );
              },
                  data: (products) {
                print('DEBUG: productsAsync data: count = ${products.length}');
                // Filter by selected category
                final filtered = selectedCategory.value == 'All'
                  ? products
                  : products.where((p) => p.category == selectedCategory.value).toList();
                    if (filtered.isEmpty) {
                  print('DEBUG: No products found after filtering');
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text('No products found.', style: TextStyle(fontSize: 18)),
                      ],
                    ),
                  );
                    }
                    return RefreshIndicator(
                      onRefresh: () async {
                    ref.refresh(productListProvider);
                  },
                  child: GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.7,
                    ),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final product = filtered[index];
                      return GestureDetector(
                        onTap: () {
                          context.push('/product/${product.id}', extra: product);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[900] : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.07),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      topRight: Radius.circular(16),
                                    ),
                                    child: product.imageUrl.isNotEmpty
                                        ? Image.network(product.imageUrl, height: 140, width: double.infinity, fit: BoxFit.cover)
                                        : Container(height: 140, color: Colors.grey[300]),
                                  ),
                                  Positioned(
                                    top: 8,
                                    left: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: primaryColor.withOpacity(0.9),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        product.category,
                                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    const SizedBox(height: 4),
                                    Text('[\$${product.price.toStringAsFixed(2)}]', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text('Condition: ${product.condition}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
      ),
    );
  }
} 