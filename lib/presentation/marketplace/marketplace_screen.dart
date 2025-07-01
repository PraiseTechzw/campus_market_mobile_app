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
    final filters = useState<Map<String, dynamic>>({
      'category': 'All',
      'priceRange': const RangeValues(0, 100000),
      'condition': 'All',
      'sort': 'Newest',
    });

    // Watch current user
    final userAsync = ref.watch(profileProvider);

    // Build filters for product provider
    Map<String, String?> providerFilters = {};
    userAsync.whenData((user) {
      providerFilters = {
        'school': user?.school,
        'campus': user?.campus,
        'city': user?.location,
        'category': filters.value['category'],
        'condition': filters.value['condition'],
        // priceRange and sort handled client-side for now
      };
    });

    final productsAsync = ref.watch(filteredProductListProvider(providerFilters));

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
            onPressed: () async {
              await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => FilterModalScreen(
                  categories: categories,
                  initialFilters: filters.value,
                  onApply: (newFilters) {
                    filters.value = newFilters;
                  },
                  onClear: () {
                    filters.value = {
                      'category': 'All',
                      'priceRange': const RangeValues(0, 100000),
                      'condition': 'All',
                      'sort': 'Newest',
                    };
                  },
                ),
              );
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
                    final selected = filters.value['category'] == cat;
                    return ChoiceChip(
                      label: Text(cat),
                      selected: selected,
                      selectedColor: primaryColor.withOpacity(0.2),
                      onSelected: (_) => filters.value = {
                        ...filters.value,
                        'category': cat,
                      },
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
                    // Client-side filter for price and sort
                    var filtered = products.where((p) {
                      final price = p.price;
                      final range = filters.value['priceRange'] as RangeValues;
                      final cond = filters.value['condition'];
                      final condOk = cond == 'All' || p.condition == cond;
                      return price >= range.start && price <= range.end && condOk;
                    }).toList();
                    final sort = filters.value['sort'];
                    if (sort == 'PriceAsc') {
                      filtered.sort((a, b) => a.price.compareTo(b.price));
                    } else if (sort == 'PriceDesc') {
                      filtered.sort((a, b) => b.price.compareTo(a.price));
                    } // else Newest is default from Firestore
                    if (filtered.isEmpty) {
                      return const Center(child: Text('No products found.'));
                    }
                    return RefreshIndicator(
                      onRefresh: () async {
                        ref.refresh(filteredProductListProvider(providerFilters));
                      },
                      child: ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final product = filtered[index];
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
                                ],
                              ),
                              onTap: () {
                                context.push('/product/${product.id}', extra: product);
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