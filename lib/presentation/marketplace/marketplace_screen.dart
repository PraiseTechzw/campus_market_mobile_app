import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:campus_market/application/product_providers.dart';
import 'package:campus_market/application/profile_provider.dart';
import 'package:campus_market/application/user_providers.dart';
import 'package:campus_market/domain/product_entity.dart';
import 'package:campus_market/domain/user_entity.dart';
import 'package:go_router/go_router.dart';
import 'filter_modal_screen.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class MarketplaceScreen extends HookConsumerWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print('DEBUG: MarketplaceScreen build called');
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF32CD32);

    // Category chips with icons
    final categories = [
      {'name': 'All', 'icon': Icons.apps},
      {'name': 'Electronics', 'icon': Icons.devices_other},
      {'name': 'Fashion', 'icon': Icons.checkroom},
      {'name': 'Books', 'icon': Icons.menu_book},
      {'name': 'Furniture', 'icon': Icons.chair},
      {'name': 'Sports', 'icon': Icons.sports_soccer},
      {'name': 'Beauty', 'icon': Icons.face},
      {'name': 'Others', 'icon': Icons.more_horiz},
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

    final searchController = useTextEditingController();
    final searchFocus = useFocusNode();
    final searchQuery = useState('');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        title: Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            boxShadow: searchFocus.hasFocus || searchQuery.value.isNotEmpty
                ? [
                    BoxShadow(
                      color: const Color(0xFF32CD32).withOpacity(0.6),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                : [],
            border: Border.all(
              color: (searchFocus.hasFocus || searchQuery.value.isNotEmpty)
                  ? const Color(0xFF32CD32)
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: TextField(
            controller: searchController,
            focusNode: searchFocus,
          decoration: InputDecoration(
              hintText: '🔍 Search products...',
            prefixIcon: Icon(Icons.search, color: isDark ? Colors.white70 : Colors.black54),
            border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
            onChanged: (query) {
              searchQuery.value = query;
          },
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite_border, color: primaryColor),
            onPressed: () => context.push('/favorites'),
          ),
          IconButton(
            icon: Icon(Icons.tune, color: primaryColor),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => FilterModalScreen(
                  categories: categories.map((c) => c['name'] as String).toList(),
                  initialFilters: filters.value,
                  onApply: (newFilters) {
                    filters.value = newFilters;
                    selectedCategory.value = newFilters['category'] ?? 'All';
                  },
                  onClear: () {
                    filters.value = {
                      'category': 'All',
                      'priceRange': const RangeValues(0, 100000),
                      'condition': 'All',
                      'sort': 'Newest',
                    };
                    selectedCategory.value = 'All';
                  },
                ),
              );
            },
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
                    final selected = selectedCategory.value == cat['name'];
                    return ChoiceChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(cat['icon'] as IconData, size: 16),
                          const SizedBox(width: 4),
                          Text(cat['name'] as String),
                        ],
                      ),
                      selected: selected,
                      selectedColor: primaryColor.withOpacity(0.2),
                      onSelected: (_) {
                        selectedCategory.value = cat['name'] as String;
                        filters.value = {
                          ...filters.value,
                          'category': cat['name'] as String,
                        };
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
              // Filter indicator
              if (filtersValue['category'] != 'All' || 
                  filtersValue['condition'] != 'All' || 
                  filtersValue['sort'] != 'Newest' ||
                  (filtersValue['priceRange'] as RangeValues).start > 0 ||
                  (filtersValue['priceRange'] as RangeValues).end < 100000)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: primaryColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.filter_alt, size: 16, color: primaryColor),
                      const SizedBox(width: 4),
                      Text(
                        'Filters Active',
                        style: TextStyle(fontSize: 12, color: primaryColor, fontWeight: FontWeight.w500),
                      ),
                    ],
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
                // Apply filters
                var filtered = products;
                
                // Category filter
                if (filtersValue['category'] != 'All') {
                  filtered = filtered.where((p) => p.category == filtersValue['category']).toList();
                }
                
                // Condition filter
                if (filtersValue['condition'] != 'All') {
                  filtered = filtered.where((p) => p.condition == filtersValue['condition']).toList();
                }
                
                // Price range filter (always start from 0)
                final priceRange = filtersValue['priceRange'] as RangeValues? ?? const RangeValues(0, 100000);
                final minPrice = 0.0;
                final maxPrice = priceRange.end;
                filtered = filtered.where((p) => p.price >= minPrice && p.price <= maxPrice).toList();
                
                // Search filter
                if (searchQuery.value.trim().isNotEmpty) {
                  final q = searchQuery.value.trim().toLowerCase();
                  filtered = filtered.where((p) =>
                    p.name.toLowerCase().contains(q) ||
                    p.description.toLowerCase().contains(q)
                  ).toList();
                }
                
                // Sort
                switch (filtersValue['sort']) {
                  case 'PriceAsc':
                      filtered.sort((a, b) => a.price.compareTo(b.price));
                    break;
                  case 'PriceDesc':
                      filtered.sort((a, b) => b.price.compareTo(a.price));
                    break;
                  case 'Newest':
                  default:
                    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
                    break;
                }
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
                      childAspectRatio: 0.75,
                    ),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final product = filtered[index];
                          final isNew = DateTime.now().difference(product.createdAt).inDays < 7;
                          final sellerAsync = ref.watch(sellerDataProvider(product.sellerId));
                          
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
                              clipBehavior: Clip.hardEdge,
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
                                        child: product.imageUrls.isNotEmpty
                                            ? Image.network(product.imageUrls.first, height: 130, width: double.infinity, fit: BoxFit.cover)
                                            : Container(height: 130, color: Colors.grey[300]),
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
                                      if (isNew)
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.orange.withOpacity(0.9),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Text(
                                              'NEW',
                                              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      if (product.status != 'Available')
                                        Positioned(
                                          bottom: 8,
                                          left: 8,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: product.status == 'Reserved' ? Colors.orange : Colors.red,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              product.status.toUpperCase(),
                                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product.name, 
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Row(
                                            children: [
                                              RatingBarIndicator(
                                                rating: product.rating,
                                                itemBuilder: (context, index) => const Icon(Icons.star, color: Colors.amber),
                                                itemCount: 5,
                                                itemSize: 10.0,
                                              ),
                                              const SizedBox(width: 4),
                                              Text('(${product.reviewCount})', style: const TextStyle(fontSize: 9, color: Colors.grey)),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '\$${product.price.toStringAsFixed(2)}', 
                                            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13),
                                          ),
                                          const SizedBox(height: 2),
                                          // Seller information
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              CircleAvatar(
                                                radius: 8,
                                                backgroundImage: sellerAsync.when(
                                                  data: (sellerData) => sellerData['selfieUrl'] != null 
                                                      ? NetworkImage(sellerData['selfieUrl']) 
                                                      : null,
                                                  loading: () => null,
                                                  error: (_, __) => null,
                                                ),
                                                child: sellerAsync.when(
                                                  data: (sellerData) => sellerData['selfieUrl'] == null 
                                                      ? const Icon(Icons.person, size: 12, color: Colors.grey)
                                                      : null,
                                                  loading: () => const Icon(Icons.person, size: 12, color: Colors.grey),
                                                  error: (_, __) => const Icon(Icons.person, size: 12, color: Colors.grey),
                                                ),
                                              ),
                                              const SizedBox(width: 3),
                                              Expanded(
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    sellerAsync.when(
                                                      data: (sellerData) => Text(
                                                        sellerData['name'] ?? 'Unknown',
                                                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w500),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                      loading: () => const Text(
                                                        'Loading...',
                                                        style: TextStyle(fontSize: 9, color: Colors.grey),
                                                      ),
                                                      error: (_, __) => const Text(
                                                        'Unknown',
                                                        style: TextStyle(fontSize: 9, color: Colors.grey),
                                                      ),
                                                    ),
                                                    Row(
                                                      mainAxisSize: MainAxisSize.min,
                                              children: [
                                                        Icon(Icons.school, size: 7, color: Colors.grey),
                                                        const SizedBox(width: 1),
                                                Expanded(
                                                  child: Text(
                                                            product.school.isNotEmpty ? product.school : 'Unknown School',
                                                            style: const TextStyle(fontSize: 7, color: Colors.grey),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
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