import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_app_devels/domain/entities/product.dart';
import 'package:qr_app_devels/presentation/providers/products/products_repo_provider.dart';

final productsProvider = FutureProvider<List<Product>>((ref) async {

  final productRepo = ref.watch(productRepoProvider);
  return await productRepo.getProducts();
  
});

final productIdProvider = FutureProvider.autoDispose.family<Product, int>((ref, id) async {
  final productRepo = ref.watch( productRepoProvider );
  return await productRepo.fetchProduct(productId: id);
});

