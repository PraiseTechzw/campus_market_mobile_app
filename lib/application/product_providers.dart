import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../infrastructure/product_repository.dart';
import '../domain/product_entity.dart';

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