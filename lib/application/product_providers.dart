import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../infrastructure/product_repository.dart';
import '../domain/product_entity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Provider for product list stream
final productListProvider = StreamProvider<List<ProductEntity>>((ref) {
  return ref.watch(productRepositoryProvider).fetchProducts();
});

// Provider for single product by ID
final productDetailProvider = FutureProvider.family<ProductEntity?, String>((ref, id) {
  return ref.watch(productRepositoryProvider).fetchProductById(id);
});

// Provider for adding a product
final addProductProvider = FutureProvider.family<void, ProductEntity>((ref, product) async {
  await ref.watch(productRepositoryProvider).addProduct(product);
});

// Provider for filtered product list stream
final filteredProductListProvider = StreamProvider.autoDispose.family<List<ProductEntity>, Map<String, String?>>((ref, filters) {
  final repo = ref.watch(productRepositoryProvider);
  return repo.fetchFilteredProducts(
    school: filters['school'],
    campus: filters['campus'],
    city: filters['city'],
    category: filters['category'],
  );
});

// Provider for user's favorite products
final userFavoritesProvider = StreamProvider<List<String>>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value([]);
  
  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('favorites')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
});

// Provider for user's favorite product entities
final userFavoriteProductsProvider = StreamProvider<List<ProductEntity>>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value([]);
  
  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('favorites')
      .snapshots()
      .asyncMap((snapshot) async {
        final productIds = snapshot.docs.map((doc) => doc.id).toList();
        if (productIds.isEmpty) return [];
        
        final products = await Future.wait(
          productIds.map((id) => FirebaseFirestore.instance
              .collection('products')
              .doc(id)
              .get()
              .then((doc) => doc.exists ? ProductEntity.fromMap(doc.data()!, doc.id) : null)
              .catchError((_) => null))
        );
        
        return products.where((product) => product != null).cast<ProductEntity>().toList();
      });
});

// Provider for adding/removing favorites
final toggleFavoriteProvider = FutureProvider.family<void, String>((ref, productId) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) throw Exception('User not logged in');
  
  final favoritesRef = FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('favorites');
  
  final doc = await favoritesRef.doc(productId).get();
  if (doc.exists) {
    await favoritesRef.doc(productId).delete();
  } else {
    await favoritesRef.doc(productId).set({'addedAt': FieldValue.serverTimestamp()});
  }
});

// Provider for product reviews
final productReviewsProvider = StreamProvider.family<List<Map<String, dynamic>>, String>((ref, productId) {
  return FirebaseFirestore.instance
      .collection('products')
      .doc(productId)
      .collection('reviews')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
});

// Provider for adding a review
final addReviewProvider = FutureProvider.family<void, Map<String, dynamic>>((ref, reviewData) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) throw Exception('User not logged in');
  
  final productId = reviewData['productId'];
  final rating = reviewData['rating'];
  final comment = reviewData['comment'];
  
  // Add review
  await FirebaseFirestore.instance
      .collection('products')
      .doc(productId)
      .collection('reviews')
      .doc(user.uid)
      .set({
    'rating': rating,
    'comment': comment,
    'userId': user.uid,
    'createdAt': FieldValue.serverTimestamp(),
  });
  
  // Update product rating
  final reviewsSnapshot = await FirebaseFirestore.instance
      .collection('products')
      .doc(productId)
      .collection('reviews')
      .get();
  
  final reviews = reviewsSnapshot.docs;
  final totalRating = reviews.fold<double>(0, (sum, doc) => sum + (doc.data()['rating'] ?? 0));
  final averageRating = reviews.isNotEmpty ? totalRating / reviews.length : 0.0;
  
  await FirebaseFirestore.instance
      .collection('products')
      .doc(productId)
      .update({
    'rating': averageRating,
    'reviewCount': reviews.length,
  });
}); 