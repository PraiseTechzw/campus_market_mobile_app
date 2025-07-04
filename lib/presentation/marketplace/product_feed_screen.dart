import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../application/product_providers.dart';
import '../../domain/product_entity.dart';
import '../core/components/app_card.dart';
import '../core/components/app_button.dart';
import '../core/app_theme.dart';
import 'package:go_router/go_router.dart';

class ProductFeedScreen extends ConsumerWidget {
  const ProductFeedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productListProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: productsAsync.when(
        data: (products) {
          print('DEBUG: Product stream emitted with count: [products.length]');
          return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: products.length,
          itemBuilder: (context, i) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ProductListTile(product: products[i]),
          ),
          );
        },
        loading: () {
          print('DEBUG: Product stream is loading');
          return const Center(child: CircularProgressIndicator());
        },
        error: (e, _) {
          print('DEBUG: Product stream error: $e');
          return Center(child: Text('Error: $e'));
        },
      ),
      );
  }
}

class ProductListTile extends StatelessWidget {
  final ProductEntity product;
  const ProductListTile({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: ListTile(
        leading: product.imageUrl.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(product.imageUrl, width: 56, height: 56, fit: BoxFit.cover),
              )
            : Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.image, color: Colors.grey),
              ),
        title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('USD ${product.price.toStringAsFixed(2)}'),
        onTap: () {
          GoRouter.of(context).push('/product/${product.id}', extra: product);
        },
      ),
    );
  }
} 