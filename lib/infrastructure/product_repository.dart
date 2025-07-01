import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../domain/product_entity.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) => ProductRepository());

class ProductRepository {
  final _products = FirebaseFirestore.instance.collection('products');

  // Fetch all products
  Stream<List<ProductEntity>> fetchProducts() {
    return _products.orderBy('createdAt', descending: true).snapshots().map(
      (snap) => snap.docs.map((doc) => ProductEntity.fromMap(doc.data(), doc.id)).toList(),
    );
  }

  // Fetch product by ID
  Future<ProductEntity?> fetchProductById(String id) async {
    final doc = await _products.doc(id).get();
    if (!doc.exists) return null;
    return ProductEntity.fromMap(doc.data()!, doc.id);
  }

  // Add new product
  Future<void> addProduct(ProductEntity product) async {
    await _products.add(product.toMap());
  }

  // Update product
  Future<void> updateProduct(String id, Map<String, dynamic> data) async {
    await _products.doc(id).update(data);
  }

  // Delete product
  Future<void> deleteProduct(String id) async {
    await _products.doc(id).delete();
  }

  // Fetch products with filters
  Stream<List<ProductEntity>> fetchFilteredProducts({
    required String? school,
    required String? campus,
    required String? city,
    String? category,
  }) {
    Query query = _products;
    if (category != null && category != 'All') {
      query = query.where('category', isEqualTo: category);
    }
    if (school != null) {
      query = query.where('school', isEqualTo: school);
    }
    if (campus != null) {
      query = query.where('campus', isEqualTo: campus);
    }
    if (city != null) {
      query = query.where('city', isEqualTo: city);
    }
    // Only show products from verified users
    // This requires a join, but Firestore doesn't support joins. We'll filter client-side for now.
    return query.orderBy('createdAt', descending: true).snapshots().asyncMap((snap) async {
      final products = snap.docs
          .map((doc) => ProductEntity.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
      // Fetch user verification status for each product
      final firestore = FirebaseFirestore.instance;
      final filtered = <ProductEntity>[];
      for (final product in products) {
        final userDoc = await firestore.collection('users').doc(product.sellerId).get();
        final data = userDoc.data();
        if (userDoc.exists && data is Map<String, dynamic>) {
          final map = data as Map<String, dynamic>;
          if (map['isVerified'] == true) {
            filtered.add(product);
          }
        }
      }
      return filtered;
    });
  }
} 