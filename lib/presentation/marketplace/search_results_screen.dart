import 'package:campus_market/application/user_providers.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:campus_market/application/product_providers.dart';
import 'package:campus_market/domain/product_entity.dart';

class SearchResultsScreen extends HookConsumerWidget {
  final String initialQuery;
  const SearchResultsScreen({Key? key, required this.initialQuery}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queryController = TextEditingController(text: initialQuery);
    final searchQuery = useState(initialQuery);

    // For simplicity, search by name (case-insensitive contains)
    final productsAsync = ref.watch(filteredProductListProvider({}));

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: queryController,
          decoration: const InputDecoration(
            hintText: 'Search products...',
            border: InputBorder.none,
          ),
          onSubmitted: (q) => searchQuery.value = q,
        ),
      ),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (products) {
          final results = products.where((p) =>
            p.name.toLowerCase().contains(searchQuery.value.toLowerCase())
          ).toList();
          if (results.isEmpty) {
            return const Center(child: Text('No products found.'));
          }
          return ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) {
              final product = results[index];
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
                    context.push('/product/${product.id}', extra: product);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
} 