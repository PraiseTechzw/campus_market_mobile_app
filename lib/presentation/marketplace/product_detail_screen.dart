import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:campus_market/domain/product_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ProductDetailScreen extends HookConsumerWidget {
  final ProductEntity product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sellerFuture = useMemoized(() async {
      final doc = await FirebaseFirestore.instance.collection('users').doc(product.sellerId).get();
      return doc.data();
    });
    final sellerAsync = useFuture(sellerFuture);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        leading: BackButton(),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Image carousel
          if (product.imageUrls.isNotEmpty)
            Column(
              children: [
                CarouselSlider(
                  options: CarouselOptions(
                    height: 240,
                    viewportFraction: 1.0,
                    enableInfiniteScroll: false,
                    enlargeCenterPage: true,
                  ),
                  items: product.imageUrls.map((url) {
                    return Builder(
                      builder: (BuildContext context) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(url, height: 220, width: double.infinity, fit: BoxFit.cover),
                        );
                      },
                    );
                  }).toList(),
                ),
                if (product.imageUrls.length > 1)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      product.imageUrls.length,
                      (index) => Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                  ),
              ],
            )
          else
            Hero(
              tag: 'product-image-${product.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: product.imageUrl.isNotEmpty
                    ? Image.network(product.imageUrl, height: 220, width: double.infinity, fit: BoxFit.cover)
                    : Container(height: 220, color: Colors.grey[300]),
              ),
            ),
          const SizedBox(height: 16),
          Text(product.name, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text('₦${product.price.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.green)),
          const SizedBox(height: 8),
          Row(
            children: [
              Chip(label: Text(product.category)),
              const SizedBox(width: 8),
              Chip(label: Text(product.condition)),
            ],
          ),
          const SizedBox(height: 16),
          Text(product.description, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 24),
          Text('Seller', style: Theme.of(context).textTheme.titleMedium),
          sellerAsync.connectionState == ConnectionState.waiting
              ? const ListTile(title: Text('Loading...'))
              : sellerAsync.data != null
                  ? ListTile(
                      leading: sellerAsync.data!['selfieUrl'] != null
                          ? CircleAvatar(backgroundImage: NetworkImage(sellerAsync.data!['selfieUrl']))
                          : const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(sellerAsync.data!['name'] ?? 'Unknown'),
                      subtitle: Text(sellerAsync.data!['email'] ?? ''),
                    )
                  : const ListTile(title: Text('Seller info not found')),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.chat),
                  label: const Text('Message Seller'),
                  onPressed: () {
                    // Implement chat navigation
                    GoRouter.of(context).push('/chat', extra: product);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.report),
                  label: const Text('Report Product'),
                  onPressed: () async {
                    // Implement report logic: show a simple dialog
                    await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Report Product'),
                        content: const Text('Thank you for reporting. Our team will review this product.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 