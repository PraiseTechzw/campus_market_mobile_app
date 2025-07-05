import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:campus_market/domain/product_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

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
          Text('\$${product.price.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.green)),
          const SizedBox(height: 8),
          Row(
            children: [
              Chip(label: Text(product.category)),
              const SizedBox(width: 8),
              Chip(label: Text(product.condition)),
              const SizedBox(width: 8),
              Chip(
                label: Text('Stock: ${product.stock}'),
                backgroundColor: product.stock > 0 ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                labelStyle: TextStyle(color: product.stock > 0 ? Colors.green : Colors.red),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text('${product.campus}, ${product.city}', style: TextStyle(color: Colors.grey)),
              const Spacer(),
              Icon(Icons.access_time, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(_getTimeAgo(product.createdAt), style: TextStyle(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 16),
          Text(product.description, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 24),
          // Rating and Reviews Section
          Row(
            children: [
              Text('Rating & Reviews', style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              Text('${product.rating.toStringAsFixed(1)} ★ (${product.reviewCount} reviews)', style: TextStyle(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              RatingBarIndicator(
                rating: product.rating,
                itemBuilder: (context, index) => const Icon(Icons.star, color: Colors.amber),
                itemCount: 5,
                itemSize: 24.0,
              ),
              const SizedBox(width: 8),
              Text('${product.rating.toStringAsFixed(1)}', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          // Status Management
          if (product.status == 'Available')
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.schedule),
                    label: const Text('Reserve'),
                    onPressed: () async {
                      // Update product status to Reserved
                      await FirebaseFirestore.instance
                          .collection('products')
                          .doc(product.id)
                          .update({'status': 'Reserved'});
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Product reserved!')),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Mark Sold'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: () async {
                      // Update product status to Sold
                      await FirebaseFirestore.instance
                          .collection('products')
                          .doc(product.id)
                          .update({'status': 'Sold'});
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Product marked as sold!')),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          if (product.status != 'Available')
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: product.status == 'Reserved' ? Colors.orange.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: product.status == 'Reserved' ? Colors.orange : Colors.red,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    product.status == 'Reserved' ? Icons.schedule : Icons.check_circle,
                    color: product.status == 'Reserved' ? Colors.orange : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Status: ${product.status}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: product.status == 'Reserved' ? Colors.orange : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          // Meetup Location
          if (product.meetupLocation.isNotEmpty) ...[
            Row(
              children: [
                Icon(Icons.location_on, color: primaryColor),
                const SizedBox(width: 8),
                const Text('Meetup Location', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(product.meetupLocation),
            ),
            const SizedBox(height: 16),
          ],
          Text('Seller', style: Theme.of(context).textTheme.titleMedium),
          sellerAsync.connectionState == ConnectionState.waiting
              ? const ListTile(title: Text('Loading...'))
              : sellerAsync.data != null
                  ? ListTile(
                      leading: sellerAsync.data!['selfieUrl'] != null
                          ? CircleAvatar(backgroundImage: NetworkImage(sellerAsync.data!['selfieUrl']))
                          : const CircleAvatar(child: Icon(Icons.person)),
                      title: Row(
                        children: [
                          Text(sellerAsync.data!['name'] ?? 'Unknown'),
                          if (sellerAsync.data!['isVerified'] == true)
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Icon(Icons.verified, color: Colors.blue, size: 20),
                            ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(sellerAsync.data!['email'] ?? ''),
                          if (sellerAsync.data!['phone'] != null)
                            Text(sellerAsync.data!['phone']),
                        ],
                      ),
                    )
                  : const ListTile(title: Text('Seller info not found')),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.chat),
                  label: const Text('Message'),
                  onPressed: () {
                    GoRouter.of(context).push('/chat', extra: product);
                  },
                ),
              ),
              const SizedBox(width: 8),
              if (sellerAsync.data != null && sellerAsync.data!['phone'] != null)
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.phone),
                    label: const Text('Call'),
                    onPressed: () async {
                      final phone = sellerAsync.data!['phone'];
                      final url = 'tel:$phone';
                      if (await canLaunchUrl(Uri.parse(url))) {
                        await launchUrl(Uri.parse(url));
                      }
                    },
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                  onPressed: () {
                    Share.share('Check out this product: ${product.name} - \$${product.price.toStringAsFixed(2)}');
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.report),
                  label: const Text('Report'),
                  onPressed: () async {
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

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
} 