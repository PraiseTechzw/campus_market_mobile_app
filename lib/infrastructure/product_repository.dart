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
} 